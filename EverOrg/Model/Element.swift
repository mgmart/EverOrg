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
  case head1 = "h1"
  case head2 = "h2"
  case head3 = "h3"
  case head4 = "h4"
}

protocol Element {
  var text: String {get set}
  var orgRepresentation: String {get}
}

struct Link: Element {
  var target: URL?
  var text: String

  init(target: URL?, text: String) {
    self.target = target
    self.text = text
  }

  var linkText: String {
    if self.text.characters.count > 0 {
      return self.text
    } else {
      return " "
    }
  }

  var orgRepresentation: String {
    get {
      return "[[\(target?.absoluteString ?? "" )][\(linkText)]]"
    }
  }
}

struct Format: Element {

  var format: FormatType?
  var text: String

  var begin: String? {
    if let frmt = format {
      switch frmt {
      case .head1:
        return "\n** "
      case .head2:
        return "\n*** "
      case .head3:
        return "\n**** "
      case .head4:
        return "\n***** "
      case .Strong:
        return "*"
      case .Underlined:
        return "_"
      case .Italic:
        return "/"
      case .lineBreak:
        return "\n"
      default:
        return nil
      }
    }
    return nil
  }

  var end: String? {
    if let frmt = format {
      switch frmt {
      case .Strong:
        return "*"
      case .Underlined:
        return "_"
      case .Italic:
        return "/"
      case .head1, .head2, .head3, .head4:
        return "\n"
      default:
        return nil
      }
    }
    return nil
  }

  var orgRepresentation: String {
    if text.characters.count > 0 {
      return "\(begin ?? "")\(text)\(end ?? "")"
    } else {
      return ""
    }
  }
}

struct Plain: Element {
  var text: String

  init(text: String) {
    self.text = text
  }

  var orgRepresentation: String {
    get {
      return text
    }
  }
}

struct Table: Element{
  // we do not need table attributes for
  // Org mode. Content is sufficient
  var text: String
  var rows:[TableRow] = []

  var orgRepresentation: String {
    get {
      var cont = "\(text)\n"
      for element in rows {
        cont += element.orgRepresentation
      }
      return cont
    }
  }
}

struct CheckItem: Element {
  var text: String
  var value: Bool

  var orgRepresentation: String {
    get {
      switch value {
      case true:
        return "\n- [X] \(text)"
      case false:
        return "\n- [ ] \(text)"
      }
    }
  }
}

struct TableRow: Element {
  var text: String
  var fields: [TableField]

  var orgRepresentation: String {
    get {
      var cont = "|"
      for element in fields {
        cont += element.orgRepresentation
      }
      return " \(cont) \n"
    }
  }
}

struct TableField: Element {
  var text: String
  var content: [Element]

  var orgRepresentation: String {
    get {
      var cont = text
      for element in content {
        cont += element.orgRepresentation
      }
      return " \(cont) | "
    }
  }
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
  var text: String

  init(hash: String, width: Int, heigth: Int, alt: String?) {
    self.alt = alt
    self.hash = hash
    self.width = width
    self.heigth = heigth
    self.data = nil
    self.text = ""
  }

  init(hash: String, width: Int, heigth: Int, alt: String?, data: Data?) {
    self.hash = hash
    self.width = width
    self.heigth = heigth
    self.alt = alt
    self.data = data
    self.text = ""
  }

  var orgRepresentation: String {
    get {
      return "\n[[ I M A G E -- Please implement me]]\n"
    }
  }
}

struct Attachment: Media {
  var hash: String
  var data: Data?
  var type: String
  var text: String

  init(hash: String, data: Data?) {
    self.hash = hash
    self.data = data
    self.type = ""
    self.text = ""
  }

  init(hash: String) {
    self.init(hash: hash, data: nil)
  }

  var orgRepresentation: String {
    get {
      return "\n[[ A T T A C H M E N T -- Please implement me]]\n"
    }
  }
}

