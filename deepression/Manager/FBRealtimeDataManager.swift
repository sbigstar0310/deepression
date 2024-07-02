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
  
  init() {
    self.ref = Database.database().reference()
    self.encoder = JSONEncoder()
    self.decoder = JSONDecoder()
  }
  
  enum FBRealtimeDataManagerError: Error {
    case referenceUnavailable
  }
  
  func addLocationData(user: User, location: Location) async throws {
    // 유저 정보 (User Info)
    guard let ref = ref else {
      print("error in getting ref")
      throw FBRealtimeDataManagerError.referenceUnavailable
    }
    
    let childRef = ref.child("Users").child("\(user.id)").child("Locations").childByAutoId()
    
    do {
      try await childRef.setValue([
        "id" : childRef.key,
        "latitude" : "\(location.latitude)",
        "longitude" : "\(location.longitude)",
        "obtained_at" : fbDateFormatter.string(from: location.updatedDate),
      ])
    } catch {
      throw error
    }
  }
  
  func addWifiData(user: User, wifi: Wifi) async throws {
    guard let ref = ref else {
      print("error in getting ref")
      throw FBRealtimeDataManagerError.referenceUnavailable
    }
    
    let childRef = ref.child("Users").child("\(user.id)").child("Wifies").childByAutoId()
    
    do {
      try await childRef.setValue([
        "id" : childRef.key,
        "ssid" : "\(wifi.ssid)",
        "bssid" : "\(wifi.bssid)",
        "rssi" : "\(wifi.rssi)",
        "obtained_at" : fbDateFormatter.string(from: wifi.updatedDate),
      ])
    } catch {
      throw error
    }
  }
  
  func addMotionData(user: User, motions: [Motion]) async throws {
    guard let ref = ref else {
      print("error in getting ref")
      throw FBRealtimeDataManagerError.referenceUnavailable
    }
    
    let userRef = ref.child("Users").child("\(user.id)")
    
    var motionUpdates: [String : Any] = [:]
    
    for motion in motions {
      var filePath: String {
        switch motion.dataType {
        case .accelerationField:
          return "Acceleration"
        case .mangeticField:
          return "Magnetic"
        }
      }
      
      let key = userRef.child(filePath).childByAutoId().key!
      
      let motionData =  [
        "id" : key,
        "x" : motion.x,
        "y" : motion.y,
        "z" : motion.z,
        "obtained_at" : fbDateFormatter.string(from: motion.updatedDate),
      ] as [String : Any]
      
      motionUpdates["/\(filePath)/\(key)"] = motionData
    }
    
    do {
      try await userRef.updateChildValues(motionUpdates)
    } catch {
      throw error
    }
  }
  
  func deleteUserData(user: User) {
    ref?.child("Users/\(user.id)").removeValue()
  }
}
