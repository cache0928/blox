//
//  OpCode.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/27.
//

import Foundation

public enum OpCode {
  case constant(_: Value, line: Int)
  case add(line: Int)
  case subtract(line: Int)
  case multiply(line: Int)
  case divide(line: Int)
  case negate(line: Int)
  case `return`(line: Int)
  
  var line: Int {
    switch self {
      case .constant(_, let line),
           .add(let line),
           .subtract(let line),
           .multiply(let line),
           .divide(let line),
           .negate(let line),
           .return(let line):
        return line
    }
  }
}

extension OpCode: CustomStringConvertible {
  public var description: String {
    switch self {
      case .constant(_, _): return "OP_CONSTANT"
      case .add(_): return "OP_ADD"
      case .subtract(_): return "OP_SUBTRACT"
      case .multiply(_): return "OP_MULTIPLY"
      case .divide(_): return "OP_DIVIDE"
      case .negate(_): return "OP_NEGATE"
      case .return(_): return "OP_RETURN"
    }
  }
}
