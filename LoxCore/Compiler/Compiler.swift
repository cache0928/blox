//
//  Compiler.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

struct Compiler {
  func compile(source: String) throws -> Chunck {
    var chunck = Chunck()
    let scanner = Scanner(source: source)
    let parser = Parser(tokens: try scanner.scanTokens())
    let expr = try parser.parse()
    let opcodes = generate(from: expr)
    for code in opcodes {
      chunck.write(opcode: code)
    }
    chunck.write(opcode: .return(line: 1))
    return chunck
  }
  
  private func generate(from expr: Expression) -> [OpCode] {
    var opcodes: [OpCode] = []
    switch expr {
      case .unary(let op, let right):
        opcodes.append(contentsOf: generate(from: right))
        opcodes.append(.negate(line: op.line))
      case .binary(let left, let op, let right):
          opcodes.append(contentsOf: generate(from: left))
          opcodes.append(contentsOf: generate(from: right))
          switch op.type {
            case .MINUS: opcodes.append(.subtract(line: op.line))
            case .PLUS: opcodes.append(.add(line: op.line))
            case .STAR: opcodes.append(.multiply(line: op.line))
            case .SLASH: opcodes.append(.divide(line: op.line))
            default: fatalError("cant reach here")
          }      case .grouping(let expr):
        opcodes.append(contentsOf: generate(from: expr))
      case .literal(let token):
        if token.type == .NUMBER, let value = Double(token.lexeme) {
          opcodes.append(.constant(.double(value), line: token.line))
        } else {
          fatalError()
        }
    }
    return opcodes
  }
}
