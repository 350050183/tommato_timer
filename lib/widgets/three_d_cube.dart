import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ThreeDCube extends StatefulWidget {
  final Function(int)? onDurationSelected;

  const ThreeDCube({
    super.key,
    this.onDurationSelected,
  });

  @override
  State<ThreeDCube> createState() => _ThreeDCubeState();
}

class _ThreeDCubeState extends State<ThreeDCube> {
  WebViewController? _controller;
  bool _isWebViewLoaded = false;
  String? _objContent;
  String? _mtlContent;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _loadModelFiles();
    }
  }

  Future<void> _loadModelFiles() async {
    try {
      debugPrint('开始加载模型文件...');
      final objBytes = await rootBundle.load('assets/cube/tomato-timer.obj');
      final mtlBytes = await rootBundle.load('assets/cube/tomato-timer.mtl');

      _objContent = base64Encode(objBytes.buffer.asUint8List());
      _mtlContent = base64Encode(mtlBytes.buffer.asUint8List());

      debugPrint(
        '模型文件加载成功，OBJ大小: ${_objContent?.length}, MTL大小: ${_mtlContent?.length}',
      );
      _initializeWebView();
    } catch (e) {
      debugPrint('加载模型文件失败: $e');
      setState(() {
        _errorMessage = '加载模型文件失败: $e';
      });
    }
  }

  Future<void> _initializeWebView() async {
    if (_objContent == null || _mtlContent == null) {
      debugPrint('模型文件内容为空');
      return;
    }

    try {
      debugPrint('开始初始化WebView...');
      final String htmlContent = await _loadHtmlTemplate();
      debugPrint('HTML模板加载成功');

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..enableZoom(false)
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: (JavaScriptMessage message) {
            try {
              debugPrint('收到JavaScript消息: ${message.message}');
              _onMessageReceived(message.message);
            } catch (e) {
              debugPrint('处理JavaScript消息失败: $e');
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              debugPrint('页面加载完成: $url');
              setState(() {
                _isWebViewLoaded = true;
              });
              _initializeThreeJS();
            },
            onWebResourceError: (WebResourceError error) {
              debugPrint('Web资源错误: ${error.description}');
              setState(() {
                _errorMessage = 'Web资源错误: ${error.description}';
              });
            },
          ),
        )
        ..loadHtmlString(htmlContent);

      setState(() {
        _controller = controller;
      });
      debugPrint('WebView初始化完成');
    } catch (e) {
      debugPrint('初始化WebView失败: $e');
      setState(() {
        _errorMessage = '初始化WebView失败: $e';
      });
    }
  }

  Future<String> _loadHtmlTemplate() async {
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
            background-color: transparent; 
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
          const container = document.getElementById('container');
          const loading = document.getElementById('loading');
          
          function sendMessageToFlutter(message) {
            try {
              console.log('发送消息前:', message);
              const messageData = {
                type: 'faceSelected',
                duration: message.duration
              };
              
              console.log('格式化后的消息:', messageData);
              const messageStr = JSON.stringify(messageData);
              
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
                antialias: true, 
                alpha: true,
                preserveDrawingBuffer: true
              });
              renderer.setSize(container.clientWidth, container.clientHeight);
              renderer.setClearColor(0x000000, 0);
              renderer.domElement.style.touchAction = 'none';
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
              
              loading.style.display = 'none';
              console.log('Three.js初始化完成');
            } catch (error) {
              console.error('Three.js初始化失败:', error);
              loading.textContent = '加载失败: ' + error.message;
            }
          }
          
          function onWindowResize() {
            camera.aspect = container.clientWidth / container.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(container.clientWidth, container.clientHeight);
          }
          
          function animate() {
            requestAnimationFrame(animate);
            renderer.render(scene, camera);
          }
          
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
            
            if (selectedFace && maxDot > 0.7) { // 阈值保持0.7，确保检测的灵敏度
              console.log('检测到面: ' + selectedFace.duration + ' 分钟, 相似度: ' + maxDot);
              try {
                const message = {
                  type: 'faceSelected',
                  duration: selectedFace.duration
                };
                console.log('准备发送消息:', message);
                sendMessageToFlutter(message);
              } catch (error) {
                console.error('发送消息失败:', error);
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
        _controller!.runJavaScript('''
          if (!window.isInitialized) {
            init();
            window.isInitialized = true;
          }
        ''');
      }
    }
  }

  void _onMessageReceived(String message) {
    try {
      final data = jsonDecode(message);
      if (data['type'] == 'faceSelected') {
        final duration = data['duration'] as int;
        debugPrint('选择了 $duration 分钟的页面');
        widget.onDurationSelected?.call(duration);
      }
    } catch (e) {
      debugPrint('解析消息失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // Web 平台使用占位符
      return const SizedBox(
        height: 400,
        child: Center(child: Text('3D 立方体在 Web 平台暂不可用')),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SizedBox(
      height: 400,
      child: WebViewWidget(controller: _controller!),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
