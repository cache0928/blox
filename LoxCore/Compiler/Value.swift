//
//  Value.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/27.
//

import Foundation

public enum Value {
  case double(_: Double)
}

extension Value: CustomStringConvertible {
  public var description: String {
    switch self {
      case .double(let value):
        return String(format: "%g", value)
    }
  }
}
