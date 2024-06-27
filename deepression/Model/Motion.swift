//
//  Motion.swift
//  deepression
//
//  Created by 성대규 on 6/27/24.
//

import Foundation
import CoreMotion

struct Motion {
  var updatedDate: Date
  var accelerationField: CMAcceleration?
  var magneticField: CMMagneticField?
  var userAccelerationField: CMAcceleration?
  var userMagneticField: CMMagneticField?
}
