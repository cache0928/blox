//
//  Expression.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/6/2.
//

import Foundation

indirect enum Expression {
  case unary(op: Token, right: Expression)
  case binary(left: Expression, op: Token, right: Expression)
  case grouping(_: Expression)
  case literal(_: Token)
}


extension Expression: CustomStringConvertible {
  var description: String {
    switch self {
      case .literal(let token):
        return token.lexeme
      case .grouping(let expr):
        return "(group \(expr.description))"
      case .binary(let left, let op, let right):
        return "(\(op.lexeme) \(left.description) \(right.description))"
      case .unary(let op, let right):
        return "(\(op.lexeme) \(right.description))"
    }
  }
}
