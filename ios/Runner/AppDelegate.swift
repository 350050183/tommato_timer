import Flutter
import UIKit
import workmanager
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // 配置音频会话
    do {
      let audioSession = AVAudioSession.sharedInstance()
      try audioSession.setCategory(
        .playback,
        mode: .default,
        options: [.mixWithOthers, .duckOthers]
      )
      try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
      print("Audio session configured successfully")
    } catch {
      print("Failed to set audio session category: \(error)")
    }
    
    // 初始化 Workmanager
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }
    
    // 注册后台任务
    WorkmanagerPlugin.registerTask(withIdentifier: "tickTimer")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func applicationDidEnterBackground(_ application: UIApplication) {
    // 应用进入后台时，请求额外的后台执行时间
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    backgroundTask = application.beginBackgroundTask {
      application.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
    
    // 在这里可以添加需要在后台执行的任务
    DispatchQueue.global().async {
      // 执行后台任务
      application.endBackgroundTask(backgroundTask)
      backgroundTask = .invalid
    }
  }
}
