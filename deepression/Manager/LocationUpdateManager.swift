//
//  LocationUpdateManager.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//
//  Firebase realtime database로 위치 정보를 업데이트하는 과정을 관리하는 매니저.

import Foundation
import UIKit

class LocationUpdateManager {
  private let fbRealtimeDataManager = FBRealtimeDataManager.shared
  private let userManager = UserManager.shared
  private let userDefaultManager = UserDefaultManager()
  private let networkManager = NetworkManager.shared
  
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
    // 네트워크 상태가 좋지 못한 경우
    // 디바이스(UserDefault)에 위치 정보 저장, 추후에 서버로 업데이트
    userDefaultManager.addLocation(location: location)
    
    // 시간 간격 보장을 위해 업데이트 시간은 최신화 (기존보다 최신의 날짜인 경우에만)
    let lastUpdatedDate = userDefaultManager.getLastUpdateDate() ?? Date(timeIntervalSince1970: 0)
    userDefaultManager.setLastUpdateDate(date: max(lastUpdatedDate, location.updatedDate))
  }
  
  func UpdateLocationToFireBase(location: Location) {
    // 업데이트 시각
    let updateDate = location.updatedDate
    
    // 15분의 업데이트 간격을 가지는지 확인
    if !isUpdateIntervalValid(intervalMinute: 1, updateDate: updateDate) {
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
    
    // 로그를 위해 앱 상태 기록
    let appState = UIApplication.shared.applicationState
    
    // 서버에 위치 정보 업로드
    Task {
      do {
        try await fbRealtimeDataManager.addUserData(user: user, latitude: location.latitude, longitude: location.longitude, updateDate: updateDate)
        
        // 마지막 업데이트 날짜 디바이스에 저장 (기존 날짜보다 더 최신의 날짜인 경우에만)
        let lastUpdatedDate = userDefaultManager.getLastUpdateDate() ?? Date(timeIntervalSince1970: 0)
        userDefaultManager.setLastUpdateDate(date: max(lastUpdatedDate, location.updatedDate))
        
        // 업데이트 완료 로그
        switch appState {
        case .active:
          print("환경: Foreground")
        case .background:
          print("환경: Background")
        default:
          print("환경: 기타")
        }
        print("업데이트 시간: \(fbDateFormatter.string(from: updateDate))")
        print("위도: \(location.latitude), 경도: \(location.longitude)")
        print("---------------------------------------------------------")
      } catch {
        // Firebase 업로드 에러가 발생한 경우, 오프라인 싱크
        doOfflineSync(location: location)
      }
    }
  }
}
