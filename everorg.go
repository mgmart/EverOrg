//
//  everorg.go
//  EverOrg
//
//  Created by Mario Martelli on 24.02.17.
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

package main

import (
	"encoding/xml"
	"fmt"
	"io/ioutil"
	"os"
)

type Query struct {
	Notes []Note `xml:"note"`
}

type Note struct {
	Title      string `xml:"title"`
	Content    string `xml:"content"`
	Created    string `xml:"created"`
	Updated    string `xml:"updated"`
	Attributes struct {
		Author    string  `xml:"author"`
		Latitude  float64 `xml:"latitude"`
		Longitude float64 `xml:"longitude"`
		Altitude  float64 `xml:"altitude"`
	} `xml:"note-attributes"`

	Resource struct {
		Data struct {
			Content  string `xml:",chardata"`
			Encoding string `xml:"encoding,attr"`
		} `xml:"data"`
	} `xml:"resource"`
	// Keywords map[string]bool
}

type Content struct {
	Spans []struct {
		Media []struct {
			Hash string `xml:"hash,attr"`
			Type string `xml:"type,attr"`
		} `xml:"en-media"`
	} `xml:"span"`
}

func (s Note) String() string {
	return fmt.Sprintf("-> %s - %f\n", s.Title, s.Attributes.Latitude)
}

func main() {

	// TODO: command line arguments parsing
	xmlFile, err := os.Open("everorg.enex")
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer xmlFile.Close()

	b, _ := ioutil.ReadAll(xmlFile)

	var q Query
	xml.Unmarshal(b, &q)
	fmt.Println(q.Notes)

	// Parse the contained xml
	cdata := []byte(q.Notes[0].Content)
	var cont Content
	xml.Unmarshal(cdata, &cont)
	fmt.Println(cont)
}
