//
//  EverOrgTests.swift
//  EverOrgTests
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

import XCTest

@testable import EverOrg

class EverOrgTests: XCTestCase {

  let enexParser = EnexParser()

  override func setUp() {
    super.setUp()

    let testBundle = Bundle(for: type(of: self))
    let url = testBundle.url(forResource: "EverNoteExportTestData", withExtension: "enex")

    let xmlParser = XMLParser(contentsOf: url!)

    xmlParser?.delegate = enexParser
    xmlParser?.shouldResolveExternalEntities = true
    xmlParser?.parse()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testTags() {
    if let tags = enexParser.notes.first?.tags {
      XCTAssertEqual(tags.count, 4)
      XCTAssertTrue(tags.contains("tags"))
    } else { XCTFail() }
  }

  func testAttachment() {

    for note in enexParser.notes {

      guard note.title == "iPad memo" else {continue}
      if let attachment = note.body.first as? Attachment {
        XCTAssertEqual(attachment.hash, attachment.data?.hexString)
        return
      }
    }
    XCTFail()
  }

  func testImage() {
    if let image = enexParser.notes[2].body[6] as? Image {

      XCTAssertEqual(image.hash, image.data?.hexString)
      XCTAssertEqual(image.width, 91)
      XCTAssertEqual(image.alt, "https://api.travis-ci.org/mgmart/EverOrg.png")

    } else { XCTFail() }
  }

  func testLink() {
    for note in enexParser.notes {

      guard note.title == "mgmart/EverOrg" else {continue}

      for element in note.body {
        if let link = element as? Link {
          XCTAssertEqual(link.target, URL(string: "https://github.com/mgmart/EverOrg#everorg"))
          return
        }
      }
    }
    XCTFail()
  }

  func testIsTextPresent() {
    for note in enexParser.notes {
      if note.title == "iPad memo" {
        for element in note.body {
          if let text = element as? Plain,
            text.text == "Violets are violet" {
            return
          }
        }
      }
    }
    XCTFail()
  }

  func testTextMarkup() {
    for note in enexParser.notes {
      if note.title == "Another Note" {
        for element in note.body where element is Format{
          if let testObject = element as? Format {
            if testObject.format == .Strong {
              XCTAssertEqual(testObject.text, "more")
              return
            }
          }
        }
      }
    }
    XCTFail()
  }

  func testTables() {
    for note in enexParser.notes {

      guard note.title == "Tables and tables" else {continue}
      for element in note.body {
        if let table = element as? Table {
          XCTAssertEqual(table.rows.count, 4)
          XCTAssertEqual(table.rows.first?.fields.last?.content.first?.text, "Org mode")
          return
        }
      }
    }
    XCTFail()
  }

  func testCheckItems() {
    for note in enexParser.notes {

      guard note.title == "Another Note" else {continue}
      if let checkItem = note.body[17] as? CheckItem {
        XCTAssertTrue(checkItem.value)
        return
      }
    }
    XCTFail()
  }
}
