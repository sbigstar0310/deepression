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
  private let userDefaultManager = UserDefaultManager()
  // 업데이트 시에 최근 업데이트 시각이 갱신될 때까지 잠금되는 Lock (잦은 업데이트 방지)
  private var lock = false
  // 업데이트를 진행할 시간 간격 (단위: 분)
  private let minIntervalMinute = 15
  
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
  
  func isUpdateIntervalValid(intervalMinute: Int, updateDate: Date) -> Bool {
    let lastUpdatedDate = userDefaultManager.getLastUpdateDate() ?? Date(timeIntervalSince1970: 0)
    
    // 마지막 업데이트 날짜로부터 업데이트 간격(분) 구하기
    guard let differenceInMinutes = Calendar.current.dateComponents([.minute], from: lastUpdatedDate, to: updateDate).minute else {
      print("오류: 시간 차이가 nil입니다.")
      return false
    }
    
    if differenceInMinutes < 0 {
      // 과거의 업데이트 (오프라인 싱크)의 경우에는 업데이트 허용
      return true
    } else if 0 <= differenceInMinutes && differenceInMinutes < intervalMinute {
      // 시간 차이가 intervalMinute 이내인 경우: 업데이트 하지 않기
      return false
    } else {
      // 시간 차이가 intervalMinute 이상인 경우: 업데이트 허용
      return true
    }
  }
}

// MARK: - CLLocationMangerDelegate에 대한 코드
extension LocationManager: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    print("위치 업데이트 호출 됨 \(msDateFormatter.string(from: Date()))")
    
    guard let cllocation = locations.last else {
      print("Can't get location")
      return
    }
    
    guard !lock else {
      // 아직 업데이트 중
      print("- 아직 업데이트 중")
      return
    }
    
    lock = true
    
    Task {
      let updatedDate = Date()
      
      // 업데이트 간격의 유효성을 검증
      guard isUpdateIntervalValid(intervalMinute: 15, updateDate: updatedDate) else {
        print("- 업데이트 간격에 도달하지 못함")
        lock = false
        return
      }
      
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


