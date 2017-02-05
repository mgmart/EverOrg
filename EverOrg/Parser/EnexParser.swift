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

  var topElement:[Evernote] = []
  var element: Evernote?
  var elementContent:String?

  override init() {
    print("Init")
    super.init()
  }

  // MARK: Parser Delegate

  func parserDidStartDocument(_ parser: XMLParser) {
    // print("start Document")
  }

  func parserDidEndDocument(_ parser: XMLParser) {
    // print("End Document: \(notes.count)")
    for note in notes {
      print(note.title)
    }
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
    guard let _ = Evernote(rawValue: elementName) else {
      print("Start Element not processed: \(elementName)")
      return
    }


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
      case .Mime:
        print("Mime: \(elementContent) for \(topElement.last)")
      case .Width:
        print("Width: \(elementContent) for \(topElement.last)")
      case .Height:
        print("Height: \(elementContent)for \(topElement.last)")
//      case .Duration:
//        print("Duration: \(elementContent)")
//      case .Timestamp:
//          print("Timestamp: \(elementContent)")

      case .Data:
        print("Data")
        break //print("Data: \(elementContent)")
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
    print("CDATA begins for: \(topElement.last)")

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
        group.leave()
      }
      group.wait()
    }

    print("CDATA ends for: \(topElement.last)")

  }

  func parser(_ parser: XMLParser, foundIgnorableWhitespace whitespaceString: String) {
    print("found whitespace: \"\(whitespaceString)\"")
  }
  func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
    print("Parse Error")
  }


  // MARK: Property Methods

  func createNewNote() -> Bool {
    if note == nil {
      note = Note()
      return true
    }
    print("Error: Trying to create a note whilst we're processing one already")
    return false
  }

  func addTitle() -> Bool {
    if note != nil {
      if let content = elementContent {
        note?.title = content
        print("Note Title: \(note?.title)")
      } else {
        note?.title = "[No Title found for Note]"
      }
      return true
    }
    print("Error: Trying to add a title to a nonexisting note")
    return false
  }

  func addCreated() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let date = time(from: currentElement) {
      note?.attributes.created = date
      return true
    } else {
      print("Error: Could not add created date")
      return false
    }
  }

  func addUpdated() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let date = time(from: currentElement) {
      note?.attributes.updated = date
      return true
    }
    print("Error: Could not add updated date")
    return false
  }

  func addLatitude() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let latitude = Double(currentElement) {
      note?.attributes.latitude = latitude
      return true
    }
    print("Error: Could not add latitude")
    return false
  }

  func addLongitude() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let longitude = Double(currentElement) {
      note?.attributes.longitude = longitude
      return true
    }
    print("Error: Could not add longitude")
    return false
  }

  func addAltitude() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let altitude = Double(currentElement) {
      note?.attributes.altitude = altitude
      return true
    }
    print("Error: Could not add altitude")
    return false
  }

  func addAuthor() -> Bool {
    if let currentElement = elementContent, note != nil {
      note?.attributes.author = currentElement
      return true
    }
    print("Error: Could not add author")
    return false
  }

  func addSource() -> Bool {
    if let currentElement = elementContent, note != nil,
      let source = Source(rawValue: currentElement) {

      note?.attributes.source = source
      return true
    }
    print("Error: Could not add source \(elementContent)")
    return false
  }

  func addReminderOrder() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let order = Int(currentElement) {
      note?.attributes.reminderOrder = order
      return true
    }
    print("Error: Could not add reminder order \(elementContent)")
    return false
  }

  func addNoteAttributes() -> Bool {
    if let currentElement = elementContent, note != nil {
      note?.attributes.noteAttributes = currentElement
      return true
    }
    print("Error: Could not add note attr \(elementContent)")
    return false
  }

  func addSourceURL() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let url = URL(string: currentElement) {
      note?.attributes.sourceURL = url
      return true
    }
    print("Error: Could not add source url")
    return false
  }

  func addWith() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let width = Int(currentElement) {
      print("Width = \(width) for \(topElement)")
      //      note?.attributes. = width
      return true
    }
    print("Error: Could not add width \(elementContent)")
    return false
  }

  func addHeight() -> Bool {
    if let currentElement = elementContent,
      note != nil,
      let order = Int(currentElement) {
      note?.attributes.reminderOrder = order
      return true
    }
    print("Error: Could not add height \(elementContent)")
    return false
  }

  func time(from string: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
    if let date = dateFormatter.date(from: string) {
      return date
    } else {
      return nil
    }
  }
}
