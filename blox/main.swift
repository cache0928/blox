//
//  main.swift
//  blox
//
//  Created by 徐才超 on 2022/5/28.
//

import Foundation
import LoxCore

var chunck = Chunck()
chunck.write(opcode: .constant(index: 0), line: 123)
chunck.add(constant: .double(1.2))
chunck.write(opcode: .return, line: 123)
print(chunck)
