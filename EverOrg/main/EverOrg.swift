//
//  EverOrg.swift
//  EverOrg
//
//  Created by Mario Martelli on 03.02.17.
//  Copyright © 2017 Mario Martelli. All rights reserved.
//
//  This file is part of EverOrg.
//
//  Foobar is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  EverOrg is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with EverOrg.  If not, see <http://www.gnu.org/licenses/>.

import Foundation

enum OptionType: String {
  case inputFile = "i"
  case help = "h"
  case unknown

  init(value: String) {
    switch value {
    case "i": self = .inputFile
    case "h": self = .help
    default: self = .unknown
    }
  }
}

struct EverOrg {

  let consoleIO = ConsoleIO()

  func staticMode() {
    let argCount = CommandLine.argc
    let argument = CommandLine.arguments[1]
    let (option, _) = consoleIO.getOption(argument.substring(from: argument.characters.index(argument.startIndex, offsetBy: 1)))

    switch option {
    case .inputFile:
      if argCount != 3 {
        if argCount > 3 {
          print("Too many arguments for option \(option.rawValue)")
        } else {
          print("Too few arguments for option \(option.rawValue)")
        }
      } else {
        let fileName = CommandLine.arguments[2]
        let url = URL(fileURLWithPath: fileName)
        let xmlParser = XMLParser(contentsOf: url)
        let enexParser = EnexParser()
        xmlParser?.delegate = enexParser
        xmlParser?.shouldResolveExternalEntities = true
        xmlParser?.parse()
      }
    case .help:
      ConsoleIO.printUsage()
    case .unknown:
      ConsoleIO.printUsage()
    }
  }
}
