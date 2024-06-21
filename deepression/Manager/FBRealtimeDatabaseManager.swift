//
//  FBRealtimeDatabaseManager.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FBRealtimeDataManager: ObservableObject {
  @Published var userData: User?
  let ref: DatabaseReference?
  private let encoder: JSONEncoder
  private let decoder: JSONDecoder
  
  static let shared = FBRealtimeDataManager()
  private init() {
    self.ref = Database.database().reference()
    self.encoder = JSONEncoder()
    self.decoder = JSONDecoder()
  }
  
  enum FBRealtimeDataManagerError: Error {
    case referenceUnavailable
  }
  
  func addUserData(user: User, latitude: Double, longitude: Double, updateDate: Date) async throws {
    // 유저 정보 (User Info)
    guard let ref = ref else {
      print("error in getting ref")
      throw FBRealtimeDataManagerError.referenceUnavailable
    }
    
    let childRef = ref.child("Users").child("\(user.id)").child("Locations").childByAutoId()
    
    do {
      try await childRef.setValue([
        "id" : childRef.key,
        "latitude" : "\(latitude)",
        "longitude" : "\(longitude)",
        "obtained_at" : fbDateFormatter.string(from: updateDate),
      ])
    } catch {
      throw error
    }
  }
  
  func deleteUserData(user: User) {
    ref?.child("Users/\(user.id)").removeValue()
  }
}
