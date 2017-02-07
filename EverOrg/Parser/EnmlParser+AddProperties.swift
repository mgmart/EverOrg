//
//  EnmlParser+AddProperties.swift
//  EverOrg
//
//  Created by Mario Martelli on 07.02.17.
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

extension EnmlParser {

  func addMedia(_ attributes: Dictionary<String, String>) -> Bool {
    var hash: String?
    var type: String?
    for (rawkey, strValue) in attributes {
      switch rawkey {
      case "hash":
        hash = strValue
      case "type":
        type = strValue
      default:
        print("unprocessed key \(rawkey) with value \(strValue)")
      }
    }

    if let mediaHash = hash, let mediaType = type {
      switch mediaType {
      case "application/pdf":
        print("Hash = \(hash)")
        let element = Attachment(hash: mediaHash)
        let figure = Figure(element: element)
        content?.body.append(figure)
        return true
      default:
        print("media not processed: \(mediaType)")
        return false
      }
    }
    return false
  }
}
