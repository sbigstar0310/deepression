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
  private let fbRealtimeDataManager = FBRealtimeDataManager.shared
  private let userManager = UserManager.shared
  private let userDefaultManager = UserDefaultManager()
  private let networkManager = NetworkManager.shared
  // 업데이트를 진행할 시간 간격 (단위: 분)
  private let minIntervalMinute = 15
  
  static let shared = FBUpdateManager()
  private init() {}
  
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
    
    // 15분의 업데이트 간격을 가지는지 확인
    if !isUpdateIntervalValid(intervalMinute: minIntervalMinute, updateDate: updatedDate) {
      return
    }
    
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
      print("Firebase에 network 업데이트 오류: \(error.localizedDescription)")
    }
  }
  
  func updateLocationToFireBase(location: Location) async {
    // 업데이트 시각
    let updateDate = location.updatedDate
    
    // 15분의 업데이트 간격을 가지는지 확인
    if !isUpdateIntervalValid(intervalMinute: minIntervalMinute, updateDate: updateDate) {
      return
    }
    
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
}
