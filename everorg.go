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

var readFile = ""
var attFolderExt = "-Attachments"
var attachmentPath = ""

func (s Note) String() string {
	return fmt.Sprintf("-> %s - %f\n", s.Title, s.Attributes.Latitude)
}

type Node struct {
	Token html.Token
	Text  string
}

type Nodes []Node

func getAttr(attribute string, token html.Token) string {
	for _, attr := range token.Attr {
		if attr.Key == attribute {
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
		switch node.Token.Type {

		case html.SelfClosingTagToken:
			mimeType := getAttr("type", node.Token)
			ext, err := mime.ExtensionsByType(mimeType)
			if err == nil {
				fileExt := ""
				if len(ext) > 0 {
					fileExt = ext[0]
				} else {
					fileExt = ".unknwn"
				}
				value += "[[./" + filepath.Base(attachmentPath) + "/"
				value += getAttr("hash", node.Token) + fileExt + "]]"
			}

		case html.StartTagToken:
			switch node.Token.Data {

			case "a":
				if header == 0 {
					value += "[[" + getAttr("href", node.Token) + "]["
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
				break
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
	fmt.Println("word:", *wordPtr)

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

		_, _ = f.WriteString("* " + note.Title + "\n")
		_, _ = f.WriteString(nodes.orgFormat())

		f.Sync()

		if note.Resource.Data.Encoding == "base64" {
			h := md5.New()
			sDec, _ := b64.StdEncoding.DecodeString(note.Resource.Data.Content)
			h.Write(sDec)
			filename := hex.EncodeToString(h.Sum(nil))
			ext, err := mime.ExtensionsByType(note.Resource.Mime)
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
