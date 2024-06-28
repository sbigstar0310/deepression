//
//  NetworkExtensionManager.swift
//  deepression
//
//  Created by 성대규 on 6/26/24.
//

import Foundation
import NetworkExtension

class WifiManager {
  // 싱글톤 클래스
  static let shared = WifiManager()
  private init() {}
  
  // WIFI 연결 정보 가져오기
  func getCurrentWiFiInfo() async -> Wifi {
    let currentWifi = await NEHotspotNetwork.fetchCurrent()
    
    guard let wifi = currentWifi else {
      // 와이파이 연결이 아니거나(셀룰러, 이더넷), 네트워크 연결이 없는 경우.
      let defaultWifi = Wifi(updatedDate: Date(), ssid: "None", bssid: "None", rssi: 0.0)
      return defaultWifi
    }
    
    let updatedDate = Date()
    let ssid = wifi.ssid
    let bssid = wifi.bssid
    let rssi = wifi.signalStrength
    
    return Wifi(updatedDate: updatedDate, ssid: ssid, bssid: bssid, rssi: rssi)
  }
}
