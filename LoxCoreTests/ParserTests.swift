//
//  ParserTests.swift
//  LoxCoreTests
//
//  Created by 徐才超 on 2022/6/2.
//

import XCTest
@testable import LoxCore

class ParserTests: XCTestCase {
  func testParseArithmeticExpression() throws {
    let code = "(5 * (3 / 1)) + -1.2"
    let scanner = Scanner(source: code)
    let parser = Parser(tokens: try scanner.scanTokens())
    let expr = try parser.parse()
    XCTAssertEqual(expr.description, "(+ (group (* 5 (group (/ 3 1)))) (- 1.2))")
  }
}
