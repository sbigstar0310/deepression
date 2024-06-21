//
//  TabView.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//

import SwiftUI

struct HomeTabView: View {
  @StateObject var userManager: UserManager
  
  var body: some View {
    TabView {
      CollectUserGPSView(userManager: userManager)
        .tabItem {
          Image(systemName: "location.square")
          Text("위치 정보")
        }
      
      OfflineSavedLocationView()
        .tabItem {
          Image(systemName: "square.and.arrow.up.on.square")
          Text("데이터 전송")
        }
    }
  }
}

#Preview {
  HomeTabView(userManager: UserManager.shared)
}
