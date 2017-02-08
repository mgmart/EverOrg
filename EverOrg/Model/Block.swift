//
//  Block.swift
//  EverOrg
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

import Foundation

enum BlockType {
  case Paragraph
  case Figure
  case List
}

enum ListType {
  case Numbered
  case Plain
  case Checkbox
}

protocol Block {
}

struct Heading: Block {
  var elements: [Element] // Text, Code, Markup
  var level:String
}

struct Paragraph: Block {
  var elements: [Element] // Text, Code, Markup
}

struct Figure: Block {
  var element:Element // Image or Attachment
}
