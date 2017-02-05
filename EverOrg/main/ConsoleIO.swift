//
//  ConsoleIO.swift
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

struct ConsoleIO {

  func getOption(_ option: String) -> (option:OptionType, value: String) {
    return (OptionType(value: option), option)
  }

  static func printUsage() {
    let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent

    print("usage:")
    print("\(executableName) -a string1 string2")
    print("or")
    print("\(executableName) -p string")
    print("or")
    print("\(executableName) -h to show usage information")
    print("Type \(executableName) without an option to enter interactive mode.")
  }
}
