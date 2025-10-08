import 'dart:async';
import 'dart:convert';


import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';


class ThreeDCube extends StatefulWidget {
  final Function(int)? onDurationSelected;
  final Function(double x, double y, double z)? onRotationChanged;

  const ThreeDCube({
    super.key,
    this.onDurationSelected,
    this.onRotationChanged,
  });

  @override
  State<ThreeDCube> createState() => _ThreeDCubeState();
}

class _ThreeDCubeState extends State<ThreeDCube> with WidgetsBindingObserver {
  WebViewController? _controller;
  bool _isWebViewLoaded = false;
  String? _objContent;
  String? _mtlContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // macOS 不支持透明背景的 WebView，直接跳过初始化以避免异常
    if (!kIsWeb) {
      _loadModelFiles();
    }
  }

  Future<void> _loadModelFiles() async {
    try {
      // debugPrint('开始加载模型文件...');
      final objBytes = await rootBundle.load('assets/cube/tomato-timer.obj');
      final mtlBytes = await rootBundle.load('assets/cube/tomato-timer.mtl');

      _objContent = base64Encode(objBytes.buffer.asUint8List());
      _mtlContent = base64Encode(mtlBytes.buffer.asUint8List());

      // debugPrint(
      //   '模型文件加载成功，OBJ大小: ${_objContent?.length}, MTL大小: ${_mtlContent?.length}',
      // );
      _initializeWebView();
    } catch (e) {
      // debugPrint('加载模型文件失败: $e');
      setState(() {
        _errorMessage = '加载模型文件失败: $e';
      });
    }
  }

  Future<void> _initializeWebView() async {
    if (_objContent == null || _mtlContent == null) {
      // debugPrint('模型文件内容为空');
      return;
    }

    try {
      // debugPrint('开始初始化WebView...');
      final String htmlContent = await _loadHtmlTemplate();
      // debugPrint('HTML模板加载成功');



      final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
      late final WebViewController controller;
      if (isMacOS) {
        final params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
        );
        controller = WebViewController.fromPlatformCreationParams(params)
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..enableZoom(false)
          ..setUserAgent('Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36')
          ..addJavaScriptChannel(
            'Flutter',
            onMessageReceived: (JavaScriptMessage message) {
              try {
                _onMessageReceived(message.message);
              } catch (e) {}
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() {
                  _isWebViewLoaded = true;
                });
                _initializeThreeJS();
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  _errorMessage = 'Web资源错误: ${error.description}';
                });
              },
            ),
          )
          ..loadHtmlString(htmlContent);
      } else {
        controller = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..enableZoom(false)
          ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
          ..addJavaScriptChannel(
            'Flutter',
            onMessageReceived: (JavaScriptMessage message) {
              try {
                _onMessageReceived(message.message);
              } catch (e) {}
            },
          )
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (String url) {
                setState(() {
                  _isWebViewLoaded = true;
                });
                _initializeThreeJS();
              },
              onWebResourceError: (WebResourceError error) {
                setState(() {
                  _errorMessage = 'Web资源错误: ${error.description}';
                });
              },
            ),
          )
          ..loadHtmlString(htmlContent);
      }

      // 仅在 Android/iOS 设置透明背景；macOS 不支持该调用，避免 UnimplementedError
      try {
        if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
          controller.setBackgroundColor(Colors.transparent);
        }
      } catch (_) {}

      setState(() {
        _controller = controller;
      });
      // debugPrint('WebView初始化完成');
    } catch (e) {
      // debugPrint('初始化WebView失败: $e');
      setState(() {
        _errorMessage = '初始化WebView失败: $e';
      });
    }
  }

  Future<String> _loadHtmlTemplate() async {
    final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    // 强制 macOS 与 iOS 使用相同的 Three.js 模板，避免 WKWebView 下本地 WebGL 白屏
    if (false && isMacOS) {
      final String templateMac = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <title>3D Cube Timer (WebGL)</title>
        <style>
          html, body { margin:0; padding:0; height:100%; background:#fff; overflow:hidden; }
          canvas { display:block; width:100%; height:100%; }
          #loading { position:absolute; top:50%; left:50%; transform:translate(-50%,-50%); color:#fff; }
        </style>
      </head>
      <body>
        <canvas id="glcanvas"></canvas>
        <div id="loading">Loading...</div>
        <script>
          const canvas = document.getElementById('glcanvas');
          const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
          // 初始化深度与裁剪设置，避免白屏
          gl.clearDepth(1.0);
          gl.enable(gl.DEPTH_TEST);
          gl.depthFunc(gl.LEQUAL);
          gl.disable(gl.CULL_FACE);
          let animationId = null;
          let isDragging = false;
          let prev = {x:0,y:0};
          let rotX = 0.3, rotY = -1.2, rotZ = 0.5;

          function resize() {
            // 使用 DPR 与边界尺寸，异常时回退 300x300，并输出尺寸日志
            const rect = canvas.getBoundingClientRect();
            const dpr = Math.max(1, (window.devicePixelRatio || 1));
            let w = Math.floor((rect.width || window.innerWidth || document.documentElement.clientWidth || 300) * dpr);
            let h = Math.floor((rect.height || window.innerHeight || document.documentElement.clientHeight || 300) * dpr);
            if (!w || !h || !isFinite(w) || !isFinite(h)) { w = 300; h = 300; }
            canvas.width = w;
            canvas.height = h;
            gl.viewport(0, 0, w, h);
            console.log('WKWebView canvas size(px):', w, h, 'dpr:', dpr);
          }
          window.addEventListener('resize', resize);

          const vsrc = `
            attribute vec3 aPos;
            attribute vec3 aCol;
            varying vec3 vCol;
            uniform mat4 uMVP;
            void main() {
              vCol = aCol;
              gl_Position = uMVP * vec4(aPos,1.0);
            }
          `;
          const fsrc = `
            precision mediump float;
            varying vec3 vCol;
            void main() {
              gl_FragColor = vec4(vCol,1.0);
            }
          `;
          function shader(type,src){
            const s = gl.createShader(type);
            gl.shaderSource(s,src);
            gl.compileShader(s);
            if(!gl.getShaderParameter(s, gl.COMPILE_STATUS)){
              console.log('shader compile error:', gl.getShaderInfoLog(s));
              return null;
            }
            return s;
          }
          const prog = gl.createProgram();
          const vs = shader(gl.VERTEX_SHADER, vsrc);
          const fs = shader(gl.FRAGMENT_SHADER, fsrc);
          if(!vs || !fs){
            console.log('shader compile failed, abort');
          } else {
            gl.attachShader(prog, vs);
            gl.attachShader(prog, fs);
            gl.linkProgram(prog);
            if(!gl.getProgramParameter(prog, gl.LINK_STATUS)){
              console.log('program link error:', gl.getProgramInfoLog(prog));
            } else {
              gl.useProgram(prog);
            }
          }

          // 立方体几何（面颜色区分）
          const positions = new Float32Array([
            // +X (25min) 右面
            1,-1,-1,  1, 1,-1,  1, 1, 1,
            1,-1,-1,  1, 1, 1,  1,-1, 1,

            // -X (10min) 左面
            -1,-1,-1,  -1,-1, 1,  -1, 1, 1,
            -1,-1,-1,  -1, 1, 1,  -1, 1,-1,

            // +Y (5min) 上面
            -1, 1,-1,   1, 1,-1,   1, 1, 1,
            -1, 1,-1,   1, 1, 1,  -1, 1, 1,

            // -Y (30min) 下面
            -1,-1,-1,  -1,-1, 1,   1,-1, 1,
            -1,-1,-1,   1,-1, 1,   1,-1,-1,

            // +Z (20min) 前面
            -1,-1, 1,   1,-1, 1,   1, 1, 1,
            -1,-1, 1,   1, 1, 1,  -1, 1, 1,

            // -Z (15min) 后面
            -1,-1,-1,  -1, 1,-1,   1, 1,-1,
            -1,-1,-1,   1, 1,-1,   1,-1,-1
          ]);
          function faceColor(r,g,b){ return [r,g,b,r,g,b,r,g,b, r,g,b,r,g,b,r,g,b]; }
          const colors = new Float32Array([
            ...faceColor(1,0,0), // +X 25
            ...faceColor(0.8,0.2,0.2), // -X 10
            ...faceColor(0,1,0), // +Y 5
            ...faceColor(0.2,0.8,0.2), // -Y 30
            ...faceColor(0,0,1), // +Z 20
            ...faceColor(0.2,0.2,0.8), // -Z 15
          ]);

          const posBuf = gl.createBuffer();
          gl.bindBuffer(gl.ARRAY_BUFFER,posBuf);
          gl.bufferData(gl.ARRAY_BUFFER,positions,gl.STATIC_DRAW);
          const colBuf = gl.createBuffer();
          gl.bindBuffer(gl.ARRAY_BUFFER,colBuf);
          gl.bufferData(gl.ARRAY_BUFFER,colors,gl.STATIC_DRAW);

          const aPos = gl.getAttribLocation(prog,'aPos');
          const aCol = gl.getAttribLocation(prog,'aCol');
          gl.bindBuffer(gl.ARRAY_BUFFER,posBuf);
          gl.vertexAttribPointer(aPos,3,gl.FLOAT,false,0,0);
          gl.enableVertexAttribArray(aPos);
          gl.bindBuffer(gl.ARRAY_BUFFER,colBuf);
          gl.vertexAttribPointer(aCol,3,gl.FLOAT,false,0,0);
          gl.enableVertexAttribArray(aCol);

          const uMVP = gl.getUniformLocation(prog,'uMVP');
          function matMul(a,b){
            const r = new Float32Array(16);
            for(let i=0;i<4;i++)for(let j=0;j<4;j++){let s=0;for(let k=0;k<4;k++)s+=a[i*4+k]*b[k*4+j];r[i*4+j]=s;}
            return r;
          }
          function rotXMat(a){const c=Math.cos(a),s=Math.sin(a);return new Float32Array([1,0,0,0, 0,c,-s,0, 0,s,c,0, 0,0,0,1]);}
          function rotYMat(a){const c=Math.cos(a),s=Math.sin(a);return new Float32Array([c,0,s,0, 0,1,0,0, -s,0,c,0, 0,0,0,1]);}
          function rotZMat(a){const c=Math.cos(a),s=Math.sin(a);return new Float32Array([c,-s,0,0, s,c,0,0, 0,0,1,0, 0,0,0,1]);}
          function translate(z){return new Float32Array([1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,z,1]);}
          function perspective(fov,aspect,near,far){
            const f=1/Math.tan(fov/2),nf=1/(near-far);
            return new Float32Array([f/aspect,0,0,0, 0,f,0,0, 0,0,(far+near)*nf,-1, 0,0,(2*far*near)*nf,0]);
          }

          function detectFace(){
            // 根据旋转后的法向量判断朝向相机的面
            const nx = Math.cos(rotY)*Math.cos(rotZ); // 粗略估计
            // 更稳定：比较 rotX/rotY 的范围
            const ax = Math.abs(rotX % (2*Math.PI));
            const ay = Math.abs(rotY % (2*Math.PI));
            // 近似判断，选离摄像机最近的面
            let duration = 25;
            let best = -Infinity;
            const candidates = [
              {dur:25, normal:[1,0,0]},
              {dur:10, normal:[-1,0,0]},
              {dur:5, normal:[0,1,0]},
              {dur:30, normal:[0,-1,0]},
              {dur:20, normal:[0,0,1]},
              {dur:15, normal:[0,0,-1]},
            ];
            function applyRot(v){
              // 仅使用 rotX/rotY/rotZ 简化旋转
              let x=v[0],y=v[1],z=v[2];
              // Y
              let cx=Math.cos(rotY),sx=Math.sin(rotY);
              let x1=cx*x+sx*z, y1=y, z1=-sx*x+cx*z;
              // X
              let cy=Math.cos(rotX),sy=Math.sin(rotX);
              let x2=x1, y2=cy*y1 - sy*z1, z2=sy*y1 + cy*z1;
              // Z
              let cz=Math.cos(rotZ),sz=Math.sin(rotZ);
              return [cz*x2 - sz*y2, sz*x2 + cz*y2, z2];
            }
            const camDir=[0,0,-1];
            for(const f of candidates){
              const wn=applyRot(f.normal);
              const dot=wn[0]*camDir[0]+wn[1]*camDir[1]+wn[2]*camDir[2];
              if(dot>best){ best=dot; duration=f.dur; }
            }
            if (best > 0.5 && window.Flutter) {
              window.Flutter.postMessage(JSON.stringify({type:'faceSelected', duration}));
            }
          }

          function draw(time){
            animationId = requestAnimationFrame(draw);
            const dw = gl.drawingBufferWidth || canvas.width || 300;
            const dh = gl.drawingBufferHeight || canvas.height || 300;
            const aspect = (dh > 0 ? (dw / dh) : 1);
            const proj = perspective(1.0, aspect, 0.1, 100.0);
            const view = translate(-5.0);
            const model = matMul(rotZMat(rotZ), matMul(rotYMat(rotY), rotXMat(rotX)));
            const mvp = matMul(proj, matMul(view, model));
            gl.uniformMatrix4fv(uMVP,false,mvp);
            gl.clearColor(1,1,1,1);
            gl.clear(gl.COLOR_BUFFER_BIT|gl.DEPTH_BUFFER_BIT);
            gl.enable(gl.DEPTH_TEST);
            gl.drawArrays(gl.TRIANGLES,0,positions.length/3);
          }

          function start(){ resize(); document.getElementById('loading').style.display='none'; draw(); }
          // 鼠标交互
          canvas.addEventListener('mousedown',e=>{isDragging=true; prev={x:e.clientX,y:e.clientY}; e.preventDefault();});
          canvas.addEventListener('mousemove',e=>{
            if(!isDragging) return;
            const dx=e.clientX-prev.x, dy=e.clientY-prev.y;
            rotY += dx*0.01; rotX += dy*0.01;
            prev={x:e.clientX,y:e.clientY};
            detectFace(); e.preventDefault();
          });
          canvas.addEventListener('mouseup',()=>{isDragging=false;});
          // 触摸
          canvas.addEventListener('touchstart',e=>{
            if(e.touches.length===1){isDragging=true; prev={x:e.touches[0].clientX,y:e.touches[0].clientY}; e.preventDefault();}
          },{passive:false});
          canvas.addEventListener('touchmove',e=>{
            if(!isDragging||e.touches.length!==1) return;
            const dx=e.touches[0].clientX-prev.x, dy=e.touches[0].clientY-prev.y;
            rotY += dx*0.01; rotX += dy*0.01;
            prev={x:e.touches[0].clientX,y:e.touches[0].clientY};
            detectFace(); e.preventDefault();
          },{passive:false});
          canvas.addEventListener('touchend',()=>{isDragging=false;}, {passive:false});

          // 清理
          window.addEventListener('beforeunload',()=>{ if(animationId) cancelAnimationFrame(animationId); });

          start();
        </script>
      </body>
      </html>
      ''';
      return templateMac;
    }
    // 非 macOS 继续使用现有 Three.js 模板
    final String template = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
        <meta name="apple-mobile-web-app-capable" content="yes">
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
        <title>3D Cube Timer</title>
        <style>
          body { 
            margin: 0; 
            padding: 0; 
            overflow: hidden; 
            background-color: ${isMacOS ? '#000000' : 'transparent'}; 
            touch-action: none;
            -webkit-touch-callout: none;
            -webkit-user-select: none;
            user-select: none;
            -webkit-tap-highlight-color: transparent;
            position: fixed;
            width: 100%;
            height: 100%;
          }
          canvas { 
            display: block; 
            width: 100%; 
            height: 100%; 
            touch-action: none;
            -webkit-tap-highlight-color: transparent;
            position: absolute;
            top: 0;
            left: 0;
          }
          #container { 
            width: 100%; 
            height: 100%; 
            position: absolute; 
            top: 0; 
            left: 0; 
            touch-action: none;
            -webkit-tap-highlight-color: transparent;
            overflow: hidden;
          }
          #loading { 
            position: absolute; 
            top: 50%; 
            left: 50%; 
            transform: translate(-50%, -50%); 
            color: white; 
            pointer-events: none;
            z-index: 100;
          }
        </style>
      </head>
      <body>
        <div id="container"></div>
        <div id="loading">Loading 3D Model...</div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/OBJLoader.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/MTLLoader.js"></script>
        <script>
          let scene, camera, renderer, cube;
          let isDragging = false;
          let previousMousePosition = { x: 0, y: 0 };
          let lastSelectedDuration = null;
          let lastDetectionTime = 0;
          const container = document.getElementById('container');
          const loading = document.getElementById('loading');
          
          function sendMessageToFlutter(message) {
            try {
              console.log('发送消息前:', message);
              const messageStr = JSON.stringify(message);
              
              if (window.Flutter) {
                window.Flutter.postMessage(messageStr);
                console.log('通过 Flutter.postMessage 发送消息:', messageStr);
              }
            } catch (error) {
              console.error('发送消息失败:', error);
            }
          }
          
          function init() {
            console.log('开始初始化Three.js...');
            try {
              scene = new THREE.Scene();
              camera = new THREE.PerspectiveCamera(75, container.clientWidth / container.clientHeight, 0.1, 1000);
              
              renderer = new THREE.WebGLRenderer({ 
                antialias: false,
                alpha: false, // 桌面使用不透明白底
                preserveDrawingBuffer: false,
                powerPreference: "low-power",
                failIfMajorPerformanceCaveat: false
              });
              renderer.setSize(window.innerWidth, window.innerHeight);
              renderer.setClearColor(0xffffff, 1);
              renderer.domElement.style.touchAction = 'none';
              
              // 设置像素比以优化性能（在移动端固定为1以降低GPU/缓冲压力）
              renderer.setPixelRatio(1);
              
              container.appendChild(renderer.domElement);
              
              // 添加触摸事件监听器
              const touchHandler = {
                handleStart: function(event) {
                  console.log('触摸开始');
                  if (event.touches.length === 1) {
                    isDragging = true;
                    previousMousePosition = {
                      x: event.touches[0].clientX,
                      y: event.touches[0].clientY
                    };
                    event.preventDefault();
                    event.stopPropagation();
                  }
                },
                handleMove: function(event) {
                  if (!isDragging || event.touches.length !== 1) return;
                  console.log('触摸移动');
                  
                  const deltaMove = {
                    x: event.touches[0].clientX - previousMousePosition.x,
                    y: event.touches[0].clientY - previousMousePosition.y
                  };
                  
                  if (cube) {
                    cube.rotation.y += deltaMove.x * 0.01;
                    cube.rotation.x += deltaMove.y * 0.01;
                    console.log('旋转角度:', cube.rotation.x, cube.rotation.y);
                  }
                  
                  previousMousePosition = {
                    x: event.touches[0].clientX,
                    y: event.touches[0].clientY
                  };
                  
                  detectCurrentFace();
                  event.preventDefault();
                  event.stopPropagation();
                },
                handleEnd: function(event) {
                  console.log('触摸结束');
                  isDragging = false;
                  event.preventDefault();
                  event.stopPropagation();
                }
              };
              
              // 添加事件监听器
              container.addEventListener('touchstart', touchHandler.handleStart, { passive: false });
              container.addEventListener('touchmove', touchHandler.handleMove, { passive: false });
              container.addEventListener('touchend', touchHandler.handleEnd, { passive: false });
              container.addEventListener('touchcancel', touchHandler.handleEnd, { passive: false });
              
              // 桌面端鼠标事件（macOS）
              const mouseHandler = {
                handleDown: function(event) {
                  isDragging = true;
                  previousMousePosition = { x: event.clientX, y: event.clientY };
                  event.preventDefault();
                  event.stopPropagation();
                },
                handleMove: function(event) {
                  if (!isDragging) return;
                  const deltaMove = {
                    x: event.clientX - previousMousePosition.x,
                    y: event.clientY - previousMousePosition.y
                  };
                  if (cube) {
                    cube.rotation.y += deltaMove.x * 0.01;
                    cube.rotation.x += deltaMove.y * 0.01;
                  }
                  previousMousePosition = { x: event.clientX, y: event.clientY };
                  detectCurrentFace();
                  event.preventDefault();
                  event.stopPropagation();
                },
                handleUp: function(event) {
                  isDragging = false;
                  event.preventDefault();
                  event.stopPropagation();
                }
              };
              container.addEventListener('mousedown', mouseHandler.handleDown, { passive: false });
              container.addEventListener('mousemove', mouseHandler.handleMove, { passive: false });
              container.addEventListener('mouseup', mouseHandler.handleUp, { passive: false });
              
              console.log('开始加载模型文件...');
              const mtlLoader = new THREE.MTLLoader();
              const mtlContent = '$_mtlContent';
              const mtlText = atob(mtlContent);
              console.log('MTL文件解码成功');
              
              const mtlMaterials = mtlLoader.parse(mtlText);
              mtlMaterials.preload();
              console.log('MTL文件解析成功');
              
              const objLoader = new THREE.OBJLoader();
              objLoader.setMaterials(mtlMaterials);
              const objContent = '$_objContent';
              const objText = atob(objContent);
              console.log('OBJ文件解码成功');
              
              const object = objLoader.parse(objText);
              console.log('OBJ文件解析成功');
              
              cube = object;
              scene.add(cube);
              
              cube.position.set(0, 0, 0);
              cube.scale.set(1.5, 1.5, 1.5);
              
              // 设置初始旋转角度，使25分钟的面朝前
              // 25分钟的面是X轴正方向(1,0,0)，需要将其朝向相机
              cube.rotation.y = -Math.PI / 2; // 绕Y轴旋转90度，使X轴正方向朝前
              cube.rotation.x = 0;
              cube.rotation.z = Math.PI / 6;
              
              camera.position.z = 4; // 相机在Z轴正方向，可以直接看到X轴正方向的面
              
              const ambientLight = new THREE.AmbientLight(0xffffff, 0.5);
              scene.add(ambientLight);
              
              const directionalLight = new THREE.DirectionalLight(0xffffff, 0.5);
              directionalLight.position.set(0, 1, 0);
              scene.add(directionalLight);
              
              animate();
              
              window.addEventListener('resize', onWindowResize);
              
              // 初始化完成后检测当前面
              setTimeout(() => {
                detectCurrentFace();
              }, 100);
              
              loading.style.display = 'none';
              console.log('Three.js初始化完成');
            } catch (error) {
              console.error('Three.js初始化失败:', error);
              loading.textContent = '加载失败: ' + error.message;
            }
          }
          
          function onWindowResize() {
            const w = window.innerWidth || document.documentElement.clientWidth || container.clientWidth || 300;
            const h = window.innerHeight || document.documentElement.clientHeight || container.clientHeight || 300;
            camera.aspect = w / Math.max(1, h);
            camera.updateProjectionMatrix();
            renderer.setSize(w, h);
          }
          
          let animationId;
          let lastFrameTime = 0;
          const targetFPS = 15; // 降低帧率以减少缓冲压力
          const frameDuration = 1000 / targetFPS;
          function animate(time) {
            animationId = requestAnimationFrame(animate);
            try {
              if (!lastFrameTime || (time - lastFrameTime) >= frameDuration) {
                lastFrameTime = time;
                if (renderer && scene && camera) {
                  renderer.render(scene, camera);
                }
              }
            } catch (error) {
              console.error('渲染错误:', error);
              // 停止动画循环以防止错误累积
              if (animationId) {
                cancelAnimationFrame(animationId);
              }
            }
          }
          
          // 页面卸载时清理资源
          window.addEventListener('beforeunload', function() {
            if (animationId) {
              cancelAnimationFrame(animationId);
            }
            if (renderer) {
              renderer.dispose();
            }
          });
          
          function detectCurrentFace() {
            if (!cube) return;
            
            const faces = [
              { duration: 25, normal: new THREE.Vector3(1, 0, 0) },    // OK 前面(E面) 25分钟 X轴正方向
              { duration: 5, normal: new THREE.Vector3(0, 1, 0) },     // OK 上面(A面) 5分钟 Z轴正方向
              { duration: 15, normal: new THREE.Vector3(0, 0, 1) },    // 左面(C面) 15分钟 Y轴负方向
              { duration: 30, normal: new THREE.Vector3(0, -1, 0) },   // 下面(F面) 30分钟 Z轴负方向
              { duration: 20, normal: new THREE.Vector3(0, 0, -1) },    // 右面(D面) 20分钟 Y轴正方向
              { duration: 10, normal: new THREE.Vector3(-1, 0, 0) }    // OK 后面(B面) 10分钟 X轴负方向
            ];
            
            // 获取立方体的世界矩阵
            const worldMatrix = new THREE.Matrix4();
            cube.updateMatrixWorld();
            worldMatrix.copy(cube.matrixWorld);
            
            // 获取相机方向
            const cameraDirection = new THREE.Vector3();
            camera.getWorldDirection(cameraDirection);
            cameraDirection.negate(); // 反转相机方向，因为我们需要从相机指向物体的方向
            
            let maxDot = -Infinity;
            let selectedFace = null;
            
            for (const face of faces) {
              // 将法向量转换到世界空间
              const worldNormal = face.normal.clone();
              worldNormal.applyMatrix4(worldMatrix);
              worldNormal.normalize();
              
              // 计算点积
              const dot = worldNormal.dot(cameraDirection);
              console.log('面 ' + face.duration + ' 分钟的点积: ' + dot);
              
              if (dot > maxDot) {
                maxDot = dot;
                selectedFace = face;
              }
            }
            
            if (selectedFace && maxDot > 0.5) { // 降低阈值到0.5，提高检测灵敏度
              const currentTime = Date.now();
              // 防抖：如果是同一个面且距离上次检测时间小于500ms，则不重复发送
              if (selectedFace.duration !== lastSelectedDuration || currentTime - lastDetectionTime > 500) {
                console.log('检测到面: ' + selectedFace.duration + ' 分钟, 相似度: ' + maxDot);
                try {
                  const message = {
                    type: 'faceSelected',
                    duration: selectedFace.duration
                  };
                  console.log('准备发送消息:', message);
                  sendMessageToFlutter(message);
                  lastSelectedDuration = selectedFace.duration;
                  lastDetectionTime = currentTime;
                } catch (error) {
                  console.error('发送消息失败:', error);
                }
              }
            }
          }
        </script>
      </body>
      </html>
    ''';
    return template;
  }

  void _initializeThreeJS() {
    if (_isWebViewLoaded && _controller != null) {
      if (!kIsWeb) {
        final js = '''
          (function(){
            try{
              if (!window.isInitialized) {
                if (typeof start === 'function') { start(); }
                else if (typeof init === 'function') { init(); }
                window.isInitialized = true;
              }
            }catch(e){
              console.log('init error:', (e && e.message) ? e.message : e);
            }
          })();
        ''';
        _controller!.runJavaScript(js);
      }
    }
  }

  void _onMessageReceived(String message) {
    try {
      // debugPrint('收到了来自JavaScript的消息: $message');
      final data = jsonDecode(message);
      if (data['type'] == 'rotation') {
        final rotation = data['rotation'] as Map<String, dynamic>;
        final x = rotation['x'] as double;
        final y = rotation['y'] as double;
        final z = rotation['z'] as double;
        widget.onRotationChanged?.call(x, y, z);
      } else if (data['type'] == 'select' || data['type'] == 'faceSelected') {
        final duration = data['duration'] as int;
        debugPrint('选择了 $duration 分钟的页面');
        widget.onDurationSelected?.call(duration);
      }
    } catch (e) {
      debugPrint('解析消息失败: $e, 原始消息: $message');
    }
  }

  Widget _buildFallbackUI() {
    // 降级方案：简单的时间选择按钮（自适应父布局高度，避免溢出）
    final durations = [5, 10, 15, 20, 25, 30];
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择计时时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: durations
                  .map(
                    (duration) => ElevatedButton(
                      onPressed: () => widget.onDurationSelected?.call(duration),
                      child: Text('$duration 分钟'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web 平台使用降级方案
      return _buildFallbackUI();
    }


    if (_errorMessage != null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            const Text('使用简化界面:', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            _buildFallbackUI(),
          ],
        ),
      );
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.white,
          child: WebViewWidget(controller: _controller!),
        ),
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    try {
      if (_controller == null) return;
      if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
        _controller!.runJavaScript('if (window.animationId){ cancelAnimationFrame(window.animationId); window.animationId = null; }');
      } else if (state == AppLifecycleState.resumed) {
        _controller!.runJavaScript('if (!window.animationId && typeof animate==="function"){ window.animationId = requestAnimationFrame(animate); }');
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // 在销毁前通知 WebView 取消动画帧，避免后台持续渲染占用缓冲
    try {
      _controller?.runJavaScript('if (window.animationId){ cancelAnimationFrame(window.animationId); }');
    } catch (_) {}
    super.dispose();
  }
}
