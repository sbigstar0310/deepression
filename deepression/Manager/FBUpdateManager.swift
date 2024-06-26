//
//  LocationUpdateManager.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//
//  Firebase realtime database로 정보들(Location, Wifi)을 업데이트하는 매니저.

import Foundation
import UIKit

actor FBUpdateManager {
  private let fbRealtimeDataManager = FBRealtimeDataManager()
  private let userManager = UserManager.shared
  private let userDefaultManager = UserDefaultManager()
  private let networkManager = NetworkManager.shared
  // 업데이트를 진행할 시간 간격 (단위: 분)
  private let minIntervalMinute = 15
  
  static let shared = FBUpdateManager()
  private init() {}
  
  func isNetworkValid() -> Bool {
    // 네트워크 상태를 점검
    networkManager.getNetworkIsConnected()
  }
  
  func isUserLoginValid() -> Bool {
    // 유저의 로그인 상태를 점검
    guard let _ = userManager.user else {
      return false
    }
    return true
  }
  
  func doOfflineSync(location: Location) {
    // 업데이트에 실패한 경우 (네트워크 불량, 유저 로그인 안함, ...)
    // 디바이스(UserDefault)에 위치 정보 저장, 추후에 서버로 업데이트
    userDefaultManager.addLocation(location: location)
    
    // 시간 간격 보장을 위해 업데이트 시간은 최신화 (기존보다 최신의 날짜인 경우로)
    let lastUpdatedDate = userDefaultManager.getLastUpdateDate() ?? Date(timeIntervalSince1970: 0)
    userDefaultManager.setLastUpdateDate(date: max(lastUpdatedDate, location.updatedDate))
  }
  
  func updateWifiToFirebase(wifi: Wifi) async {
    // 네트워크 상태 확인
    guard isNetworkValid() else {
      return
    }
    
    // 업데이트 시각
    let updatedDate = wifi.updatedDate
    
    // 유저 로그인 상태 확인
    guard isUserLoginValid(), let user = userManager.user else {
      return
    }
    
    do {
      try await fbRealtimeDataManager.addWifiData(user: user, wifi: wifi)
      print("업데이트 시간: \(fbDateFormatter.string(from: wifi.updatedDate))")
      print("ssid: \(wifi.ssid)")
      print("bssid: \(wifi.bssid)")
      print("rssi: \(wifi.rssi)")
      print("---------------------------------------------------------")
    } catch {
      print("Firebase에 wifi 업데이트 오류: \(error.localizedDescription)")
    }
  }
  
  func updateLocationToFirebase(location: Location) async {
    // 업데이트 시각
    let updateDate = location.updatedDate
    
    // 네트워크 상태 확인
    guard isNetworkValid() else {
      doOfflineSync(location: location)
      return
    }
    
    // 유저 로그인 상태 확인
    guard isUserLoginValid(), let user = userManager.user else {
      doOfflineSync(location: location)
      return
    }
    
    // 서버에 위치 정보 업로드
    do {
      try await fbRealtimeDataManager.addLocationData(user: user, location: location)
      
      // 마지막 업데이트 날짜 디바이스에 저장 (기존 날짜보다 더 최신의 날짜인 경우에만)
      let lastUpdatedDate = userDefaultManager.getLastUpdateDate() ?? Date(timeIntervalSince1970: 0)
      userDefaultManager.setLastUpdateDate(date: max(lastUpdatedDate, location.updatedDate))
      
      print("업데이트 시간: \(fbDateFormatter.string(from: updateDate))")
      print("위도: \(location.latitude), 경도: \(location.longitude)")
      print("---------------------------------------------------------")
    } catch {
      print("Firebase에 location 업데이트 오류: \(error.localizedDescription)")
      
      // Firebase 업로드 에러가 발생한 경우, 오프라인 싱크
      doOfflineSync(location: location)
    }
  }
  
  func updateMotionToFirebase(motions: [Motion]) async {
    // 네트워크 상태 확인
    guard isNetworkValid() else {
      return
    }
    
    // 유저 로그인 상태 확인
    guard isUserLoginValid(), let user = userManager.user else {
      return
    }
    
    do {
      try await fbRealtimeDataManager.addMotionData(user: user, motions: motions)
    } catch {
      print("Firebase에 [motion] 업데이트 오류: \(error.localizedDescription)")
    }
  }
}
