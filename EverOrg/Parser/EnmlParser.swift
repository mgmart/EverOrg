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
    case TableRow = "tr"
    case TableField = "td"
    case Link = "a"
    case Paragraph = "p"
    case Span = "span"
    case HorizontalLine = "hr"
    case Division = "div"
    case Font = "font"
    case CheckItem = "en-todo"
  }

  var elementContent = ""
  var elementStack: [Element] = []


  var content: [Element] = []

  var tableContent: [TableRow]?
  var rowContent: [TableField]?
  var fieldContent: [Element]?


  var width: Int?
  var height: Int?

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
        tableContent = []
      case .TableRow:
        rowContent = []
      case .TableField:
        fieldContent = []
        
      case .Link:
        var link = (Link(target: nil, text: ""))

        for (rawkey, strValue) in attributeDict {
          if rawkey == "href" {
            link.target = URL(string: strValue)
          }
        }
        elementStack.append(link)


      case .Paragraph, .Span, .Font, .Division:
        elementStack.append(Plain(text: ""))
      case .HorizontalLine:
        break // FIXME: Ignored that for now.
      case .CheckItem:
        for (rawkey, strValue) in attributeDict {
          if rawkey == "checked" {
            if let status = Bool(strValue) {
              elementStack.append(CheckItem(text: "", value: status))
            } else {
              elementStack.append(CheckItem(text: "", value: false))
            }
          }
        }
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
      addContent(element: element)
    }

    else if let curElement = Enml(rawValue: elementName) {
      switch curElement {
      case .Link:
        if let link = elementStack.popLast() as? Link {
          let newLink = Link(target: link.target, text: link.text + elementContent)
          elementContent = ""
          addContent(element: newLink)
        }
      case .Paragraph, .Span, .Font, .Division:
        if let element = elementStack.popLast() as? Plain{
          let newPlain = Plain(text: element.text + elementContent)
          elementContent = ""
          addContent(element: newPlain)
        }
      case .TableField:
        if let tableFieldContent = fieldContent {
          let tableField = TableField(text: elementContent, content: tableFieldContent)
          rowContent?.append(tableField)
          elementContent = ""
          fieldContent = nil
        }
      case .TableRow:
        if let tableRowContent = rowContent {
          let tableRow = TableRow(text: elementContent, fields: tableRowContent)
          tableContent?.append(tableRow)
          elementContent = ""
          rowContent = nil
        }
      case .Table:
        if let thisTableContent = tableContent {
          let table = Table(text: elementContent, rows: thisTableContent)
          elementContent = ""
          tableContent = nil
          content.append(table)
        }
      case .CheckItem:
        if let element = elementStack.popLast() as? CheckItem{
          let checkItem = CheckItem(text: element.text + elementContent, value: element.value)
          elementContent = ""
          addContent(element: checkItem)
        }


      default:
        // TODO: Complete switch cases
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
