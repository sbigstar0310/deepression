//
//  CollectUserGPSView.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation
import SwiftUI

struct CollectUserGPSView: View {
  let locationManager = LocationManager()
  let authManager = AuthManager.shared
  @StateObject var userManager: UserManager
  
  var body: some View {
    VStack {
      Button("위치 정보 받기 시작") {
        locationManager.startUpdateLocationInTime()
        locationManager.startSignificantChangeUpdates()
      }
      
      Button("로그아웃") {
        authManager.Logout()
        userManager.user = nil
      }
    }
  }
}

#Preview {
  CollectUserGPSView(userManager: UserManager.shared)
}
