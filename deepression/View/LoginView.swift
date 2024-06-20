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
      ScrollView {
        Spacer()
          .frame(height: 50)
        
        VStack(alignment: .leading) {
          Text("이메일 주소 입력")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.bottom, 12)
            .padding(.horizontal, 31)
          
          Text("이메일 주소를 적어주세요. (ex. aa@gmail.com)")
            .padding(.bottom, 12)
            .padding(.horizontal, 31)
          
          TextField("이메일을 입력해주세요.", text: $email)
            .padding(10)
            .textFieldStyle(.plain)
            .border(Color.black)
            .padding(.bottom, 15)
            .padding(.horizontal, 31)
          
          Text("비밀번호 입력")
            .font(.title2)
            .fontWeight(.bold)
            .padding(.bottom, 12)
            .padding(.horizontal, 31)
          
          Text("영문, 숫자 혼합하여 8자 이상으로 설정해주세요.")
            .padding(.bottom, 12)
            .padding(.horizontal, 31)
          
          SecureField("비밀번호를 입력해주세요.", text: $password)
            .padding(10)
            .textFieldStyle(.plain)
            .border(Color.black)
            .padding(.horizontal, 31)
          
          Spacer()
            .frame(height: 30)
          
          HStack {
            Spacer()
            Text("계정이 없으신가요? ")
            Button("회원가입 하기") {
              goRegisterView = true
            }
            
            Spacer()
          }
        }
      }
      .navigationDestination(isPresented: $goRegisterView) {
        RegisterView(userManager: userManager, goRegisterView: $goRegisterView)
      }
      
      if email.count > 0 && (password.count > 0) {
        ZStack {
          Rectangle()
            .frame(width: 300, height: 60)
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
            .frame(width: 300, height: 60)
            .foregroundStyle(.gray)
          
          Text("다음")
            .foregroundStyle(.black)
        }
      }
    }
  }
}

#Preview {
  LoginView(userManager: UserManager.shared)
}

