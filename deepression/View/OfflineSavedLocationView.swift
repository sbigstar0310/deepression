//
//  OfflineSavedLocationView.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//

import Foundation
import SwiftUI

@MainActor
class OfflineSavedLocationViewModel: ObservableObject {
  @Published var progress = 0.0
  @Published var savedLocations: [Location] = []
  @Published var savedMotions: [Motion] = []
  
  private let userDefaultManager = UserDefaultManager()
  private let fbUpdateManager = FBUpdateManager.shared
  private var isUpdating = false
  
  func tryUpdateOfflineData() {
    guard !isUpdating else {
      print("이미 업데이트 중입니다.")
      return
    }
    
    // Update Lock 걸기
    isUpdating = true
    
    // UserDefault에서 [location], [Motion] 받아오기
    savedLocations = userDefaultManager.getLocations() ?? []
    savedMotions = userDefaultManager.getMotions() ?? []
    
    Task {
      // 기존에 저장된 데이터 삭제
      userDefaultManager.clearLocation()
      userDefaultManager.clearMotions()
      
      // 데이터의 전체 개수
      let overallDataCount = savedLocations.count + savedMotions.count
      
      // 기존 데이터 모두 서버에 업로드 시도
      for (index, location) in savedLocations.enumerated() {
        await fbUpdateManager.updateLocationToFirebase(location: location)
        await MainActor.run {
          progress = Double(index + 1) / Double(overallDataCount)
        }
      }
      
      await fbUpdateManager.updateMotionToFirebase(motions: savedMotions)
      
      await MainActor.run {
        progress = 1.0
      }
      
      // 데이터 변경사항 viewModel에 반영
      await initializeView()
      
      // Update Lock 풀기
      isUpdating = false
    }
  }
  
  func initializeView() async {
    // 로딩이 완료되면 진행도를 0으로 초기화
    await MainActor.run {
      progress = (progress == 1) ? 0 : progress
    }
    // UserDefault에서 [location], [Motion] 받아오기
    savedLocations = userDefaultManager.getLocations() ?? []
    savedMotions = userDefaultManager.getMotions() ?? []
  }
}

struct OfflineSavedLocationView: View {
  @StateObject var viewModel = OfflineSavedLocationViewModel()
  
  var body: some View {
    VStack {
      HStack {
        Text("수집된 데이터")
          .font(.largeTitle)
          .fontWeight(.bold)
        
        Spacer()
      }
      .padding()
      
      ZStack {
        RoundedRectangle(cornerRadius: 5)
          .frame(width: 300, height: 300)
          .foregroundStyle(.blue)
          .opacity(0.4)
        
        RingDashProgressView(progress: viewModel.progress)
          .frame(width: 250, height: 250)
        
        VStack {
          Text("\(viewModel.savedLocations.count + viewModel.savedMotions.count) 개")
            .font(.title)
            .bold()
        }
      }
      
      ZStack {
        RoundedRectangle(cornerRadius: 5)
          .frame(height: 50)
          .foregroundStyle(.blue)
          .padding(.horizontal, 20)
        
        Text("데이터 전송")
          .foregroundStyle(.white)
          .font(.title3)
      }
      .onTapGesture {
        viewModel.tryUpdateOfflineData()
      }
    }
    .task {
      await viewModel.initializeView()
    }
    .refreshable {
      await viewModel.initializeView()
    }
  }
}

struct RingDashProgressView: View {
  let progress: CGFloat
  
  private let bgColor = Color(.blue).opacity(0.2)
  private let fillColor = Color(.blue).opacity(0.4)
  
  var body: some View {
    Circle()
      .stroke(style: StrokeStyle(lineWidth: 50, lineCap: .butt, miterLimit: 0, dash: [10, 5], dashPhase: 0))
      .foregroundColor(bgColor)
      .overlay {
        Circle()
          .trim(from: 0, to: progress)
          .stroke(style: StrokeStyle(lineWidth: 50, lineCap: .butt, miterLimit: 0, dash: [10, 5], dashPhase: 0))
          .foregroundColor(fillColor)
      }
      .rotationEffect(.degrees(-90))
      .clipShape(Circle())
  }
}

#Preview {
  OfflineSavedLocationView()
}
