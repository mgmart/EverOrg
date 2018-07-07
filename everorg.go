//
//  everorg.go
//  EverOrg
//
//  Created by Mario Martelli on 24.02.17.
//  Copyright © 2017 Mario Martelli. All rights reserved.
//
//  This file is part of EverOrg.
//
//  Everorg is free software: you can redistribute it and/or modify
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
	"crypto/md5"
	b64 "encoding/base64"
	"encoding/hex"
	"encoding/xml"
	"flag"
	"fmt"
	"io"
	"io/ioutil"
	"mime"
	"os"
	"path/filepath"
	"strings"

	"golang.org/x/net/html"
)

// Globals for filehandling
var readFile = ""
var attFolderExt = "-Attachments"
var attachmentPath = ""

// Get Attributes for html tag
func getAttr(attribute string, token html.Token) string {
	for _, attr := range token.Attr {
		if attr.Key == attribute {
			// a := ele.Data + attr.Val
			return attr.Val
		}
	}
	return ""
}

func mimeFiles(token html.Token) (string, string) {

	mimeType := getAttr("type", token)
	ext, err := mime.ExtensionsByType(mimeType)
	if err == nil {
		fileExt := ""
		if len(ext) > 0 {
			fileExt = ext[0]
		} else {
			fileExt = ".unknwn"
		}
		return filepath.Base(attachmentPath), getAttr("hash", token) + fileExt
	}
	return "", ""
}

// Org mode represantation of Node
func (nodes Nodes) orgFormat() string {

	value := ""
	header := 0
	table := 0
	list := 0
	listValue := []int{}

	for _, node := range nodes {
		switch node.Token.Type {

		case html.SelfClosingTagToken:
			switch node.Token.Data {
			case "en-media":
				base, file := mimeFiles(node.Token)
				value += "[[./" + base + "/"
				value += file + "]]"

			case "en-todo":

				switch getAttr("checked", node.Token) {
				case "true":
					value += "\n- [X] "
				case "false":
					value += "\n- [ ] "
				}
			}
		case html.StartTagToken:
			switch node.Token.Data {

			case "a":
				// We do not want links in the header
				if header == 0 {
					value += "[[" + getAttr("href", node.Token) + "]["
				}
			case "p":
				value += "\n"
			case "u":
				value += "_"
			case "i":
				value += "/"
			case "b", "strong", "em":
				value += "*"
			case "del":
				value += "+"
			case "h1":
				value += "\n** "
				header += 1
			case "h2":
				value += "\n*** "
				header += 1
			case "h3":
				value += "\n**** "
				header += 1
			case "h4":
				value += "\n***** "
				header += 1
			case "h5":
				value += "\n****** "
				header += 1
			case "h6":
				value += "\n******* "
				header += 1

				// These tags are ignored
			case "div", "span", "tr", "tbody", "abbr", "th", "thead", "ins", "img":
				break
			case "sup", "small", "br", "dl", "dd", "dt", "font", "colgroup", "cite":
				break
			case "address", "s", "map", "area", "center":
				break

			case "hr":
				value += "\n------\n"
			case "en-media":
				base, file := mimeFiles(node.Token)
				value += "[[./" + base + "/"
				value += file + "]]"
			case "table":
				table += 1
			case "td":
				value += "|"
			case "ol":
				list += 1
				listValue = append(listValue, 1)
			case "ul":
				list += 1
				listValue = append(listValue, 0)
			case "li":
				value += "\n"
				for i := 0; i <= list; i++ {
					value += "  "
				}
				if list > 0 {
					switch listValue[list-1] {
					case 0:
						value += "- "
					default:
						value += fmt.Sprintf("%d.", listValue[list-1])
						listValue[list-1] = listValue[list-1] + 1
					}
				}
			case "code":
				value += "~"
			case "pre":
				value += "\n#+BEGIN_SRC\n"
			case "blockquote":
				value += "\n#+BEGIN_QUOTE\n"

			default:
				println(node.Token.Data)
				break
			}

		case html.EndTagToken:
			switch node.Token.Data {
			case "u":
				value += "_"
			case "i":
				value += "/"
			case "b", "strong", "em":
				value += "*"
			case "del":
				value += "+"
			case "a":
				if header == 0 {
					value += "]]"
				}
			case "h1", "h2", "h3", "h4", "h5", "h6":
				header -= 1
			case "table":
				table -= 1
			case "tr":
				value += "|\n"
			case "ol", "ul":
				list -= 1
				listValue = listValue[:len(listValue)-1]
			case "code":
				value += "~"
			case "pre":
				value += "\n#+END_SRC\n"
			case "blockquote":
				value += "\n#+END_QUOTE\n"

			}
		}
		value += node.Text
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
		case html.StartTagToken:

			switch token.Data {

			case "en-note":
				break
			default:
				nodes = append(nodes, Node{token, ""})
			}

		case html.TextToken:
			nodes = append(nodes, Node{html.Token{}, html.UnescapeString(tokenValue)})

		case html.EndTagToken:
			nodes = append(nodes, Node{token, ""})

		case html.SelfClosingTagToken:
			if token.String() == "<br/>" || token.String() == "<hr/>" {
				nodes = append(nodes, Node{html.Token{}, "\n"})
			} else {
				nodes = append(nodes, Node{token, ""})
			}
		}
	}
}

func main() {

	// Commandline stuff
	wordPtr := flag.String("input", "enex File", "relative path to enex file")
	var svar string
	flag.StringVar(&svar, "svar", "bar", "a string var")
	flag.Parse()
	fmt.Println("input:", *wordPtr)

	// Open the file given at commandline
	readFile = *wordPtr
	xmlFile, err := os.Open(readFile)

	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}

	// Create Attachments Directory if not existent
	attachmentPath = strings.TrimSuffix(readFile, filepath.Ext(readFile)) + attFolderExt
	if _, err := os.Stat(attachmentPath); os.IsNotExist(err) {
		os.Mkdir(attachmentPath, 0711)
	}

	defer xmlFile.Close()
	b, _ := ioutil.ReadAll(xmlFile)

	var q Query
	xml.Unmarshal(b, &q)

	// Parse the contained xml
	orgFile := strings.TrimSuffix(readFile, filepath.Ext(readFile)) + ".org"
	f, err := os.Create(orgFile)
	defer f.Close()

	for _, note := range q.Notes {

		cdata := []byte(note.Content)
		reader := bytes.NewReader(cdata)
		nodes := parseHtml(reader)

		f.WriteString(note.orgProperties())
		f.WriteString(nodes.orgFormat())
		f.Sync()
		for _, attachment := range note.Resource {
			if attachment.Data.Encoding == "base64" {
				h := md5.New()
				sDec, _ := b64.StdEncoding.DecodeString(attachment.Data.Content)
				h.Write(sDec)
				filename := hex.EncodeToString(h.Sum(nil))
				ext, err := mime.ExtensionsByType(attachment.Mime)
				if err == nil {
					fileExt := ""
					if len(ext) > 0 {
						fileExt = ext[0]
					} else {
						fileExt = ".unknwn"
					}
					_ = ioutil.WriteFile(attachmentPath+"/"+filename+fileExt, sDec, 0644)
				}
			}
		}
	}
}

func (note Note) orgProperties() string {
	result := ""
	attr := note.Attributes

	result += "\n* " + note.Title // + "\n"

	if len(note.Tags) > 0 {
		result += "       "
		for _, tag := range note.Tags {
			result += ":" + tag
		}
		result += ":"
	}
	result += "\n"

	result += ":PROPERTIES:\n"
	if attr.Author != "" {
		result += ":AUTHOR: " + attr.Author + "\n"
	}
	if note.Created != "" {
		result += ":EVNT_CREATED: " + note.Created + "\n"
		result += ":EVNT_UPDATED: " + note.Updated + "\n"
	}
	if attr.Latitude > 0 {
		result += fmt.Sprintf(":GEO_LAT: %f\n", attr.Latitude)
		result += fmt.Sprintf(":GEO_LON: %f\n", attr.Longitude)
	}
	if attr.Source != "" {
		result += ":EVNT_SOURCE: " + attr.Source + "\n"
	}
	if attr.SourceUrl != "" {
		result += ":EVNT_SOURCEURL: " + attr.SourceUrl + "\n"
	}

	result += ":END:\n"
	return result
}
