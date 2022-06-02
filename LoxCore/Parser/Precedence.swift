//
//  Precedence.swift
//  LoxCore
//
//  Created by 徐才超 on 2022/5/31.
//

import Foundation

enum Precedence: UInt8, CaseIterable {
  case none
  case assignment  // =
  case or          // or
  case and         // and
  case equality    // == !=
  case comparison  // < > <= >=
  case term        // + -
  case factor      // * /
  case unary       // ! -
  case call        // . ()
  case primary
}
