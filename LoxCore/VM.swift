//
//  VM.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

public struct VM {
  private var chunck: Chunck!
  private var pc: Int!
  private var stack: [Value] = []
  
  public init() {}
  
  public mutating func interpret(source: String) throws {
    Compiler().compile(source: source)
  }
  
  private mutating func run() throws {
    
    func readCode() -> OpCode? {
      guard pc < chunck.codes.count else {
        return nil
      }
      defer {
        pc += 1
      }
      return chunck.codes[pc]
    }
    
    while let instruction = readCode() {
      #if DEBUG
      print("          \(stack.map { "[ \($0) ]"}.joined())")
      print(chunck.disassemble(opcode: instruction))
      #endif
      switch instruction {
        case .constant(let value):
          stack.append(value)
        case .add:
          switch (stack.popLast(), stack.popLast()) {
            case (.double(let b), .double(let a)):
              stack.append(.double(a + b))
            default:
              throw LoxError.runtimeError(message: "Operand must be two numbers.")
          }
        case .subtract, .multiply, .divide:
          switch (stack.popLast(), stack.popLast()) {
            case (.double(let b), .double(let a)):
              if case .subtract = instruction {
                stack.append(.double(a - b))
              } else if case .multiply = instruction {
                stack.append(.double(a * b))
              } else if case .divide = instruction {
                stack.append(.double(a / b))
              }
            default:
              throw LoxError.runtimeError(message: "Operand must be two numbers.")
          }
        case .negate:
          guard case let .double(value) = stack.popLast() else {
            throw LoxError.runtimeError(message: "Operand must be a number.")
          }
          stack.append(.double(-value))
        case .return:
          if let value = stack.popLast() {
            print(value)
          }
      }
    }
  }
}
