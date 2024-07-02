//
//  OverallDataManager.swift
//  deepression
//
//  Created by 성대규 on 6/27/24.
//

import Foundation

class OverallDataManager {
  static let shared = OverallDataManager()
  private init() {}
  
  private let locationManager = LocationManager.shared
  private let motionManager = MotionManager.shared
  private let fbRealtimeDataManager = FBRealtimeDataManager()
  private let userDefaultManager = UserDefaultManager()
  
  func startDataUpdating() {
    locationManager.startUpdatingLocation()
    locationManager.startSignificantChangeUpdates()
    motionManager.startMotionUpdates()
  }
  
  func stopDataUpdating() {
    locationManager.stopUpdatingLocation()
    locationManager.stopSignificantChangeUpdates()
    motionManager.stopMotionUpdates()
  }
  
  func deleteAllData(user: User) {
    // 기존 업데이트 중지
    stopDataUpdating()
    // 서버 데이터 삭제
    fbRealtimeDataManager.deleteUserData(user: user)
    // 디바이스 데이터 삭제
    userDefaultManager.clearAllData()
  }
}
