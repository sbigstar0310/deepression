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
  
  func getLastUpdatedDate() -> Date {
    // 최근 업데이트 된 날짜를 가져온다.
    locationManager.lastUpdatedDate
  }
  
  func startUpdatingUserLocationWithTimer() {
    // Timer를 이용하여 15분간 유저의 위치를 업데이트 시작
    locationManager.startUpdateLocationWithTimer()
    // SLC도 업데이트 시작
    locationManager.startSignificantChangeUpdates()
  }
  
  func stopUpdatingUserLocationWithTimer() {
    print("타이머를 이용한 업데이트 종료")
    // Timer를 이용하는 업데이트 종료
    locationManager.stopUpdateLocationWithTimer()
    // SLC 업데이트 종료
    locationManager.stopSignificantChangeUpdates()
  }
  
  func startUpdatingUserLocation() {
    locationManager.startUpdatingLocation()
    locationManager.startSignificantChangeUpdates()
  }
  
  func stopUpdatingUserLocation() {
    print("CLLocation를 이용한 업데이트 종료")
    locationManager.stopUpdatingLocation()
    locationManager.stopSignificantChangeUpdates()
  }
  
  func doLogOut() {
    authManager.Logout()
  }
}

struct CollectUserGPSView: View {
  let viewModel = CollectUserGPSViewModel()
  @StateObject var userManager: UserManager
  @State private var lastUpdatedDate = "최근 업데이트 없음"
  
  var body: some View {
    VStack {
      List {
        Section(header: Text("마지막 업데이트 날짜")
          .font(.title2)
          .fontWeight(.bold)
        ) {
          Text(lastUpdatedDate)
        }
        .listRowSeparator(.hidden)
        
        Section(header: Text("Timer를 통해 위치 정보 받기")
          .font(.title2)
          .fontWeight(.bold)
        ) {
          Button("위치 정보 받기 시작") {
            viewModel.startUpdatingUserLocationWithTimer()
          }
          
          Button("위치 정보 받기 종료") {
            viewModel.stopUpdatingUserLocationWithTimer()
          }
        }
        .buttonStyle(DefaultButtonStyle())
        .listRowSeparator(.hidden)
        
        Section(header: Text("startUpdatingLocation를 통해 위치 정보 받기")
          .font(.title3)
          .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
        ) {
          Button("위치 정보 받기 시작") {
            viewModel.startUpdatingUserLocation()
          }
          
          Button("위치 정보 받기 종료") {
            viewModel.stopUpdatingUserLocation()
          }
        }
        .buttonStyle(DefaultButtonStyle())
        .listRowSeparator(.hidden)
        
      }
      
      Button("로그아웃") {
        viewModel.doLogOut()
        userManager.user = nil
      }
      .buttonStyle(BorderedProminentButtonStyle())
    }
    .refreshable {
      lastUpdatedDate = fbDateFormatter.string(from: viewModel.getLastUpdatedDate())
    }
  }
}

#Preview {
  CollectUserGPSView(userManager: UserManager.shared)
}
