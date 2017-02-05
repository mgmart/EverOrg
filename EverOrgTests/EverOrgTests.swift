//
//  EverOrgTests.swift
//  EverOrgTests
//
//  Created by Mario Martelli on 05.02.17.
//  Copyright © 2017 Mario Martelli. All rights reserved.
//

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
}
