package setup

import (
	"fmt"
	"runtime"
)

type BrowserPaths struct {
	BrowserVersion string
	OsName         string
	DirPath        string
	BrowserPath    string
	BrowserDirPath string
	DriverPath     string
	DriverDirPath  string
}

func GetChromePaths() (*BrowserPaths, error) {
	os := fmt.Sprintf("%s-%s", runtime.GOOS, runtime.GOARCH)

	browserFilesDir := "browser_files"
	chromeVersion := "117.0.5846.0"
	var osName string

	switch os {
	case "linux-amd64":
		osName = "linux64"
	case "darwin-arm64":
		osName = "mac-arm64"
	case "darwin-amd64":
		osName = "mac-x64"
	case "windows-386":
		osName = "win32"
	case "windows-amd64":
		osName = "win64"
	default:
		return nil, fmt.Errorf("Unsupported architecture")
	}

	chromeExecPath := getChromeExecutablePath()
	path := fmt.Sprintf("%s/%s/%s", browserFilesDir, "chrome", chromeVersion)
	chromePath := fmt.Sprintf("%s/chrome-%s/%s", path, osName, chromeExecPath)
	chromeDirPath := fmt.Sprintf("%s/chrome-%s", path, osName)
	driverPath := fmt.Sprintf("%s/chromedriver-%s/chromedriver", path, osName)
	driverDirPath := fmt.Sprintf("%s/chromedriver-%s", path, osName)

	return &BrowserPaths{
		BrowserVersion: chromeVersion,
		OsName:         osName,
		DirPath:        path,
		BrowserPath:    chromePath,
		BrowserDirPath: chromeDirPath,
		DriverPath:     driverPath,
		DriverDirPath:  driverDirPath,
	}, nil
}

func getChromeExecutablePath() string {
	switch runtime.GOOS {
	case "darwin":
		return "Google Chrome for Testing.app/Contents/MacOS/Google Chrome for Testing"
	case "linux":
		return "chrome"
	}

	return "chrome"
}
