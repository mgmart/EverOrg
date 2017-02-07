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

    // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testTags() {
    if let tags = enexParser.notes.first?.tags {
      XCTAssertEqual(tags.count, 4)
      XCTAssertTrue(tags.contains("tags"))
    } else {
      XCTFail()
    }
  }

  func testAttachment() {
    if let figure = enexParser.notes.last?.content?.body.first as? Figure,
      let attachment = figure.element as? Attachment {

      XCTAssertEqual(attachment.hash, attachment.data?.hexString)

    } else {
      XCTFail()
    }
  }
}
