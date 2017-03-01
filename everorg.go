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
	"bytes"
	"encoding/xml"
	"fmt"
	"io"
	"io/ioutil"
	"os"

	"golang.org/x/net/html"
)

func (s Note) String() string {
	return fmt.Sprintf("-> %s - %f\n", s.Title, s.Attributes.Latitude)
}

type Node struct {
	Token html.Token
	Text  string
}

type Nodes []Node

func getHref(token html.Token) string {
	for _, attr := range token.Attr {
		if attr.Key == "href" {
			// a := ele.Data + attr.Val
			return attr.Val
		}
	}
	return ""
}

func (nodes Nodes) orgFormat() string {

	value := ""
	header := 0

	for _, node := range nodes {
		// println("-->", node.Token.Type, node.Token.Data)
		switch node.Token.Type {

		case html.StartTagToken:
			switch node.Token.Data {
			case "a":

				if header == 0 {
					value += "[[" + getHref(node.Token) + "]["
				}
			case "p":
				value += "\n"
			case "u":
				value += "_"
			case "i":
				value += "/"
			case "b":
				value += "*"
			case "h1":
				value += "** "
				header += 1
			case "h2":
				value += "*** "
				header += 1
			case "h3":
				value += "**** "
				header += 1
			case "span", "tr", "tbody", "table":
				break
			case "td":
				value += "|"
			default:
				println("StartTag:", node.Token.Data)
			}

		case html.EndTagToken:
			switch node.Token.Data {
			case "u":
				value += "_"
			case "i":
				value += "/"
			case "b":
				value += "*"
			case "a":
				if header == 0 {
					value += "]]"
				}
			case "h1":
				header -= 1
			case "h2":
				header -= 1
			case "h3":
				header -= 1
			case "tr":
				value += "|\n"
			}
		}
		value += node.Text

		// for idx2, ele := range node.Tokens {
		// 	println("ELE:", idx1, ":", idx2, ":", ele.String())
		// 	println(ele.Data)
		// tokens += fmt.Sprintf("%s-", ele.Data)
		//		}
	}
	return value
}

func parseHtml(r io.Reader) Nodes {
	var nodes Nodes
	d := html.NewTokenizer(r)

	for {
		// token type
		tokenType := d.Next()
		if tokenType == html.ErrorToken {
			return nodes
		}

		token := d.Token()
		tokenValue := token.String()

		switch tokenType {
		case html.StartTagToken: // <tag>

			switch token.Data {
			// case "a":
			// 	nodes = append(nodes, Node{token, ""})

			case "div", "en-note":
				break
			default:
				//				println("stt", token.Data)
				nodes = append(nodes, Node{token, ""})
			}

		case html.TextToken:
			nodes = append(nodes, Node{html.Token{}, tokenValue})

		case html.EndTagToken:
			nodes = append(nodes, Node{token, ""})

		case html.SelfClosingTagToken:
			if token.String() == "<br/>" || token.String() == "<hr/>" {
				nodes = append(nodes, Node{html.Token{}, "\n"})
			} else {
				//				println("sct", token.Data)
				nodes = append(nodes, Node{token, ""})
			}
		}
	}
}

func main() {
	// TODO: command line arguments parsing
	xmlFile, err := os.Open("Resources/EverNoteExportTestData.enex")
	// xmlFile, err := os.Open("Resources/everorg.enex")

	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer xmlFile.Close()

	b, _ := ioutil.ReadAll(xmlFile)

	var q Query
	xml.Unmarshal(b, &q)
	// fmt.Println(q.Notes)

	// Parse the contained xml

	for _, note := range q.Notes {
		cdata := []byte(note.Content)
		reader := bytes.NewReader(cdata)

		nodes := parseHtml(reader)
		//		println("Calling pretty")
		println("*", note.Title)
		println(nodes.orgFormat())
		//		println("Called pretty")

	}
	//fmt.Println("Nodes:", nodes)
	//fmt.Println(string(cdata))
	//var cont Content
	// xml.Unmarshal(cdata, &cont)
	//fmt.Println(cont)

}
