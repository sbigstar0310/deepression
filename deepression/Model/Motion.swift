//
//  Motion.swift
//  deepression
//
//  Created by 성대규 on 6/27/24.
//

import Foundation
import CoreMotion

struct Motion: Codable, Hashable {
  var updatedDate: Date
  var dataType: DataType
  let x: Double
  let y: Double
  let z: Double
  
  enum DataType: Codable {
    case accelerationField
    case mangeticField
  }
}
