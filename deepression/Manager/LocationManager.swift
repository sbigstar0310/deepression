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
  private var locationManager = CLLocationManager()
  private let locationUpdateManager = LocationUpdateManager()
  
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
    guard CLLocationManager.locationServicesEnabled() else {
      print("CLLocationManagager: 위치 정보를 받아올 수 없음.")
      return
    }
    
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
}

// MARK: - CLLocationMangerDelegate에 대한 코드
extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let cllocation = locations.last else {
      print("Can't get location")
      return
    }
    
    let location = Location(updatedDate: Date(), latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude)
    
    
    locationUpdateManager.UpdateLocationToFireBase(location: location)
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

// MARK: - CoreLocation Error extension


