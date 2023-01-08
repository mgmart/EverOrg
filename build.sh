TRGT=everorg-0.3

# Windows Intel
GOOS=windows GOARCH=amd64 go build -o everorg.exe
tar czf $TRGT-windows-amd64.tgz everorg.exe

# Windows Intel 386
GOOS=windows GOARCH=386 go build -o everorg.exe
tar czf $TRGT-windows-386.tgz everorg.exe

# Linux Intel
GOOS=linux GOARCH=amd64 go build -o everorg
tar czf $TRGT-linux-amd64.tgz everorg

# Linux ARM
GOOS=linux GOARCH=arm go build -o everorg
tar czf $TRGT-linux-arm.tgz everorg

# MacOS Intel
GOOS=darwin GOARCH=amd64 go build -o everorg
tar czf $TRGT-darwin-amd64.tgz everorg

# MacOS ARM 
GOOS=darwin GOARCH=arm64 go build -o everorg
tar czf $TRGT-darwin-arm64.tgz everorg



