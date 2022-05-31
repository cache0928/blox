//
//  File.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

extension Character {
  var isDigit: Bool {
    let numbers: ClosedRange<Character> = "0"..."9"
    return numbers.contains(self)
  }
  
  var isAlpha: Bool {
    let lowercase: ClosedRange<Character> = "a"..."z"
    let uppercase: ClosedRange<Character> = "A"..."Z"
    return lowercase.contains(self) || uppercase.contains(self) || self == "_"
  }
  
  var isAlphaNumberic: Bool {
    return isDigit || isAlpha
  }
}
