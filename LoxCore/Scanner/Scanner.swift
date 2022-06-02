//
//  Scanner.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

final class Scanner {
  private let source: String
  private var tokens: [Token] = []
  private var tokenStartIndex: String.Index
  private var currentScanIndex: String.Index
  private var line = 1
  
  public init(source: String) {
    self.source = source
    tokenStartIndex =  source.startIndex
    currentScanIndex = source.startIndex
  }
  
  public func scanTokens() throws -> [Token]  {
    repeat {
      tokenStartIndex = currentScanIndex
      try scanToken()
    } while !isAtEnd
    tokens.append(Token(type: .EOF, line: line, lexeme: ""))
    return tokens
  }
  
  private func scanToken() throws {
    guard let c = advanceIndex() else {
      // 到达文件末尾
      return
    }
    switch c {
      case "(",")","{","}",",",".","-","+",";","*", ":": addToken(type: TokenType(rawValue: String(c))!)
      case "!": addToken(type: match(expected: "=") ? TokenType(rawValue: "!=")! : TokenType(rawValue: "!")!)
      case "=": addToken(type: match(expected: "=") ? TokenType(rawValue: "==")! : TokenType(rawValue: "=")!)
      case "<": addToken(type: match(expected: "=") ? TokenType(rawValue: "<=")! : TokenType(rawValue: "<")!)
      case ">": addToken(type: match(expected: "=") ? TokenType(rawValue: ">=")! : TokenType(rawValue: ">")!)
      case "/":
        if (match(expected: "/")) {
          // 是注释的话直接消耗整行
          while currentCharacter != "\n" && !isAtEnd {
            advanceIndex()
          }
        } else if (match(expected: "*")) {
          try scanCStyleComments()
        } else {
          addToken(type: TokenType(rawValue: "/")!)
        }
      case "\"": try scanString()
      default:
        if c.isNewline {
          line += 1
        } else if c.isWhitespace {
          // 忽略空白
          break
        } else if c.isDigit {
          scanNumber()
        } else if c.isAlpha {
          scanIdentifier()
        } else {
          throw LoxError.scanError(message: "Unexpected character.", line: line)
        }
    }
  }
  
  private func match(expected: Character) -> Bool {
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
  private func advanceIndex() -> Character? {
    guard !isAtEnd else {
      return nil
    }
    let c = source[currentScanIndex]
    currentScanIndex = source.index(after: currentScanIndex)
    return c
  }
  
  private func scanString() throws {
    while currentCharacter != "\"" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    // 扫描到底都没发现下一个引号
    guard !isAtEnd else {
      throw LoxError.scanError(message: "Unterminated string.", line: line)
    }
    // tokenStartIndex此时指向开始的引号，currentScanIndex指向闭合引号
    tokenStartIndex = source.index(after: tokenStartIndex)
    addToken(type: .STRING)
    // 取出字面量后将指针移动至闭合引号的下一个字符
    advanceIndex()
  }
  
  private func scanNumber() {
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
    addToken(type: .NUMBER)
  }
  
  private func scanIdentifier() {
    while currentCharacter?.isAlphaNumberic == true {
      advanceIndex()
    }
    let str = String(source[tokenStartIndex ..< currentScanIndex])
    let tokenType = TokenType(rawValue: str) ?? .IDENTIFIER
    addToken(type: tokenType)
  }
  
  private func scanCStyleComments() throws {
    while currentCharacter != "*" && !isAtEnd {
      if currentCharacter == "\n" {
        line += 1
      }
      advanceIndex()
    }
    guard !isAtEnd else {
      throw LoxError.scanError(message: "Unterminated commment.", line: line)
    }
    advanceIndex()
    if match(expected: "/") {
      return
    } else {
      try scanCStyleComments()
    }
  }
  
  private func addToken(type: TokenType) {
    let text = source[tokenStartIndex ..< currentScanIndex]
    tokens.append(Token(type: type, line: line, lexeme: String(text)))
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
