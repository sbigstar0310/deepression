//
//  DateFormatter.swift
//  deepression
//
//  Created by 성대규 on 6/18/24.
//

import Foundation

var fbDateFormatter: DateFormatter {
  let dateFormatter = DateFormatter()
  dateFormatter.locale = Locale(identifier: "ko_KR") // 한국 로케일 사용
  dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
  return dateFormatter
}
