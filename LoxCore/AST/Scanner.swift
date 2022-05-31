//
//  Scanner.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

struct Scanner: Sequence {
  let source: String
  
  func makeIterator() -> TokenIterator {
    return TokenIterator(source: source)
  }
}

struct TokenIterator: IteratorProtocol {
  let source: String
  private var tokenStartIndex: String.Index
  private var currentScanIndex: String.Index
  private var line = 1
  
  init(source: String) {
    self.source = source
    tokenStartIndex =  source.startIndex
    currentScanIndex = source.startIndex
  }
  
  mutating func next() -> Result<Token, Error>? {
    do {
      guard let token = try scanToken() else {
        return nil
      }
      return .success(token)
    } catch {
      return .failure(error)
    }
  }
  
  private mutating func scanToken() throws -> Token? {
    tokenStartIndex = currentScanIndex
    guard let c = advanceIndex() else {
      // 到达文件末尾
      return nil
    }
    switch c {
      case "(",")","{","}",",",".","-","+",";","*", ":": return makeToken(type: TokenType(rawValue: String(c))!)
      case "!": return makeToken(type: match(expected: "=") ? TokenType(rawValue: "!=")! : TokenType(rawValue: "!")!)
      case "=": return makeToken(type: match(expected: "=") ? TokenType(rawValue: "==")! : TokenType(rawValue: "=")!)
      case "<": return makeToken(type: match(expected: "=") ? TokenType(rawValue: "<=")! : TokenType(rawValue: "<")!)
      case ">": return makeToken(type: match(expected: "=") ? TokenType(rawValue: ">=")! : TokenType(rawValue: ">")!)
      case "/":
        if (match(expected: "/")) {
          // 是注释的话直接消耗整行
          while currentCharacter != "\n" && !isAtEnd {
            advanceIndex()
          }
          return try scanToken()
        } else if (match(expected: "*")) {
          try scanCStyleComments()
          return try scanToken()
        } else {
          return makeToken(type: TokenType(rawValue: "/")!)
        }
      case "\"": return try scanString()
      default:
        if c.isNewline {
          line += 1
          return try scanToken()
        } else if c.isWhitespace {
          // 忽略空白
          return try scanToken()
        } else if c.isDigit {
          return scanNumber()
        } else if c.isAlpha {
          return scanIdentifier()
        } else {
          throw LoxError.scanError(message: "Unexpected character", line: line)
        }
    }
  }
  
  private mutating func match(expected: Character) -> Bool {
    guard !isAtEnd else {
      return false
    }
    if source[currentScanIndex] != expected {
      return false
    }
    advanceIndex()
    return true
  }
  
  @discardableResult
  private mutating func advanceIndex() -> Character? {
    guard !isAtEnd else {
      return nil
    }
    let c = source[currentScanIndex]
    currentScanIndex = source.index(after: currentScanIndex)
    return c
  }
  
  private mutating func scanString() throws -> Token {
    while currentCharacter != "\"" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    // 扫描到底都没发现下一个引号
    guard !isAtEnd else {
      throw LoxError.scanError(message: "Unterminated string", line: line)
    }
    // 此操作前tokenStartIndex此时指向开始的引号，currentScanIndex指向闭合引号
    tokenStartIndex = source.index(after: tokenStartIndex)
    let token = makeToken(type: .STRING)
    // 取出字面量后将指针移动至闭合引号的下一个字符
    advanceIndex()
    return token
  }
  
  private mutating func scanNumber() -> Token {
    while currentCharacter?.isDigit == true {
      advanceIndex()
    }
    // 小数
    if currentCharacter == "." && nextCharacter?.isDigit == true {
      // 移过小数点，开始寻找小数位
      advanceIndex()
      while currentCharacter?.isDigit == true {
        advanceIndex()
      }
    }
    return makeToken(type: .NUMBER)
  }
  
  private mutating func scanIdentifier() -> Token {
    while currentCharacter?.isAlphaNumberic == true {
      advanceIndex()
    }
    let str = String(source[tokenStartIndex ..< currentScanIndex])
    let tokenType = TokenType(rawValue: str) ?? .IDENTIFIER
    return makeToken(type: tokenType)
  }
  
  private mutating func scanCStyleComments() throws {
    while currentCharacter != "*" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    guard !isAtEnd else {
      throw LoxError.scanError(message: "Unterminated comment", line: line)
    }
    advanceIndex()
    if match(expected: "/") {
      return
    } else {
      try scanCStyleComments()
    }
  }
  
  private mutating func makeToken(type: TokenType) -> Token {
    let text = source[tokenStartIndex ..< currentScanIndex]
    return Token(type: type, line: line, lexeme: String(text))
  }
  
  private var isAtEnd:  Bool  {
    return currentScanIndex >= source.endIndex
  }
  
  private var currentCharacter: Character? {
    guard !isAtEnd else {
      return nil
    }
    return source[currentScanIndex]
  }
  
  private var nextCharacter: Character? {
    guard currentScanIndex < source.index(before: source.endIndex) else {
      return nil
    }
    return source[source.index(after: currentScanIndex)]
  }
}
