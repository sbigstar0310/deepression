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
  private let userDefaultManager = UserDefaultManager()
  private let updateInterval = 1.0 // 단위 sec
  
  // 30분 간격인지 판단하는 함수
  private func isTimeOnMinuteInterval(date: Date, interval: Int) -> Bool {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.hour, .minute], from: date)
    
    guard 0 <= interval && interval < 60 else {
      // 분의 단위가 아님.
      return false
    }
    
    if let minute = components.minute {
        return minute % interval == 0
    }
    return false
  }
  
  // Motion 데이터 업데이트 시작
  func startMotionUpdates() {
    startAccelerometerUpdate()
    startMagnetometerUpdate()
    // Device Motion 수집 보류
    //startDeviceMotionUpdate()
  }
  
  // Motion 데이터 업데이트 종료
  func stopMotionUpdates() {
    stopAccelerometerUpdates()
    stopMagnetometerUpdates()
    // Device Motion 수집 보류
    //stopDeviceMotionUpdates()
  }
  
  private func startAccelerometerUpdate() {
    // 이미 가속도 데이터 업데이트 중이면 정지
    if motionManager.isAccelerometerActive {
      stopAccelerometerUpdates()
    }
    
    guard motionManager.isAccelerometerAvailable else {
      // 디바이스에서 가속도 센서 사용 불가능
      print("디바이스에서 가속도 센서 사용 불가능")
      return
    }
    
    // updateInterval 간격으로 업데이트
    motionManager.accelerometerUpdateInterval = updateInterval
    
    // Background Queue 정의
    let backgroundQueue = OperationQueue()
    backgroundQueue.name = "Background Queue"
    backgroundQueue.qualityOfService = .background
    
    // update Handler 정의
    motionManager.startAccelerometerUpdates(to: backgroundQueue) { [weak self] data, error in
      
      guard let self = self else {
        print("self가 nil입니다.")
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
      
      let (x, y, z) = (data.acceleration.x, data.acceleration.y, data.acceleration.z)
      
      // 데이터 갱신
      print("가속도 데이터 갱신 \(fbDateFormatter.string(from: Date()))")
      let currentAccelerometerData = Motion(updatedDate: Date(), dataType: .accelerationField, x: x, y: y, z: z)
      
      // 디바이스에 데이터 저장
      userDefaultManager.addMotion(motion: currentAccelerometerData)
      
      // 30분 간격으로 디바이스 데이터 서버에 업로드 요청
      // `motions.count > 1000`는 30분일 때, 계속 업데이트 되는 것을 방지하기 위함
      if isTimeOnMinuteInterval(date: currentAccelerometerData.updatedDate, interval: 30),
         let motions = userDefaultManager.getMotions(),
         motions.count > 1000 {
        userDefaultManager.clearMotions()
        Task {
          await self.fbUpdateManager.updateMotionToFirebase(motions: motions)
        }
      }
    }
  }
  
  private func stopAccelerometerUpdates() {
    motionManager.stopAccelerometerUpdates()
  }
  
  private func startMagnetometerUpdate() {
    // 이미 자기장 데이터 업데이트 중이면 정지
    if motionManager.isMagnetometerActive {
      stopMagnetometerUpdates()
    }
    
    guard motionManager.isMagnetometerAvailable else {
      // 디바이스에서 자기장 센서 사용 불가능
      print("디바이스에서 자기장 센서 사용 불가능")
      return
    }
    
    // updateInterval 간격으로 업데이트
    motionManager.magnetometerUpdateInterval = updateInterval
    
    // Background Queue 정의
    let backgroundQueue = OperationQueue()
    backgroundQueue.name = "Background Queue"
    backgroundQueue.qualityOfService = .background
    
    motionManager.startMagnetometerUpdates(to: backgroundQueue) { [weak self] data, error in
      guard let self = self else {
        print("self가 ni입니다.")
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
      
      let (x, y, z) = (data.magneticField.x, data.magneticField.y, data.magneticField.z)
      
      // 데이터 갱신
      print("자기장 데이터 갱신 \(fbDateFormatter.string(from: Date()))")
      let currentMagnetometerData = Motion(updatedDate: Date(), dataType: .mangeticField, x: x, y: y, z: z)
      
      // 디바이스에 데이터 저장
      userDefaultManager.addMotion(motion: currentMagnetometerData)
    }
  }
  
  private func stopMagnetometerUpdates() {
    motionManager.stopMagnetometerUpdates()
  }
}

// MARK: Device Motion에 관한 코드
extension MotionManager {
  /*
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
   */
  
  /*
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
   */
}
