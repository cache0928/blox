//
//  OpCode.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/27.
//

import Foundation

public enum OpCode {
  case constant(_: Value)
  case add
  case subtract
  case multiply
  case divide
  case negate
  case `return`
}

extension OpCode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .constant(_): return "OP_CONSTANT"
      case .add: return "OP_ADD"
      case .subtract: return "OP_SUBTRACT"
      case .multiply: return "OP_MULTIPLY"
      case .divide: return "OP_DIVIDE"
      case .negate: return "OP_NEGATE"
      case .return: return "OP_RETURN"
    }
  }
}
