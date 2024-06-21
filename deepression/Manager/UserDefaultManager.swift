//
//  UserDefaultManager.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//
//  Last Position Update 정보, 오프라인 싱크를 위한 [Location] 정보를 다루는 Manager

import Foundation

class UserDefaultManager {
  func setLastUpdateDate(date: Date) {
      let defaults = UserDefaults.standard
      defaults.set(date, forKey: "lastUpdateDate")
  }
  
  func getLastUpdateDate() -> Date? {
      let defaults = UserDefaults.standard
      return defaults.object(forKey: "lastUpdateDate") as? Date
  }
  
  func setLocations(locations: [Location]) {
      let defaults = UserDefaults.standard
      let encoder = JSONEncoder()
      do {
          let data = try encoder.encode(locations)
          defaults.set(data, forKey: "locations")
      } catch {
          print("Failed to encode locations: \(error)")
      }
  }
  
  func getLocations() -> [Location]? {
      let defaults = UserDefaults.standard
      if let data = defaults.data(forKey: "locations") {
          let decoder = JSONDecoder()
          do {
              let locations = try decoder.decode([Location].self, from: data)
              return locations
          } catch {
              print("Failed to decode locations: \(error)")
          }
      }
      return nil
  }
  
  func addLocation(location: Location) {
    var locations = getLocations() ?? []
    locations.append(location)
    setLocations(locations: locations)
  }
  
  func clearLocation() {
    let defaults = UserDefaults.standard
    defaults.removeObject(forKey: "locations")
    defaults.synchronize()
  }
}
