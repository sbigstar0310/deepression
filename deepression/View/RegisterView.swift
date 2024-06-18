//
//  RegisterView.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import SwiftUI

class RegisterViewModel {
  let authManager = AuthManager.shared
  
  func doRegisterWith(email: String, password: String) async  {
    do {
      try await authManager.RegisterWith(email: email, password: password)
    } catch {
      print(error)
    }
  }
}

struct RegisterView: View {
  let viewModel = RegisterViewModel()
  @StateObject var userManager: UserManager
  @State var email = ""
  @State var password1 = ""
  @State var password2 = ""
  @Binding var goRegisterView: Bool
  
  var body: some View {
    ScrollView {
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
      
      SecureField("비밀번호", text: $password1)
        .padding(10)
        .textFieldStyle(.roundedBorder)
        .border(Color.black)
        .padding(.bottom, 5)
        .padding(.horizontal, 31)
      
      HStack {
        Spacer()
        Text("\(password1.count)/22")
      }
      .padding(.bottom, 15)
      .padding(.horizontal, 31)
      
      Text("비밀번호 확인")
        .padding(.bottom, 12)
        .padding(.horizontal, 31)
      
      Text("위에 적어주신 비밀번호를 다시 한번 적어주세요")
        .padding(.bottom, 12)
        .padding(.horizontal, 31)
      
      SecureField("비밀번호 확인", text: $password2)
        .padding(10)
        .textFieldStyle(.roundedBorder)
        .border(Color.black)
        .padding(.bottom, 5)
        .padding(.horizontal, 31)
      
      HStack {
        Spacer()
        Text("\(password2.count)/22")
      }
      .padding(.bottom, 15)
      .padding(.horizontal, 31)
      .id("last")
      
      Spacer()
        .frame(height: 50)
      
      
      if email.count > 0 && (password1 == password2) && (password1.count > 0) {
        ZStack {
          Rectangle()
            .frame(width: 300, height: 84)
            .foregroundStyle(.blue)
          
          Text("다음")
            .foregroundStyle(.black)
        }
        .onTapGesture {
          Task {
            await viewModel.doRegisterWith(email: email, password: password1)
            guard let currentUserId = AuthManager.shared.getCurrentUserID() else {
              return
            }
            userManager.user = User(id: currentUserId)
            goRegisterView = false
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
  }
}

#Preview {
  RegisterView(userManager: UserManager.shared, goRegisterView: .constant(true))
}

