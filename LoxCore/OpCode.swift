//
//  OpCode.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/27.
//

import Foundation

public enum OpCode {
  case constant(index: UInt8)
  case `return`
}

extension OpCode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .return: return "OP_RETURN"
      case .constant(_): return "OP_CONSTANT"
    }
  }
}
