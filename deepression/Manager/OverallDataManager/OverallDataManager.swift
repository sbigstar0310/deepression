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
}
