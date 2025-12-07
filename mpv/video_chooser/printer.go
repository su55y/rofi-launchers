package main

import (
	"fmt"
	"html"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

const (
	errMsgFmt = "\000message\037err: %s\n \000nonselectable\037true\n"
	lineFmt   = "<b>%s</b>\r%s <i>%s</i>\000info\037%s\037meta\037%s\n"
)

func exitWithError(f string, args ...any) {
	fmt.Printf(errMsgFmt, fmt.Sprintf(f, args...))
	os.Exit(1)
}

func main() {
	if len(os.Args[1:]) != 1 {
		fmt.Printf("usage: %s ROOT_DIR\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	rootDir := os.Args[1]
	info, err := os.Stat(rootDir)
	if err != nil {
		exitWithError(err.Error())
	}
	if !info.IsDir() {
		exitWithError("%#v is not a directory", rootDir)
	}

	if err := filepath.WalkDir(rootDir, func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}
		baseName := filepath.Base(path)
		title := html.EscapeString(strings.TrimSuffix(baseName, filepath.Ext(baseName)))
		parentDir := filepath.Base(filepath.Dir(path))
		relativePath := strings.TrimSuffix(strings.TrimPrefix(filepath.Dir(path), rootDir), parentDir)
		meta := strings.Join(strings.Split(parentDir, "/"), ",")
		fmt.Printf(lineFmt, title, parentDir, relativePath, path, meta)
		return nil
	}); err != nil {
		exitWithError(err.Error())
	}
}
