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
  @Published var authorizationStatus: CLAuthorizationStatus?
  
  private let locationManager = CLLocationManager()
  private let wifiManager = WifiManager.shared
  private let fbUpdateManager = FBUpdateManager.shared
  
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
  
  func startUpdatingLocation() {
    guard CLLocationManager.headingAvailable() else {
      print("CLLocationManagager: 헤딩(방향) 정보를 사용할 수 없음.")
      return
    }
    
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
  
  private var lock = false
}

// MARK: - CLLocationMangerDelegate에 대한 코드
extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    // print("위치 업데이트 호출 됨 \(msDateFormatter.string(from: Date()))")
    
    guard let cllocation = locations.last else {
      print("Can't get location")
      return
    }
    
    Task {
      guard !lock else {
        // 아직 업데이트 중
        return
      }
      
      lock = true
      
      let wifi = await wifiManager.getCurrentWiFiInfo()
      let location = Location(updatedDate: Date(), latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude)
      await fbUpdateManager.updateWifiToFirebase(wifi: wifi)
      await fbUpdateManager.updateLocationToFirebase(location: location)
      
      lock = false
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
    // 오류 처리
    print("Location 오류:", error.localizedDescription)
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    // 권한 변경시
    print("권한이 변경되었습니다:  \(manager.authorizationStatus)")
    switch manager.authorizationStatus {
    case .authorizedWhenInUse:
      print("authorizedWhenInUse")
      authorizationStatus = .authorizedWhenInUse
    case .authorizedAlways:
      print("authorizedAlways")
      authorizationStatus = .authorizedAlways
    case .notDetermined:
      print("notDetermined")
      authorizationStatus = .notDetermined
    case .denied:
      print("denied")
      authorizationStatus = .denied
    case .restricted:
      print("restricted")
      authorizationStatus = .restricted
    default:
      break
    }
  }
}

// MARK: - CoreLocation Error extension


