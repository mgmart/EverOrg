//
//  Element.swift
//  EverOrg
//
//  Created by Mario Martelli on 05.02.17.
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

enum FormatType: String{
  case Strong = "b"
  case Italic = "i"
  case Underlined = "u"
  case lineBreak = "br"
  //  case Verbatim = "code"
  case Code = "code"
  //  case StrikeThrough
}


protocol Element {
}

struct Link: Element {
  var target: URL?
  var text: String?
}

struct Format: Element {
  var format: FormatType?
  var text: String?
}

struct Table: Element{
  // we do not need table attributes for
  // Org mode. Content is sufficient
  var rows:[[String]]
}

protocol Media: Element {
  var hash: String {get set}
  var data: Data? {get set}
}

struct Image: Media {
  var hash: String
  var width: Int
  var heigth: Int
  var alt: String?
  var data: Data?
}

struct Attachment: Media {
  var hash: String
  var data: Data?
  var type: String

  init(hash: String, data: Data?) {
    self.hash = hash
    self.data = data
    self.type = ""
  }

  init(hash: String) {
    self.init(hash: hash, data: nil)
  }
}

