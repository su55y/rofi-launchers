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

type VideoFormatSet map[string]struct{}

var formats = make(VideoFormatSet)

func (s VideoFormatSet) Has(f string) bool {
	_, exists := s[f]
	return exists
}

func exitWithError(f string, args ...any) {
	fmt.Printf(errMsgFmt, fmt.Sprintf(f, args...))
	os.Exit(1)
}

func validateInput(args []string) []string {
	dirs := []string{}
	for _, v := range args {
		info, err := os.Stat(v)
		if err != nil {
			fmt.Printf(errMsgFmt, err.Error())
		} else if !info.IsDir() {
			fmt.Printf(errMsgFmt, fmt.Sprintf("%#v is not a directory", v))
		} else {
			dirs = append(dirs, v)
		}
	}
	return dirs
}

func walkDir(rootDir string) {
	if err := filepath.WalkDir(rootDir, func(path string, d fs.DirEntry, err error) error {
		if d.IsDir() {
			return nil
		}

		baseName := filepath.Base(path)
		ext := filepath.Ext(baseName)
		if !formats.Has(ext) {
			return nil
		}

		title := html.EscapeString(strings.TrimSuffix(baseName, ext))
		parentDir := filepath.Base(filepath.Dir(path))
		relativePath := strings.TrimSuffix(strings.TrimPrefix(filepath.Dir(path), rootDir), parentDir)
		meta := strings.Join(strings.Split(parentDir, "/"), ",")
		fmt.Printf(lineFmt, title, parentDir, relativePath, path, meta)
		return nil
	}); err != nil {
		exitWithError(err.Error())
	}
}

func main() {
	if len(os.Args) < 2 {
		fmt.Printf("usage: %s ROOT_DIR...\n", filepath.Base(os.Args[0]))
		os.Exit(1)
	}

	dirs := validateInput(os.Args[1:])

	for _, f := range []string{
		".mp4", ".mkv", ".webm", ".avi", ".ogv",
		".mpg", ".mpeg", ".3gp", ".mov", ".wmv",
		".flv", ".vob", ".mts", ".m2ts", ".ts",
		".swf", ".rm", ".rmvb", ".y4m", ".m4v"} {
		formats[f] = struct{}{}
	}

	for _, d := range dirs {
		walkDir(d)
	}
}
