//
//  ContentView.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import SwiftUI
import FirebaseAuth

struct ContentView: View {
  @State var authHandle: AuthStateDidChangeListenerHandle? = nil
  @StateObject var userManager = UserManager.shared
  
  var body: some View {
    VStack {
      if userManager.user != nil {
        HomeTabView(userManager: userManager)
      } else {
        LoginView(userManager: userManager)
      }
    }
    .onAppear {
      authHandle = Auth.auth().addStateDidChangeListener { auth, user in
        // ...
        if let user = user {
          print("로그인 성공")
          print("유저 아이디: \(user.uid)")
          userManager.user = User(id: user.uid)
        } else {
          print("로그인 정보 없음")
        }
      }
    }
    .onDisappear {
      Auth.auth().removeStateDidChangeListener(authHandle!)
    }
  }
}

#Preview {
  ContentView()
}
