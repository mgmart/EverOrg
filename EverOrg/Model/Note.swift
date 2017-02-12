//
//  Note.swift
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

struct Note {

  struct Attributes {
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var author: String?
    var reminderOrder: Int?
    var reminderDoneTime: Date?
    var reminderTime: Date?
    var contentClass: String?
    var source: String?
    var sourceURL: URL?
    var applicationData: Data?
    var created: Date?
    var updated: Date?
    var noteAttributes: String?

    var orgRepresentation: String {
      var cont = latitude != nil ? ":GEO_LAT: \(latitude ?? 0)\n" : ""
      cont += longitude != nil ? ":GEO_LON: \(longitude ?? 0)\n" : ""
      cont += altitude != nil ? ":GEO_ALT: \(altitude ?? 0)\n" : ""
      cont += author != nil ? ":EVN_AUTHOR: \(author ?? "")\n" : ""
      cont += source != nil ? ":EVN_SOURCE: \(source ?? "")\n" : ""
      cont += sourceURL != nil ? ":EVN_SOURCE_URL: \(sourceURL?.absoluteString ?? "")\n" : ""
      cont += created != nil ? ":EVN_CREATED: \(created ?? Date())\n" : ""
      cont += updated != nil ? ":EVN:UPDATED: \(updated ?? Date())\n" : ""
      return cont
    }
  }


  var title: String
  var attributes: Attributes
  var body: [Element] = []
  var tags: [String] = []
  var fileName: String?

  init() {
    title = ""
    attributes = Attributes()
  }

  var orgRepresentation: String {
    var cont = "\n* \(title)"
    if tags.count > 0 {
      cont += "                :"
      for tag in tags {
        cont += "\(tag):"
      }
    }
    cont += "\n"
    cont += ":PROPERTIES:\n\(attributes.orgRepresentation):END:\n"
    for element in body {
      cont += element.orgRepresentation
    }
    return cont
  }

  func detachAttachments(to: URL) {

    for element in body {
      if let media = element as? Media {
        //        FileManager.default.createFile(atPath: to.absoluteString.removingPercentEncoding!, contents: media.data, attributes: nil)
       try! media.data?.write(to: to.appendingPathComponent(media.filename ))
      }
    }
  }
}
