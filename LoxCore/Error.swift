//
//  Error.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

public enum LoxError: Error, CustomStringConvertible {
  case scanError(message: String, line: Int)
  case compileError(message: String)
  case runtimeError(message: String)
  
  public var description: String {
    switch self {
      case .scanError(let message, let line):
        return "[line \(line)] Error: \(message)"
      case .compileError(let message):
        return message
      case .runtimeError(let message):
        return message
    }
  }
}
