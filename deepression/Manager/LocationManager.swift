//
//  LocationManager.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, ObservableObject {
  @Published var lastUpdatedDate: Date = Date(timeIntervalSince1970: 0)
  
  private var locationManager = CLLocationManager()
  private let fbRealtimeDataManager = FBRealtimeDataManager.shared
  private let userManager = UserManager.shared
  private var timer: Timer?
  
  static let shared = LocationManager()
  override private init() {
    super.init()
    // delegate 지정
    locationManager.delegate = self
    
    // 최대한 정확한 위치 정보 받아오기
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    
    // 앱이 background에서도 위치 정보를 받아올 수 있는 옵션
    locationManager.allowsBackgroundLocationUpdates = true
    locationManager.pausesLocationUpdatesAutomatically = false
  }
  
  
  func startUpdateLocationWithTimer() {
    // 주어진 시간(sec)마다 위치 정보 업데이트
    let sec: Double = 15 * 60 // 15분 마다 서버에 업로드
    timer = Timer.scheduledTimer(timeInterval: sec, target: self, selector: #selector(requestLocation), userInfo: nil, repeats: true)
    RunLoop.current.add(timer!, forMode: .default)
    
    // 사용자의 장거리 위치 변화 감지
    startSignificantChangeUpdates()
  }
  
  @objc func requestLocation() {
    // 사용자 현재 위치 요청
    locationManager.requestLocation()
  }
  
  func stopUpdateLocationWithTimer() {
    timer?.invalidate()
    timer = nil
  }
  
  func startUpdatingLocation() {
    locationManager.startUpdatingLocation()
  }
  
  func stopUpdatingLocation() {
    locationManager.stopUpdatingLocation()
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
    let calendar = Calendar.current
    let currentDate = Date()
    
    // 마지막 업데이트 날짜로부터 업데이트 간격 구하기
    guard let differenceInMinutes = Calendar.current.dateComponents([.minute], from: lastUpdatedDate, to: currentDate).minute else {
      print("오류: 시간 차이가 nil입니다.")
      return
    }
    
    if differenceInMinutes < 15 {
      // 시간 차이가 15분 이내인 경우: Update Pass
      return
    }
    
    // 앱의 상태 확인
    let appState = UIApplication.shared.applicationState
    
    switch appState {
    case .active:
      print("환경: Foreground")
    case .background:
      print("환경: Background")
    default:
      print("환경: 기타")
    }
    
    print("업데이트 시간: \(fbDateFormatter.string(from: currentDate))")
    
    if let location = locations.last {
      print("위도: \(location.coordinate.latitude), 경도: \(location.coordinate.longitude)")
      
      guard let user = userManager.user else {
        print("서버 업로드 실패: 유저가 로그인 상태가 아닙니다.")
        return
      }
      
      // 마지막 업데이트 날짜 최신화
      lastUpdatedDate = currentDate
      
      // 서버에 위치 정보 업로드
      fbRealtimeDataManager.addUserData(user: user, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
    
    print("---------------------------------------------------------")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    // 오류 처리
    print("Location 오류:", error.localizedDescription)
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // 권한 변경시
    print("권한이 변경되었습니다:  \(manager.authorizationStatus)")
  }
}
