package main

import (
	"fmt"
	"html"
	"io/fs"
	"os"
	"path/filepath"
	"strings"
)

func exitWithError(f string, args ...interface{}) {
	fmt.Printf(
		"\000message\037err: %s\n \000nonselectable\037true\n",
		fmt.Sprintf(f, args...),
	)
	os.Exit(1)
}

func main() {
	var rootDir string
	if args := os.Args[1:]; len(args) != 1 {
		exitWithError("invalid args count %d", len(args))
	} else {
		rootDir = args[0]
	}
	info, err := os.Stat(rootDir)
	if err != nil {
		exitWithError("%s", err.Error())
	}
	if !info.IsDir() {
		exitWithError("%#v is not a directory", rootDir)
	}

	if err := filepath.WalkDir(rootDir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if !d.IsDir() {
			baseName := filepath.Base(path)
			title := html.EscapeString(strings.TrimSuffix(baseName, filepath.Ext(baseName)))
			parentDir := filepath.Base(filepath.Dir(path))
			relativePath := strings.TrimSuffix(strings.TrimPrefix(filepath.Dir(path), rootDir), parentDir)
			meta := strings.Join(strings.Split(parentDir, "/"), ",")
			fmt.Printf("<b>%s</b>\r%s <i>%s</i>\000info\037%s\037meta\037%s\n", title, parentDir, relativePath, path, meta)
		}
		return nil
	}); err != nil {
		exitWithError("%s", err.Error())
	}
}
