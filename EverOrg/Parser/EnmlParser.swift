//
//  EnmlParser.swift
//  EverOrg
//
//  Created by Mario Martelli on 04.02.17.
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

class EnmlParser: NSObject, XMLParserDelegate {

  enum Enml: String {
    case Media = "en-media"
    case Note = "en-note"
  }

  // TODO: There must be something already defined in SDK
  enum MediaItemType: String {
    case Pdf = "application/pdf"
    case Jpeg = "image/jpeg"
    case Png = "image/png"
  }

  var elementContent: String?
  var content: Content?

  var width: Int?
  var height: Int?

  func parserDidStartDocument(_ parser: XMLParser) {
    content = Content()
  }
  func parserDidEndDocument(_ parser: XMLParser) {
    // print("Content: \(content)")
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    if let currentElement = Enml(rawValue: elementName) {

      switch currentElement {
      case .Media:
        guard addMedia(attributeDict) else {
          parser.abortParsing()
          return
        }
       case .Note:
        for (rawkey, strValue) in attributeDict {
          switch rawkey {
          default:
            print("unprocessed key \(rawkey) with value \(strValue)")
          }
        }
      }
    } else {
      print("Element -> \(elementName)")
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    // print("Element -> \(elementName)")
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("ParseError")
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    print("ENML -> \(string)")
  }
}
