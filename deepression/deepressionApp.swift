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
  private var locationManager: LocationManager? = nil
  private var overallDataManager: OverallDataManager? = nil
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // firebase 시작
    FirebaseApp.configure()
    
    locationManager = LocationManager.shared
    guard let locationManager = locationManager else {
      return false
    }
    overallDataManager = OverallDataManager.shared
    guard let overallDataManager = overallDataManager else {
      return false
    }
    
    // 위치정보 권한 요청
    locationManager.requestLocationPermission()
    
    // 네트워크 모니터링 시작
    NetworkManager.shared.startMonitoring()
    
    // 백그라운드 fretch: refresh 작업 등록
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.sbigstar.deepression.refresh", using: nil) { task in
      self.handleAppRefresh(task: task as! BGAppRefreshTask)
    }
    
    // 백그라운드 스케줄 작업을 예약
    scheduleAppRefresh()
    return true
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
    // 백그라운드 스케줄 작업을 예약
    scheduleAppRefresh()
  }
  
  private func handleAppRefresh(task: BGAppRefreshTask) {
    print("background fetch 실행")
    guard let overallDataManager = overallDataManager else {
      return
    }
    
    // 바로 다음 백그라운드 스케줄 작업을 예약
    scheduleAppRefresh()
    
    // 작업이 완료되지 않으면 중단하기
    task.expirationHandler = {
      task.setTaskCompleted(success: false)
    }
    
    DispatchQueue.global(qos: .background).async {
      print("사용자 데이터 업데이트 시작")
      // 사용자 데이터 업데이트 실행, 중복 실행 시작 가능
      overallDataManager.startDataUpdating()
      
      print("작업 완료 처리")
      // 작업 완료 처리 (여기서는 단순히 성공으로 설정, 실제 구현에서는 적절한 완료 로직 필요)
      task.setTaskCompleted(success: true)
    }
  }
  
  private func scheduleAppRefresh() {
    // 참고
    // 여러 번 스케줄 요청이 제출되더라도, 실제로 스케줄된 작업은 최신 작업 하나만 유지된다.
    let request = BGAppRefreshTaskRequest(identifier: "com.sbigstar.deepression.refresh")
    
    // 최소 1분 이후에 스케줄이 되도록 설정 (배터리 절약)
    request.earliestBeginDate = Date().addingTimeInterval(1 * 60)
    
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
