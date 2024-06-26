//
//  NetworkManager.swift
//  deepression
//
//  Created by 성대규 on 6/20/24.
//
//  사용자의 네트워크 상태를 점검하는 Manager입니다.

import Foundation
import Network

// 네트워크 연결타입
enum ConnectionType {
  case wifi
  case cellular
  case ethernet
  case unknown
}

class NetworkManager {
  // 싱글톤 클래스로 작성
  static let shared = NetworkManager()
  private init() { }
  
  private let monitor = NWPathMonitor()
  private var isConnected: Bool = false
  private var connectionType: ConnectionType = .unknown
  
  // Network Monitoring 시작
  func startMonitoring() {
    monitor.start(queue: .global())
    monitor.pathUpdateHandler = { [weak self] path in
      guard let self = self else { return }
      
      // 네트워크 연결 여부 저장
      self.isConnected = (path.status == .satisfied)
      
      // 네트워크 연결 방식 저장
      // self.getConnectionType(path)
    }
  }
  
  // Network Monitoring 종료
  func stopMonitoring() {
    monitor.cancel()
  }
  
  // 네트워크 연결 여부 반환
  func getNetworkIsConnected() -> Bool {
    isConnected
  }
  
  func getNetworkConnectionType() -> ConnectionType {
    connectionType
  }
  
  // 네트워크 연결 타입
  func getConnectionType(_ path: NWPath) {
    if path.usesInterfaceType(.wifi) {
      connectionType = .wifi
    } else if path.usesInterfaceType(.cellular) {
      connectionType = .cellular
    } else if path.usesInterfaceType(.wiredEthernet) {
      connectionType = .ethernet
    } else {
      connectionType = .unknown
    }
  }
}
