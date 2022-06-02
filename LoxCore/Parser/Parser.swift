//
//  Parser.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/31.
//

import Foundation

typealias PrefixParseFn = () throws -> Expression
typealias InfixParseFn = (_ left: Expression) throws -> Expression

fileprivate struct ParseRule {
  let prefix: PrefixParseFn?
  let infix: InfixParseFn?
  let precedence: Precedence
  
  init(precedence: Precedence, prefix: PrefixParseFn? = nil, infix: InfixParseFn? = nil) {
    self.prefix = prefix
    self.infix = infix
    self.precedence = precedence
  }
}

final class Parser {
  private let tokens: [Token]
  private var currentParseIndex = 0
  
  public init(tokens: [Token]) {
    self.tokens = tokens.isEmpty ? [Token(type: .EOF, line: 1, lexeme: "")] : tokens
  }
  
  private lazy var rules: [TokenType: ParseRule] = {
    [unowned self] in
    return [
      .LEFT_PAREN: ParseRule(precedence: .none, prefix: grouping),
      .MINUS: ParseRule(precedence: .term, prefix: unary, infix: binary),
      .PLUS: ParseRule(precedence: .term, infix: binary),
      .STAR: ParseRule(precedence: .factor, infix: binary),
      .SLASH: ParseRule(precedence: .factor, infix: binary),
      .NUMBER: ParseRule(precedence: .none, prefix: number)
    ]
  }()
  
  private func number() throws -> Expression {
    guard let _ = Double(previousToken!.lexeme) else {
      throw LoxError.parseError(message: "invalid number.", token: currentToken)
    }
    return .literal(previousToken!)
  }
  
  private func expression() throws -> Expression {
    return try parse(precedence: .assignment)
  }
  
  private func grouping() throws -> Expression {
    let expr = try expression()
    try consume(type: .RIGHT_PAREN, message: "Expect ')' after expression.")
    return .grouping(expr)
  }
  
  private func unary() throws -> Expression {
    let op = previousToken!
    let opType = op.type
    let right = try parse(precedence: .unary)
    switch opType {
      case .MINUS: return .unary(op: op, right: right)
      default: fatalError("cant reach here")
    }
  }
  
  private func binary(left: Expression) throws -> Expression {
    let op = previousToken!
    let opType = op.type
    guard let rule = rules[opType] else {
      throw LoxError.parseError(message: "invalid infix operator.", token: previousToken!)
    }
    // 只解析右侧比自己优先级更高的操作符，所以要+1
    let right = try parse(precedence: Precedence(rawValue: rule.precedence.rawValue + 1)!)
    switch opType {
      case .PLUS, .STAR, .SLASH, .MINUS: return .binary(left: left, op: op, right: right)
      default: fatalError("cant reach here")
    }
  }
  
  // 因为assignment的优先级是最低的，所以这方法其实就是求整个token序列表示的表达式
  func parse() throws -> Expression {
    let expr = try parse(precedence: .assignment)
    try consume(type: .EOF, message: "Expect end of expression.")
    return expr
  }
  
  // 解析>=指定优先级的一串token组成的表达式，直到碰到低优先级的token位置
  private func parse(precedence: Precedence) throws  -> Expression {
    func currentTokenPrecedent() -> Precedence {
      guard let currentPrecedence = rules[currentToken.type]?.precedence else {
        return .none
      }
      return currentPrecedence
    }
    advanceIndex()
    // 当前token的type对应的prefix
    // 求一元操作符的操作数或者二元操作符的左侧操作数
    guard let previousType = previousToken?.type,
          let prefix = rules[previousType]?.prefix else {
      throw LoxError.parseError(message: "Expect expression.", token: currentToken)
    }
    var left = try prefix()
    // 只关心右侧优先级不低于当前操作符的操作符
    while precedence.rawValue <= currentTokenPrecedent().rawValue {
      advanceIndex()
      if let infix = rules[previousToken!.type]?.infix {
        left = try infix(left)
      }
    }
    return left
  }
  
  // 当前指向的token是否满足types中的任意一个，如果满足则指针前进并返回true
  private func match(types: TokenType...) -> Bool {
    for type in types {
      if check(type: type) {
        advanceIndex()
        return true
      }
    }
    return false
  }
  
  private func check(type: TokenType) -> Bool {
    guard !isAtEnd else {
      return type == .EOF
    }
    return currentToken.type == type
  }
  
  @discardableResult
  private func consume(type: TokenType, message: String) throws -> Token? {
    guard check(type: type) else {
      throw LoxError.parseError(message: message, token: currentToken)
    }
    return advanceIndex()
  }
  
  private var isAtEnd: Bool {
    // 最后一个token为EOF，指向EOF及以后就算End
    return currentParseIndex >= tokens.count - 1
  }
  
  private var currentToken: Token {
    guard !isAtEnd else {
      return tokens.last!
    }
    return tokens[currentParseIndex]
  }
  
  private var previousToken: Token? {
    guard currentParseIndex > 0 else {
      return nil
    }
    return tokens[currentParseIndex - 1]
  }
  
  @discardableResult
  private func advanceIndex() -> Token? {
    guard !isAtEnd else {
      return nil
    }
    defer {
      currentParseIndex += 1
    }
    return tokens[currentParseIndex]
  }
}
