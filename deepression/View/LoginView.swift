//
//  LoginVIew.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import SwiftUI

//
//  RegisterView.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

class LoginViewModel {
  let AuthManger = AuthManager.shared
  
  func doLoginwith(email: String, password: String) async {
    do {
      try await AuthManger.LoginInWith(email: email, password: password)
    } catch {
      print(error)
    }
  }
}

struct LoginView: View {
  let viewModel = LoginViewModel()
  @StateObject var userManager: UserManager
  @State private var goRegisterView = false
  @State var email = ""
  @State var password = ""
  
  var body: some View {
    NavigationStack {
      VStack {
        Text("이메일 주소 입력")
          .fontWeight(.bold)
          .padding(.bottom, 12)
          .padding(.horizontal, 31)
        
        Text("이메일 주소를 적어주세요. (ex. abcdefg@gmail.com)")
          .padding(.bottom, 12)
          .padding(.horizontal, 31)
        
        TextField("이메일을 입력해주세요", text: $email)
          .padding(10)
          .textFieldStyle(.roundedBorder)
          .border(Color.black)
          .padding(.bottom, 5)
          .padding(.horizontal, 31)
        
        HStack {
          Spacer()
          Text("\(email.count)/22")
        }
        .padding(.bottom, 15)
        .padding(.horizontal, 31)
        
        Text("비밀번호 설정")
          .padding(.bottom, 12)
          .padding(.horizontal, 31)
        
        Text("영문, 숫자 혼합하여 8자 이상으로 설정해주세요.")
          .padding(.bottom, 12)
          .padding(.horizontal, 31)
        
        SecureField("비밀번호", text: $password)
          .padding(10)
          .textFieldStyle(.roundedBorder)
          .border(Color.black)
          .padding(.bottom, 5)
          .padding(.horizontal, 31)
        
        HStack {
          Spacer()
          Text("\(password.count)/22")
        }
        .padding(.bottom, 15)
        .padding(.horizontal, 31)
        
        Button("회원가입 하기") {
          goRegisterView = true
        }
        
        if email.count > 0 && (password.count > 0) {
          ZStack {
            Rectangle()
              .frame(width: 300, height: 84)
              .foregroundStyle(.blue)
            
            Text("다음")
              .foregroundStyle(.black)
          }
          .onTapGesture {
            Task {
              await viewModel.doLoginwith(email: email, password: password)
              guard let currentUserId = AuthManager.shared.getCurrentUserID() else {
                return
              }
              userManager.user = User(id: currentUserId)
            }
          }
        } else {
          ZStack {
            Rectangle()
              .frame(width: 300, height: 84)
              .foregroundStyle(.gray)
            
            Text("다음")
              .foregroundStyle(.black)
          }
        }
      }
      .navigationDestination(isPresented: $goRegisterView) {
        RegisterView(userManager: userManager, goRegisterView: $goRegisterView)
      }
    }
  }
}

#Preview {
  LoginView(userManager: UserManager.shared)
}

