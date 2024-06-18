//
//  AuthManager.swift
//  SeureureukApp
//
//  Created by 성대규 on 5/12/24.
//

import SwiftUI
import FirebaseAuth

class AuthManager: Observable {
  
  static let shared = AuthManager()
  private init() {}
  
  
  func getCurrentUserID() -> String? {
    return Auth.auth().currentUser?.uid
  }
  
  func RegisterWith(email: String, password: String) async throws {
    do {
      try await Auth.auth().createUser(withEmail: email, password: password)
      print("회원가입 성공")
    } catch {
      throw error
    }
  }
  
  func LoginInWith(email: String, password: String) async throws{
    do {
      try await Auth.auth().signIn(withEmail: email, password: password)
      print("로그인 성공")
    } catch {
      throw error
    }
  }
  
  func Logout() {
    do {
      try Auth.auth().signOut()
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func deleteAccount(user: User) async {
    guard let currentUser = Auth.auth().currentUser else {
      print("User is not a currentUser")
      return
    }
    
    guard user.id == currentUser.uid else {
      print("Not vailid user id")
      return
    }
    
    // 유저 계정 삭제하기.
    do {
      try await currentUser.delete()
    } catch  {
      print("error in deleting user account \(error.localizedDescription)")
    }
  }
}
