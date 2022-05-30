//
//  Error.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/30.
//

import Foundation

enum LoxError: Error {
  case runtimeError(message: String)
}
