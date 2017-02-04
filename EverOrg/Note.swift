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

enum Source: String {
  // TODO: Cases missing!
  case iPhone = "mobile.iphone"
  case web = "web.clip"
  case mac = "desktop.mac"
}

/*<!ELEMENT resource
(data, mime, width?, height?, duration?, recognition?, resource-attributes?,
  alternate-data?)
>*/

struct Resource {

  var data: Data?
  var mime: String?
  var width: Int?
  var height: Int?
  var duration: Int?
  // var recogniton: <- ignore that for the time being
  var alternateData: Data?
}

struct Attributes {
  var latitude: Double?
  var longitude: Double?
  var altitude: Double?
  var author: String?
  var reminderOrder: Int?
  var reminderDoneTime: Date?
  var reminderTime: Date?
  var contentClass: String?
  var source: Source?
  var sourceURL: URL?
  var applicationData: Data?
  var created: Date?
  var updated: Date?
  var noteAttributes: String?
}

struct Note {
  var title: String
  var attributes: Attributes
  var content: [Data]

  init() {
    title = ""
    attributes = Attributes()
    content = []
  }
}
