//
//  OfflineSavedLocationView.swift
//  deepression
//
//  Created by 성대규 on 6/21/24.
//

import Foundation
import SwiftUI

struct OfflineSavedLocationView: View {
  let userDefaultManager = UserDefaultManager()
  let locationUpdateManager = LocationUpdateManager()
  @State private var savedLocations: [Location] = []
  @State private var progress: Double = 0
  
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
        
        RingDashProgressView(progress: progress)
          .frame(width: 250, height: 250)
        
        VStack {
          Text("\(savedLocations.count) 개")
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
        // 데이터 전송 코드
        // 기존에 저장된 데이터 삭제
        userDefaultManager.clearLocation()
        
        // 기존 데이터 모두 서버에 업로드 시도
        for (index, location) in savedLocations.enumerated() {
          locationUpdateManager.UpdateLocationToFireBase(location: location)
          progress = (index / savedLocations.count)
        }
      }
    }
    .onAppear {
      // 로딩이 완료되면 진행도를 0으로 초기화
      progress = (progress == 1) ? 0 : progress
      // UserDefault에서 [location] 받아오기
      savedLocations = userDefaultManager.getLocations() ?? []
    }
    .refreshable {
      // 로딩이 완료되면 진행도를 0으로 초기화
      progress = (progress == 1) ? 0 : progress
      // UserDefault에서 [location] 받아오기
      savedLocations = userDefaultManager.getLocations() ?? []
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
