//
//  LoxCoreTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/5/28.
//

import XCTest
@testable import LoxCore

class ScannerTests: XCTestCase {
  func getScanResult(source: String) throws -> [Token] {
    let scanner = Scanner(source: source)
    return try scanner.scanTokens()
  }
  
  func testSingleCharTokenType() throws {
    let singleChars = ["(", ")", "{", "}", ",", ".", "-", "+", ";", "*", ":"]
    for char in singleChars {
      let result = try getScanResult(source: char)
      XCTAssertEqual(TokenType(rawValue: char)!, result.first?.type)
    }
  }
  
  func testOperatorTokenType() throws  {
    let operators = ["=", "==", "!", "!=", "<", "<=", ">", ">="]
    for `operator` in operators {
      let result = try getScanResult(source: `operator`)
      XCTAssertEqual(TokenType(rawValue: `operator`), result.first?.type)
    }
  }
  
  func testSlashTokenType() throws  {
    let result = try getScanResult(source: "/")
    XCTAssertEqual(result.first?.type, .SLASH)
  }
  
  func testDiscardComents() throws  {
    let result1 = try getScanResult(source: "//comments\n")
    XCTAssertTrue(result1.last?.type == .EOF)
    let result2 = try getScanResult(source: "//comments")
    XCTAssertTrue(result2.last?.type == .EOF)
  }
  
  func testIgnoreWhitespace() throws  {
    let result = try getScanResult(source: " \r\t")
    XCTAssertTrue(result.last?.type == .EOF)
  }
  
  func testLineisIncreased() throws  {
    let result = try getScanResult(source: "123\n123")
    XCTAssertEqual(result.last?.line, 2)
  }
  
  func testStringLiterals() throws  {
    let result = try getScanResult(source: "\"string\"")
    XCTAssertEqual(result.first?.type, .STRING)
    XCTAssertEqual(result.first?.lexeme, "string")
  }
  
  func testUnterminatedString() {
    XCTAssertThrowsError(try getScanResult(source: "\"string\n"))
  }
  
  func testNumberLiterals() throws  {
    let result1 = try getScanResult(source: "1234.56")
    XCTAssertEqual(result1.first?.type, .NUMBER)
    XCTAssertEqual(Double(result1.first?.lexeme ?? ""), 1234.56)
    let result2 = try getScanResult(source: "\"1000\"")
    XCTAssertEqual(result2.first?.type, .STRING)
    XCTAssertEqual(result2.first?.lexeme, "1000")
  }
  
  func testScanIndentifiers() throws  {
    let result = try getScanResult(source: "var tmp = 1000")
    XCTAssertEqual(result.map{$0.type}, [.VAR, .IDENTIFIER, .EQUAL, .NUMBER, .EOF])
  }
  
  func testCStyleComments() throws  {
    let result = try getScanResult(source: "/*\n***some comments***\n*/")
    XCTAssertTrue(result.last?.type == .EOF)
    XCTAssertThrowsError(try getScanResult(source: "/*\nsome comments\n*"))
  }
  
}
