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

struct Content {
  var data: Data?
  var mime: String?
  var width: Int?
  var height: Int?
  var duration: Int?
  // var recogniton: <- ignore that for the time being
  var alternateData: Data?
  var body: [String]
}

class EnmlParser: NSObject, XMLParserDelegate {

  var elementContent: String?
  var content: Content?

  func parserDidStartDocument(_ parser: XMLParser) {
    // print("Start Document")
  }
  func parserDidEndDocument(_ parser: XMLParser) {
    // print("End Document")
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    print("Element -> \(elementName)")
    for (rawkey, strValue) in attributeDict {
      print("Key: \(rawkey) Value \(strValue)")
//      let value = strValue
//      if let key = Coordinate(rawValue: rawkey) {
//        switch key {
//        case .Latitude:
//          coordinateBuffer.latitude = Double(value)!
//        // trackPoint.coord.latitude = Double(value)!
//        case .Longitude:
//          coordinateBuffer.longitude = Double(value)!
//          // trackPoint.coord.longitude = Double(value)!
//        }
      }
    }


  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    print("Element -> \(elementName)")
  }

  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("ParseError")
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    print("ENML -> \(string)")
  }

}
