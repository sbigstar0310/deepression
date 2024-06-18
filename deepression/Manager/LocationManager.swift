//
//  LocationManager.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject {
  private var locationManager = CLLocationManager()
  private let fbRealtimeDataManager = FBRealtimeDataManager.shared
  private let userManager = UserManager.shared
  
  override init() {
    super.init()
    // delegate 지정
    locationManager.delegate = self
    
    // 최대한 정확한 위치 정보 받아오기
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // 앱이 background에서도 위치 정보를 받아올 수 있는 옵션
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
  }
  
  
  func startUpdateLocationInTime() {
    // 주어진 시간(sec)마다 위치 정보 업데이트
    let sec: Double = 15 * 60 // 15분 마다 서버에 업로드
    var timer = Timer.scheduledTimer(timeInterval: sec, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: true)
    RunLoop.current.add(timer, forMode: .default)
    
    // 사용자의 장거리 위치 변화 감지
    startSignificantChangeUpdates()
  }
  
  @objc func requestLocation() {
    // 사용자 현재 위치 요청
    locationManager.requestLocation()
  }
  
  func startSignificantChangeUpdates() {
    // 사용자의 장거리 이동 감지 (수 백에서 수 킬로미터)
    // 앱이 종료된 상황에서도 감지 가능
    if CLLocationManager.significantLocationChangeMonitoringAvailable() {
          locationManager.startMonitoringSignificantLocationChanges()
      }
  }

  func stopSignificantChangeUpdates() {
      locationManager.stopMonitoringSignificantLocationChanges()
  }

  func requestLocationPermission() {
    // 앱 사용 중 사용 권한 요청
    locationManager.requestWhenInUseAuthorization()
    // 항상 사용 권한 요청
    locationManager.requestAlwaysAuthorization()
  }
}

// MARK: - CLLocationMangerDelegate에 대한 코드
extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // 앱의 상태 확인
    let appState = UIApplication.shared.applicationState
    
    switch appState {
    case .active:
      print("포그라운드에서 위치 업데이트")
    case .background:
      print("백그라운드에서 위치 업데이트")
    default:
      print("기타 상태에서 위치 업데이트")
    }
    
    print("시간: ", Date())
    
    if let location = locations.last {
      print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
      
      print("서버에 업로드")
      guard let user = userManager.user else {
        print("서버 업로드 실패: 유저가 로그인 상태가 아닙니다.")
        return
      }
      
      fbRealtimeDataManager.addUserData(user: user, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    // 오류 처리
    print("Location error:", error.localizedDescription)
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // 권한 변경시
    print("권한이 변경되었습니다:  \(manager.authorizationStatus)")
  }
}
