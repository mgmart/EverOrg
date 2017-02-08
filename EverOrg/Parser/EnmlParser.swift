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
    case Headline1 = "h1"
    case Headline2 = "h2"
    case Headline3 = "h3"
    case Headline4 = "h4"
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
  var content: [Block] = []
  var block: Block?
  var paragraph = Paragraph(elements: [])
  var element: Element?

  var width: Int?
  var height: Int?

  var tableRows: [[String]]?

  func parserDidStartDocument(_ parser: XMLParser) {
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
      case .Table:
        // Table Attributes are not usable within Org Mode
          tableRows = [[]]
      case .Link:
        for (rawkey, strValue) in attributeDict {
          if rawkey == "href" {
            element = Link(target: URL(string: strValue), text: nil)
          }
          let text = Format(format: nil, text: elementContent)
          paragraph.elements.append(text)
          elementContent = ""
        }
      case .Paragraph, .Span, .Font:
        paragraph = Paragraph(elements: [])
      case .Headline1, .Headline2, .Headline3, .Headline4:
        block = Heading(elements: [], level: elementName)
      case .HorizontalLine, .Division:
        break // FIXME: Ignored that for now.
      }
    } else if FormatType(rawValue: elementName) == nil {
      print("Element -> \(elementName)")
      for (rawkey, strValue) in attributeDict {
        switch rawkey {
        default:
          print("unprocessed key \(rawkey) with value \(strValue)")
        }
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {

    if let elementType = FormatType(rawValue: elementName) {
      let element = Format(format: elementType, text: elementContent)
      paragraph.elements.append(element)
      elementContent = ""
    }
    else if let curElement = Enml(rawValue: elementName) {
      switch curElement {
      case .Link:
        if let link = element as? Link {
          paragraph.elements.append(Link(target: link.target, text: elementContent))
          elementContent = ""
        }
      case .Paragraph, .Span, .Font:
          paragraph.elements.append(Format(format: nil, text: elementContent))
          content.append(paragraph)
          elementContent = ""
      case.Headline1, .Headline2, .Headline3, .Headline4:
        if var headline = block as? Heading {
          paragraph.elements.append(Format(format: nil, text: elementContent))
          headline.elements.append(contentsOf: paragraph.elements)
          content.append(headline)
        }
      default:
        print("Unprocessed content: \(elementContent)")
      }
    } else {
      print("Unprocessed ENML: \(elementName) with content \(elementContent)")
    }
    elementContent = ""
    element = nil
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
