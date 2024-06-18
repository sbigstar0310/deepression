//
//  UserManager.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation

class UserManager: ObservableObject {
  @Published var user: User?
  
  static let shared = UserManager()
  private init() {}
}
