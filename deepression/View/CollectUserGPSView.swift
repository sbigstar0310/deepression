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
  @State private var lastUpdatedDate: Date? = nil
  
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
    .onAppear {
      lastUpdatedDate = viewModel.getLastUpdatedDate()
    }
    .refreshable {
      lastUpdatedDate = viewModel.getLastUpdatedDate()
    }
  }
}

#Preview {
  CollectUserGPSView(userManager: UserManager.shared)
}
