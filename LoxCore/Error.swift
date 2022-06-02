//
//  Error.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

public enum LoxError: Error, CustomStringConvertible {
  case scanError(message: String, line: Int)
  case parseError(message: String, token: Token)
  case runtimeError(message: String)
  
  public var description: String {
    switch self {
      case .scanError(let message, let line):
        return "[line \(line)] Error: \(message)"
      case .parseError(let message, let token):
        return "[line \(token.line)] Error at \(token.type == .EOF ? "end" : "'\(token.lexeme)'"): \(message)"
      case .runtimeError(let message):
        return message
    }
  }
}
