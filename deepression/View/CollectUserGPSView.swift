//
//  CollectUserGPSView.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation
import SwiftUI

class CollectUserGPSViewModel {
  private let locationManager = LocationManager.shared
  private let authManager = AuthManager.shared
  private let userDefaultManager = UserDefaultManager()
  
  func getLastUpdatedDate() -> Date? {
    // UserDefault에서 최근 업데이트 된 날짜를 가져온다.
    userDefaultManager.getLastUpdateDate()
  }
  
  func startUpdatingUserLocation() {
    locationManager.startUpdatingLocation()
    locationManager.startSignificantChangeUpdates()
  }
  
  func stopUpdatingUserLocation() {
    print("위치/Wifi 정보 받기 종료")
    locationManager.stopUpdatingLocation()
    locationManager.stopSignificantChangeUpdates()
  }
  
  func doLogOut() {
    authManager.Logout()
  }
  
  func openAppLocationSettings() {
     if let url = URL(string: UIApplication.openSettingsURLString) {
         if UIApplication.shared.canOpenURL(url) {
             UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
     }
   }
  
  func isAuthorizationStatusAlways() -> Bool {
    return locationManager.authorizationStatus == .authorizedAlways
  }
}

struct CollectUserGPSView: View {
  let viewModel = CollectUserGPSViewModel()
  @StateObject var userManager: UserManager
  @State private var lastUpdatedDate: Date? = nil
  @State private var presentAlert = false
  
  var body: some View {
    VStack {
      List {
        Section(header: Text("마지막 업데이트 날짜")
          .font(.title2)
          .fontWeight(.bold)
        ) {
          Text(lastUpdatedDate == nil ? "최근 업데이트 없음" : fbDateFormatter.string(from: lastUpdatedDate!))
        }
        .listRowSeparator(.hidden)
        
        Section(header: Text("위치 정보")
          .font(.title3)
          .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        ) {
          Button("위치/Wifi 정보 받기 시작") {
            viewModel.startUpdatingUserLocation()
          }
          
          Button("위치/Wifi 정보 받기 종료") {
            viewModel.stopUpdatingUserLocation()
          }
        }
        .buttonStyle(DefaultButtonStyle())
        .listRowSeparator(.hidden)
        
        Button("위치 서비스 설정") {
          presentAlert = true
        }
      }
      
      Button("로그아웃") {
        viewModel.doLogOut()
        userManager.user = nil
      }
      .buttonStyle(BorderedProminentButtonStyle())
    }
    .alert("위치 접근 허용 변경", isPresented: $presentAlert, actions: {
      Button("설정", role: .none) {
        viewModel.openAppLocationSettings()
      }
      
      Button("닫기", role: .cancel) {
        
      }
    }, message: {
      Text("앱의 원활한 데이터 수집을 위해\n 위치 접근 허용을 '항상'으로 변경해주세요.")
    })
    .onAppear {
      lastUpdatedDate = viewModel.getLastUpdatedDate()
      if !viewModel.isAuthorizationStatusAlways() {
        presentAlert = true
      }
    }
    .refreshable {
      lastUpdatedDate = viewModel.getLastUpdatedDate()
      if !viewModel.isAuthorizationStatusAlways() {
        presentAlert = true
      }
    }
  }
}

#Preview {
  CollectUserGPSView(userManager: UserManager.shared)
}
