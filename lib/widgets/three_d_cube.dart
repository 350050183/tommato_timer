import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..enableZoom(false)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.120 Mobile Safari/537.36')
        ..addJavaScriptChannel(
          'Flutter',
          onMessageReceived: (JavaScriptMessage message) {
            try {
              // debugPrint('收到JavaScript消息: ${message.message}');
              _onMessageReceived(message.message);
            } catch (e) {
              // debugPrint('处理JavaScript消息失败: $e');
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) {
              // debugPrint('页面加载完成: $url');
              setState(() {
                _isWebViewLoaded = true;
              });
              _initializeThreeJS();
            },
            onWebResourceError: (WebResourceError error) {
              // debugPrint('Web资源错误: ${error.description}');
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
      // debugPrint('WebView初始化完成');
    } catch (e) {
      // debugPrint('初始化WebView失败: $e');
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
                antialias: false, // 关闭抗锯齿以减少GPU负载
                alpha: true,
                preserveDrawingBuffer: false, // 关闭缓冲区保留以减少内存使用
                powerPreference: "low-power", // 使用低功耗模式
                failIfMajorPerformanceCaveat: true // 如果性能不足则失败
              });
              renderer.setSize(container.clientWidth, container.clientHeight);
              renderer.setClearColor(0x000000, 0);
              renderer.domElement.style.touchAction = 'none';
              
              // 设置像素比以优化性能
              renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
              
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
            camera.aspect = container.clientWidth / container.clientHeight;
            camera.updateProjectionMatrix();
            renderer.setSize(container.clientWidth, container.clientHeight);
          }
          
          let animationId;
          function animate() {
            animationId = requestAnimationFrame(animate);
            try {
              if (renderer && scene && camera) {
                renderer.render(scene, camera);
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
    // 降级方案：简单的时间选择按钮
    final durations = [5, 10, 15, 20, 25, 30];
    return SizedBox(
      height: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('选择计时时间', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: durations.map((duration) => 
              ElevatedButton(
                onPressed: () => widget.onDurationSelected?.call(duration),
                child: Text('$duration 分钟'),
              )
            ).toList(),
          ),
        ],
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
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          const Text('使用简化界面:', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          _buildFallbackUI(),
        ],
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
