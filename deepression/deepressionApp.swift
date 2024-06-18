//
//  deepressionApp.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import SwiftUI
import CoreLocation
import BackgroundTasks
import FirebaseCore
import FirebaseAuth

class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // firebase 시작
    FirebaseApp.configure()
    
    // 백그라운드 fretch: refresh 작업 등록
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.sbigstar.deepression.refresh", using: nil) { task in
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }
    
    // 위치정보 권한 요청
    var locationManager = LocationManager()
    locationManager.requestLocationPermission()
    
    scheduleAppRefresh()
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    scheduleAppRefresh()
  }
  
  private func handleAppRefresh(task: BGAppRefreshTask) {
    scheduleAppRefresh()
    
    let queue = OperationQueue()
    queue.maxConcurrentOperationCount = 1
    
    let operation = BlockOperation {
      var locationManager = LocationManager()
      locationManager.requestLocation()
    }
    
    task.expirationHandler = {
      queue.cancelAllOperations()
    }
    
    // Inform the system that the background task is complete
    // when the operation completes.
    operation.completionBlock = {
      task.setTaskCompleted(success: !operation.isCancelled)
    }
    
    // Start the operation.
    queue.addOperation(operation)
  }
  
  private func scheduleAppRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.sbigstar.deepression.refresh")
    
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      print("Unable to submit task: \(error.localizedDescription)")
    }
  }
}

@main
struct deepressionApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
