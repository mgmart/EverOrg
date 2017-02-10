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
    case Table = "table"
    case Link = "a"
    case Paragraph = "p"
    case Span = "span"
    case HorizontalLine = "hr"
    case Division = "div"
    case Font = "font"
  }

  // TODO: There must be something already defined in SDK
  enum MediaItemType: String {
    case Pdf = "application/pdf"
    case Jpeg = "image/jpeg"
    case Png = "image/png"
    case Mp4 = "audio/x-m4a"
  }

  var elementContent = ""
  var content: [Element] = []
  var elementStack: [Element] = []
  var element:Element = Plain(text: "")

  var width: Int?
  var height: Int?

  var tableRows: [[String]]?

  func parserDidStartDocument(_ parser: XMLParser) {
  }
  func parserDidEndDocument(_ parser: XMLParser) {
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {

    if var element = elementStack.last,
      elementContent.characters.count > 0 {
      elementStack[elementStack.count - 1].text = element.text + elementContent
      elementContent = ""
    }

    if let formatType = FormatType(rawValue: elementName) {
      let newElement = Format(format: formatType, text: "")
      elementStack.append(newElement)
    }
    else if let currentElement = Enml(rawValue: elementName) {
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
            break
          }
        }
      case .Table:
        // Table Attributes are not usable within Org Mode
        tableRows = [[]]
      case .Link:
        var link = (Link(target: nil, text: ""))

        for (rawkey, strValue) in attributeDict {
          if rawkey == "href" {
            link.target = URL(string: strValue)
          }
        }
        elementStack.append(link)


      case .Paragraph, .Span, .Font:
        elementStack.append(Plain(text: ""))
      case .HorizontalLine, .Division:
        break // FIXME: Ignored that for now.
      }
    } else if FormatType(rawValue: elementName) == nil {
      for (rawkey, strValue) in attributeDict {
        switch rawkey {
        default:
          break;
        }
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

    if let elementType = FormatType(rawValue: elementName),
      let textElement = elementStack.popLast() as? Format {
      let element = Format(format: elementType, text: textElement.text + elementContent)
      elementContent = ""
      content.append(element)
    }

    else if let curElement = Enml(rawValue: elementName) {
      switch curElement {
      case .Link:
        if let link = elementStack.popLast() as? Link {
          let newLink = Link(target: link.target, text: link.text + elementContent)
          elementContent = ""
          content.append(newLink)
        }
      case .Paragraph, .Span, .Font:
        if let element = elementStack.popLast() as? Plain{
          let newPlain = Plain(text: element.text + elementContent)
          elementContent = ""
          content.append(newPlain)
        }
      default:
        break
      }
    } else {
      // print("Unprocessed ENML: \(elementName) with content \(elementContent)")
    }
    elementContent = ""
  }


  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("ParseError")
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    elementContent = elementContent + string
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("Found ignorable whitespace")
  }
}
