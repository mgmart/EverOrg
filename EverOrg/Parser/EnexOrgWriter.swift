//
//  EnexOrgWriter.swift
//  EverOrg
//
//  Created by Mario Martelli on 11.02.17.
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
  func writeOrgFile(to: URL) {

    let fileManager = FileManager.default
    if let url = URL(string: "\(to.absoluteString)-Attachments") {
      do {
        try fileManager.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
      }
      catch let error as NSError {
        print("Ooops! Directory might already exist. Don't panic! \(error.localizedDescription)")
      }

      let orgFile = to.appendingPathExtension("org")
      if !fileManager.fileExists(atPath: orgFile.path) {
        fileManager.createFile(atPath: orgFile.path, contents: nil, attributes: nil)
      }

      do {
        let file = try FileHandle(forWritingTo: orgFile)
        for note in notes {
          note.detachAttachments(to: url)
          file.write(note.orgRepresentation.data(using: .utf8)!)
        }
      }
      catch let error as NSError {
        print("Ooops! Something went wrong: \(error.localizedDescription)")
      }
    }

  }
}
