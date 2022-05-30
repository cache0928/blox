//
//  Chunck.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/27.
//

import Foundation

public struct Chunck {
  private(set) var codes: [OpCode] = []
  private(set) var lines: [Int] = []
  
  public init() {}
  
  public mutating func write(opcode: OpCode, line: Int) {
    codes.append(opcode)
    lines.append(line)
  }
}

extension Chunck: CustomStringConvertible {
  func disassemble(opcode: OpCode) -> String {
    switch opcode {
      case .constant(let value):
        return """
               \(String(format: "%@     ", opcode.description.padding(toLength: 16, withPad: " ", startingAt: 0))) '\(value.description)'
               """
      default:
        return opcode.description
    }
  }
  public var description: String {
    func line(index: Int) -> String {
      if index > 0 && lines[index] == lines[index - 1] {
        return "   |"
      } else {
        return String(format: "%4d", lines[index])
      }
    }
    return codes.enumerated().map {
      return "\(String(format: "%04d", $0.0)) \(line(index: $0.0)) \(disassemble(opcode: $0.1))"
    }.joined(separator: "\n")
  }
}
