//
//  MotionManager.swift
//  deepression
//
//  Created by 성대규 on 6/27/24.
//

import Foundation
import CoreMotion

class MotionManager {
  static let shared = MotionManager()
  private init() {}
  
  private let motionManager = CMMotionManager()
  private let fbUpdateManager = FBUpdateManager.shared
  private let updateInterval = 1.0 * 5 * 60 // 단위 sec
  private var motion: Motion = Motion(updatedDate: Date())
//  private let dispatchQueue = DispatchQueue(label: "com.motionManager.queue")
  
  // Motion 데이터가 유효한지 확인
  // accelerationField, magneticField, userAccelerationField, userMagneticField
  // 모든 데이터가 nil이 아니어야 함
  func isMotionDataValid(motion: Motion) -> Bool {
    guard let _ = motion.accelerationField,
          let _ = motion.magneticField,
          let _ = motion.userAccelerationField,
          let _ = motion.userMagneticField 
    else {
      return false
    }
    
    return true
  }
  
  func resetMotionData() {
    self.motion = Motion(updatedDate: Date())
  }
  
  // Motion 데이터 업데이트 시작
  func startMotionUpdates() {
    startAccelerometerUpdate()
    startMagnetometerUpdate()
    startDeviceMotionUpdate()
  }
  
  // Motion 데이터 업데이트 종료
  func stopMotionUpdates() {
    stopAccelerometerUpdates()
    stopMagnetometerUpdates()
    stopDeviceMotionUpdates()
  }
  
  private func startAccelerometerUpdate() {
    guard motionManager.isAccelerometerAvailable else {
      // 디바이스에서 자기장 센서 사용 불가능
      return
    }
    
    // updateInterval에 한 번씩 업데이트
    motionManager.accelerometerUpdateInterval = updateInterval
    
    motionManager.startAccelerometerUpdates(to: OperationQueue.main) { [weak self] data, error in
      guard let self = self else {
        return
      }
      
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      guard let data = data else {
        print("올바른 가속도 데이터가 아닙니다.")
        return
      }
      
      let (_, _, _) = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
      
      // 데이터 갱신
      print("Accelerometer 데이터 갱신")
      self.motion.updatedDate = Date()
      self.motion.accelerationField = data.acceleration
    }
  }
  
  private func stopAccelerometerUpdates() {
    motionManager.stopAccelerometerUpdates()
  }
  
  private func startMagnetometerUpdate() {
    guard motionManager.isMagnetometerAvailable else {
      // 디바이스에서 자기장 센서 사용 불가능
      return
    }
    
    // updateInterval에 한 번씩 업데이트
    motionManager.magnetometerUpdateInterval = updateInterval
    
    motionManager.startMagnetometerUpdates(to: OperationQueue.main) { [weak self] data, error in
      guard let self = self else {
        return
      }
      
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      guard let data = data else {
        print("올바른 자기장 데이터가 아닙니다.")
        return
      }
      
      let (_, _, _) = (data.magneticField.x, data.magneticField.y, data.magneticField.z)
      
      // 데이터 갱신
      print("magneticField 데이터 갱신")
      self.motion.updatedDate = Date()
      self.motion.magneticField = data.magneticField
    }
  }
  
  private func stopMagnetometerUpdates() {
    motionManager.stopMagnetometerUpdates()
  }
  
  
  
  private func startDeviceMotionUpdate() {
    guard motionManager.isDeviceMotionAvailable else {
      // 디바이스에서 Device Motion 사용 불가능
      return
    }
    
    let avaiableMask = CMMotionManager.availableAttitudeReferenceFrames()
    print(avaiableMask)
    
    guard ((avaiableMask.rawValue & CMAttitudeReferenceFrame.xArbitraryCorrectedZVertical.rawValue) != 0)  else {
      print("디바이스에서 가능한 기준 좌표계가 아님")
      return
    }
    
    // 1초에 한 번씩 업데이트
    motionManager.deviceMotionUpdateInterval = updateInterval
    
    motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue.main) { [weak self] data, error in
      guard let self = self else {
        return
      }
      
      if let error = error {
        print(error.localizedDescription)
        return
      }
      
      guard let data = data else {
        print("올바른 자기장 데이터가 아닙니다.")
        return
      }
      
      let (_, _, _) = ( data.userAcceleration.x, data.userAcceleration.y, data.userAcceleration.z)
      let (_, _, _, _) = (data.magneticField.accuracy, data.magneticField.field.x, data.magneticField.field.y, data.magneticField.field.z)
      
        // 데이터 갱신
        print("DeviceMotion 데이터 갱신")
        self.motion.updatedDate = Date()
        self.motion.userAccelerationField = data.userAcceleration
        self.motion.userMagneticField = data.magneticField.field
        
        // 3개의 CompletionHandler 중, DeviceMotion Completion Handler를 기준으로 서버에 업데이트 진행 (1초의 간격을 보장하기 위함)
        let capturedCurrentMotionData = self.motion
        
        Task {
          // Motion 데이터의 유효성 검증
          print("Motion 데이터 유효성 검증")
          guard self.isMotionDataValid(motion: capturedCurrentMotionData) else {
            print("Motion 데이터 유효성 검증 실패")
            return
          }
          
          print("Motion 데이터 업로드 전, 기존 초기화")
          //새로운 Motion 데이터를 채우기 위해 기존 데이터를 비우기
          self.motion = Motion(updatedDate: Date())
          
          print("Motion 데이터 업로드 요청")
          // 서버에 Motion 데이터 업로드 요청
          await self.fbUpdateManager.updateMotionToFirebase(motion: capturedCurrentMotionData)
        }
      }
    }
  
  private func stopDeviceMotionUpdates() {
    motionManager.stopDeviceMotionUpdates()
  }
}
