//
//  EnexParser+Content.swift
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

extension EnexParser {
  func addData() -> Bool {
    print("Data Size: \(elementContent?.characters.count)")

    // ENML Parser has prefilled attachment blocks with hashes
    // We have to find the corresponding hash and add the data
    if let body = note?.content?.body,
      let data = Data(base64Encoded: elementContent!, options: .ignoreUnknownCharacters) {
      for (index, block) in body.enumerated() {

        // FIXME: That could be done much nicer
        if let figure = block as? Figure {
          if let attachment = figure.element as? Attachment{
            if attachment.hash == data.hexString {
              note?.content?.body[index] = Figure(element: Attachment(hash: attachment.hash, data: data))
            }
          }
          else if let image = figure.element as? Image {
            if image.hash == data.hexString {
              note?.content?.body[index] = Figure(element: Image(hash: image.hash, width: image.width, heigth: image.heigth, alt: image.alt, data: data))

            }
          }
        }
      }
      return true
    }
    return false
  }
}

