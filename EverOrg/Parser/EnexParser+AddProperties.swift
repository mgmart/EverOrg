//
//  EnexParser+AddProperties.swift
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

  func createNewNote() -> Bool {
    if note == nil {
      note = Note()
      return true
    }
    print("Error: Trying to create a note whilst we're processing one already")
    return false
  }


  func addData() -> Bool {
    // ENML Parser has prefilled attachment blocks with hashes
    // We have to find the corresponding hash and add the data
    if let body = note?.body,
      let data = Data(base64Encoded: elementContent!, options: .ignoreUnknownCharacters) {
      for (index, element) in body.enumerated() {

        // FIXME: That could be done much nicer
        if let attachment = element as? Attachment {
          if attachment.hash == data.hexString {
            note?.body[index] = Attachment(hash: attachment.hash, data: data)
          }
        }
        else if let image = element as? Image {
          if image.hash == data.hexString {
            note?.body[index] = Image(hash: image.hash, width: image.width, heigth: image.heigth, alt: image.alt, data: data)

          }
        }
      }
      return true
    }
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
    if let currentElement = elementContent, note != nil {

      note?.attributes.source = currentElement
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

  func addTag() -> Bool {
    if let currentElement = elementContent, note != nil {
      note?.tags.append(currentElement)
      return true
    }
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
