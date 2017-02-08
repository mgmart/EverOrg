//
//  EnexParser.swift
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

class EnexParser: NSObject, XMLParserDelegate {

  enum Evernote: String {
    case EvernoteExport = "en-export"
    case Title = "title"
    case Note = "note"
    case Content = "content"
    case ContentClass = "content-class"
    // case Timestamp = "timestamp"
    case Created = "created"
    case Updated = "updated"
    case NoteAttributes = "note-attributes"
    case Resource = "resource"
    case ResourceAttributes = "resource-attributes"
    case SourceApplication = "source-application"
    case ReminderTime = "reminder-time"
    case ReminderOrder = "reminder-order"
    case ReminderDone = "reminder-done-time"
    case Latitude = "latitude"
    case Longitude = "longitude"
    case Altitude = "altitude"
    case Author = "author"
    case Data = "data"
    case Mime = "mime"
    case Width = "width"
    case Height = "height"
    // case Duration = "duration"
    case Filename = "file-name"
    case Recoginition = "recognition"
    case RecoginitionType = "reco-type"
    case Source = "source"
    case SourceURL = "source-url"
    case CameraModel = "camera-make"
    case ApplicationData = "application-data"
    case Tag = "tag"
    case SubjectDate = "subject-date"
    case Attachment = "attachment"
    case Classifications = "classifications"
  }

  var notes: [Note] = []
  var note:Note?
  // var content: Content?

  var topElement:[Evernote] = []
  var element: Evernote?
  var elementContent:String?

  public override init() {
    print("Init")
    super.init()
  }

  // MARK: Parser Delegate

  func parserDidStartDocument(_ parser: XMLParser) {
    print("start Document")
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    print("End Document: \(notes.count)")
    for note in notes {
      print(note.title)
    }
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    guard let _ = Evernote(rawValue: elementName) else {
      print("Start Element not processed: \(elementName)")
      return
    }

//    for (rawkey, strValue) in attributeDict {
//      print("Key: \(rawkey), Value: \(strValue)")
//    }

    // Put current element on stack
    if let top = Evernote(rawValue: elementName) {
      topElement.append(top)
    }

    elementContent = nil

    if let currentElement = Evernote(rawValue: elementName) {
      switch currentElement {
      case .Note:
        guard createNewNote() else {
          parser.abortParsing()
          return
        }
      default:
        break
      }
    }
    element = Evernote(rawValue: elementName)
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    guard let _ = Evernote(rawValue: elementName) else {
      print("End Element not processed: \(elementName)")
      return
    }

    // Remove current element from stack
    if let top = Evernote(rawValue: elementName),
      topElement.last == top {
      topElement.removeLast()
    }

    if let currentElement = Evernote(rawValue: elementName) {
      switch currentElement {
      case .Note:
        if let currentNote = note {
          notes.append(currentNote)
          note = nil
        }
      case .Title:
        guard addTitle() else {
          parser.abortParsing()
          return
        }
      case .Created:
        guard addCreated() else {
          parser.abortParsing()
          return
        }
      case .Updated:
        guard addUpdated() else {
          parser.abortParsing()
          return
        }
      case .Latitude:
        guard addLatitude() else {
          parser.abortParsing()
          return
        }
      case .Longitude:
        guard addLongitude() else {
          parser.abortParsing()
          return
        }
      case .Altitude:
        guard addAltitude() else {
          parser.abortParsing()
          return
        }
      case .Author:
        guard addAuthor() else {
          parser.abortParsing()
          return
        }
      case .Source:
        guard addSource() else {
          parser.abortParsing()
          return
        }
      case .SourceURL:
        guard addSourceURL() else {
          parser.abortParsing()
          return
        }
      case .ReminderOrder:
        guard addReminderOrder() else {
          parser.abortParsing()
          return
        }
      case .NoteAttributes:
        guard addNoteAttributes() else {
          parser.abortParsing()
          return
        }
      case .Tag:
        guard addTag() else {
          parser.abortParsing()
          return
        }
      case .Mime, .Width, .Height:
      // Already processed in CDATA block?
        break
      case .Data:
        guard addData() else {
          parser.abortParsing()
          return
        }
      case .Content:
        break
      default:
        print("Not processed: \(elementName)")
      }
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if let content = elementContent {
      elementContent = content + string
    } else {
      elementContent = string
    }
  }

  func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
    // print("CDATA begins for: \(topElement.last)")

    // Not sure if we should process recognition information
    if topElement.last != Evernote.Recoginition {

      // XMLParser is not reentrant capable. Need to dispatch async and wait immediately
      let group = DispatchGroup()
      group.enter()
      let myqueue = DispatchQueue(label: "de.schnuddelhuddel.myqueue", qos: .background,  target: nil)
      myqueue.async {
        let enmlParser = EnmlParser()
        let xmlParser = XMLParser(data: CDATABlock)
        xmlParser.delegate = enmlParser
        xmlParser.parse()
        self.note?.body = enmlParser.content
        group.leave()
      }
      group.wait()
    }
    // print("CDATA ends for: \(topElement.last)")
  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("found whitespace: \"\(whitespaceString)\"")
  }
  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("Parse Error")
  }

}

