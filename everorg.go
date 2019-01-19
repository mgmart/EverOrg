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
var (
	readFile       = ""
	attFolderExt   = "-attachments"
	attachmentPath = ""

	isMerged bool
)

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
		var fileExt string
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

	var value strings.Builder
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
				value.WriteString("[[./" + base + "/")
				value.WriteString(file + "]]")

			case "en-todo":

				switch getAttr("checked", node.Token) {
				case "true":
					value.WriteString("\n- [X] ")
				case "false":
					value.WriteString("\n- [ ] ")
				}
			}
		case html.StartTagToken:
			switch node.Token.Data {

			case "a":
				// We do not want links in the header
				if header == 0 {
					value.WriteString("[[" + getAttr("href", node.Token) + "][")
				}
			case "p":
				value.WriteString("\n")
			case "u":
				value.WriteString("_")
			case "i":
				value.WriteString("/")
			case "b", "strong", "em":
				value.WriteString("*")
			case "del":
				value.WriteString("+")
			case "h1":
				value.WriteString("\n** ")
				header++
			case "h2":
				value.WriteString("\n*** ")
				header++
			case "h3":
				value.WriteString("\n**** ")
				header++
			case "h4":
				value.WriteString("\n***** ")
				header++
			case "h5":
				value.WriteString("\n****** ")
				header++
			case "h6":
				value.WriteString("\n******* ")
				header++

				// These tags are ignored
			case "div", "span", "tr", "tbody", "abbr", "th", "thead", "ins", "img":
				break
			case "sup", "sub", "small", "br", "dl", "dd", "dt", "font", "colgroup", "cite":
				break
			case "address", "s", "map", "area", "center", "q":
				break

			case "hr":
				value.WriteString("\n------\n")
			case "en-media":
				base, file := mimeFiles(node.Token)
				value.WriteString("[[./" + base + "/")
				value.WriteString(file + "]]")
			case "table":
				table++
			case "td":
				value.WriteString("|")
			case "ol":
				list++
				listValue = append(listValue, 1)
			case "ul":
				list++
				listValue = append(listValue, 0)
			case "li":
				value.WriteString("\n")
				for i := 0; i <= list; i++ {
					value.WriteString("  ")
				}
				if list > 0 {
					switch listValue[list-1] {
					case 0:
						value.WriteString("- ")
					default:
						value.WriteString(fmt.Sprintf("%d.", listValue[list-1]))
						listValue[list-1] = listValue[list-1] + 1
					}
				}
			case "code":
				value.WriteString("~")
			case "pre":
				value.WriteString("\n#+BEGIN_SRC\n")
			case "blockquote":
				value.WriteString("\n#+BEGIN_QUOTE\n")

			default:
				fmt.Println("skip token: " + node.Token.Data)
				break
			}

		case html.EndTagToken:
			switch node.Token.Data {
			case "u":
				value.WriteString("_")
			case "i":
				value.WriteString("/")
			case "b", "strong", "em":
				value.WriteString("*")
			case "del":
				value.WriteString("+")
			case "a":
				if header == 0 {
					value.WriteString("]]")
				}
			case "h1", "h2", "h3", "h4", "h5", "h6":
				header--
			case "table":
				table--
			case "tr":
				value.WriteString("|\n")
			case "ol", "ul":
				list--
				listValue = listValue[:len(listValue)-1]
			case "code":
				value.WriteString("~")
			case "pre":
				value.WriteString("\n#+END_SRC\n")
			case "blockquote":
				value.WriteString("\n#+END_QUOTE\n")

			}
		}
		value.WriteString(node.Text)
	}
	return value.String()
}

func parseHTML(r io.Reader) Nodes {
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
	wordPtr := flag.String("input", "enex File", "relative path to enex file")

	flag.BoolVar(&isMerged, "merge", false, "whether to merge notes to single file")
	flag.Parse()
	if wordPtr == nil || *wordPtr == "" {
		panic("input file is missing")
	}
	fmt.Println("input:", *wordPtr)

	// Open the file given at commandline
	readFile = *wordPtr
	xmlFile, err := os.Open(readFile)

	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}

	defer func() { _ = xmlFile.Close() }()

	currentDir, fileName := filepath.Split(readFile)
	ext := filepath.Ext(readFile)
	baseName := strings.TrimSuffix(fileName, ext)

	newWrittenDir := filepath.Join(currentDir, baseName)
	// strings.TrimSuffix(readFile, ext)
	if _, err = os.Stat(newWrittenDir); os.IsNotExist(err) {
		os.Mkdir(newWrittenDir, 0711)
	}

	// Create Attachments Directory if not existent
	currentFilePathName := filepath.Join(newWrittenDir, baseName)

	attachmentPath = currentFilePathName + attFolderExt
	if _, err = os.Stat(attachmentPath); os.IsNotExist(err) {
		os.Mkdir(attachmentPath, 0711)
	}

	b, _ := ioutil.ReadAll(xmlFile)

	var q Query
	xml.Unmarshal(b, &q)

	var f *os.File
	// Parse the contained xml
	if isMerged {
		f, err = os.Create(currentFilePathName + ".org")

		fmt.Println("output: " + currentFilePathName + ".org")
		if err != nil {
			fmt.Errorf("err=%v", err)
			return
		}
		defer func() { _ = f.Close() }()
	}
	attachmentsCount := 0
	notesCount := 0

	for _, note := range q.Notes {

		cdata := []byte(note.Content)
		reader := bytes.NewReader(cdata)
		nodes := parseHTML(reader)

		if isMerged {
			f.WriteString(note.orgProperties())
			f.WriteString(nodes.orgFormat())
			f.Sync()
		} else {
			noteFileName := sanitize(note.Title) + "-" + note.Updated + ".org"
			newFile, err := os.Create(filepath.Join(newWrittenDir, noteFileName))
			if err != nil {
				continue
			}
			newFile.WriteString(note.orgProperties())
			newFile.WriteString(nodes.orgFormat())
			_ = newFile.Close()
		}

		notesCount++
		for _, attachment := range note.Resources {
			if attachment.Data.Encoding == "base64" {
				err = createAttachment(attachment, attachmentPath)
				if err == nil {
					attachmentsCount++
				}
			}
		}
	}

	if attachmentsCount == 0 {
		// remove attachment directory
		_ = os.Remove(attachmentPath)
		return
	}

	fmt.Printf("\nThere are %d notes and %d attachments created", notesCount, attachmentsCount)
}

func sanitize(title string) string {
	title = strings.TrimSpace(strings.ToLower(title))
	title = strings.Replace(title, "-", "", -1)
	title = strings.Replace(title, "'", "", -1)
	title = strings.Replace(title, "(", "", -1)
	title = strings.Replace(title, ")", "", -1)
	title = strings.Replace(title, ",", "", -1)
	title = strings.Replace(title, "|", "", -1)
	title = strings.Replace(title, "?", "", -1)

	title = strings.Replace(title, " ", "-", -1)

	return title
}

func createAttachment(attachment Resource, attachmentPath string) error {
	h := md5.New()
	sDec, _ := b64.StdEncoding.DecodeString(attachment.Data.Content)
	h.Write(sDec)
	filename := hex.EncodeToString(h.Sum(nil))
	ext, err := mime.ExtensionsByType(attachment.Mime)
	if err != nil {
		return err
	}

	var fileExt string
	if len(ext) > 0 {
		fileExt = ext[0]
	} else {
		fileExt = ".unknwn"
	}
	err = ioutil.WriteFile(attachmentPath+"/"+filename+fileExt, sDec, 0644)
	if err != nil {
		return err
	}

	return nil

}

func (note Note) orgProperties() string {
	var result strings.Builder
	attr := note.Attributes

	if isMerged {
		result.WriteString("\n* " + note.Title)
		if len(note.Tags) > 0 {
			result.WriteString("       ")
			for _, tag := range note.Tags {
				result.WriteString(":" + tag)
			}
			result.WriteString(":")
		}
		result.WriteString("\n")

		result.WriteString(":PROPERTIES:\n")
		if attr.Author != "" {
			result.WriteString(":AUTHOR: " + attr.Author + "\n")
		}
		if note.Created != "" {
			result.WriteString(":EVNT_CREATED: " + note.Created + "\n")
			result.WriteString(":EVNT_UPDATED: " + note.Updated + "\n")
		}
		if attr.Latitude > 0 {
			result.WriteString(fmt.Sprintf(":GEO_LAT: %f\n", attr.Latitude))
			result.WriteString(fmt.Sprintf(":GEO_LON: %f\n", attr.Longitude))
		}
		if attr.Source != "" {
			result.WriteString(":EVNT_SOURCE: " + attr.Source + "\n")
		}
		if attr.SourceUrl != "" {
			result.WriteString(":EVNT_SOURCEURL: " + attr.SourceUrl + "\n")
		}

		result.WriteString(":END:\n")
	} else {
		result.WriteString("#+TITLE: " + note.Title + "\n")
		result.WriteString("#+STARTUP: showall" + "\n")

		if attr.Author != "" {
			result.WriteString("#+AUTHOR: " + attr.Author + "\n")
		}
		if len(note.Tags) > 0 {
			result.WriteString("#+TAGS: ")
			result.WriteString(strings.Join(note.Tags, " ") + "\n")
		}
		if note.Created != "" {
			result.WriteString("#+DATE: " + note.Created + "\n")
		}
		if attr.Latitude > 0 {
			result.WriteString(fmt.Sprintf("#+LAT: %f\n", attr.Latitude))
			result.WriteString(fmt.Sprintf("#+LON: %f\n", attr.Longitude))
		}
		if attr.Source != "" {
			result.WriteString("#+SOURCE: " + attr.Source + "\n")
		}
		if attr.SourceUrl != "" {
			result.WriteString("#+DESCRIPTION: " + attr.SourceUrl + "\n")
		}
	}

	return result.String()
}
