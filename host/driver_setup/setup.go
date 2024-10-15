package driversetup

import (
	"archive/zip"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
)

// RunChromedriver runs the chromedriver and listens for crashes
func RunChromedriver() (*exec.Cmd, error) {
	paths, err := getChromePaths()
	if err != nil {
		return nil, err
	}

	// Create the command to run ./chromedriver
	cmd := exec.Command(paths.driverPath)

	// Start the process in the background
	if err := cmd.Start(); err != nil {
		log.Fatalf("Failed to start chromedriver: %v", err)
	}

	// Log that the process has started
	fmt.Println("Chromedriver started with PID:", cmd.Process.Pid)

	// Create a goroutine to wait for the process to exit or crash
	go func() {
		// Wait for the process to exit
		err := cmd.Wait()

		// If the process exits or crashes, handle it here
		if err != nil {
			fmt.Println("Chromedriver crashed:", err)
		} else {
			fmt.Println("Chromedriver exited normally")
		}
	}()

	return cmd, nil
}

// handleCleanup ensures chromedriver is killed when the app exits
func HandleCleanup(cmd *exec.Cmd) {
	if cmd != nil && cmd.Process != nil {
		// Kill the process if it's running
		if err := cmd.Process.Kill(); err != nil {
			fmt.Println("Failed to kill chromedriver:", err)
		} else {
			fmt.Println("Chromedriver killed successfully")
		}
	}
}

type BrowserPaths struct {
	browserVersion string
	osName         string
	dirPath        string
	browserPath    string
	browserDirPath string
	driverPath     string
	driverDirPath  string
}

func getChromePaths() (*BrowserPaths, error) {
	os := fmt.Sprintf("%s-%s", runtime.GOOS, runtime.GOARCH)
	fmt.Println("Detected OS: ", os)

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

	path := fmt.Sprintf("%s/%s/%s/", browserFilesDir, "chrome", chromeVersion)
	chromePath := fmt.Sprintf("%s/chrome-%s/chrome", path, osName)
	chromeDirPath := fmt.Sprintf("%s/chrome-%s", path, osName)
	driverPath := fmt.Sprintf("%s/chromedriver-%s/chromedriver", path, osName)
	driverDirPath := fmt.Sprintf("%s/chromedriver-%s", path, osName)

	return &BrowserPaths{
		browserVersion: chromeVersion,
		osName:         osName,
		dirPath:        path,
		browserPath:    chromePath,
		browserDirPath: chromeDirPath,
		driverPath:     driverPath,
		driverDirPath:  driverDirPath,
	}, nil
}

func DownloadChromeAndDriver() error {
	paths, err := getChromePaths()
	if err != nil {
		return err
	}

	if doesFileOrDirExist(paths.browserPath) && doesFileOrDirExist(paths.driverPath) {
		fmt.Println("browser already exists")
		return nil
	}

	fmt.Println("chrome or driver missing ")

	err = checkAndCreateDir(paths.dirPath)
	if err != nil {
		return err
	}
	// checkAndCreateDir(browserFilesDir)

	chromeUrl := fmt.Sprintf("https://storage.googleapis.com/chrome-for-testing-public/%s/%s/chrome-%s.zip", paths.browserVersion, paths.osName, paths.osName)
	driverUrl := fmt.Sprintf("https://storage.googleapis.com/chrome-for-testing-public/%s/%s/chromedriver-%s.zip", paths.browserVersion, paths.osName, paths.osName)

	// downloadFile("chrome.zip", chromeUrl)
	// fmt.Println("downloaded")
	err = downloadFile(fmt.Sprintf("%s.zip", paths.browserDirPath), chromeUrl)
	if err != nil {
		return err
	}
	err = downloadFile(fmt.Sprintf("%s.zip", paths.driverDirPath), driverUrl)
	if err != nil {
		return err
	}

	err = unzip(fmt.Sprintf("%s.zip", paths.browserDirPath), fmt.Sprintf("%s/", paths.dirPath))
	if err != nil {
		return err
	}

	err = unzip(fmt.Sprintf("%s.zip", paths.driverDirPath), fmt.Sprintf("%s/", paths.dirPath))
	if err != nil {
		return err
	}

	return nil
}

// Unzip function extracts a zip file to the specified destination folder
func unzip(src, dest string) error {
	// Open the zip file
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer r.Close()

	// Iterate through each file in the zip archive
	for _, file := range r.File {
		// Construct the full path for the destination
		filePath := filepath.Join(dest, file.Name)

		// If the file is a directory, create the directory
		if file.FileInfo().IsDir() {
			fmt.Println("Creating directory:", filePath)
			os.MkdirAll(filePath, os.ModePerm)
			continue
		}

		// If the file is a regular file, extract it
		if err := os.MkdirAll(filepath.Dir(filePath), os.ModePerm); err != nil {
			return err
		}

		destFile, err := os.OpenFile(filePath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, file.Mode())
		if err != nil {
			return err
		}

		srcFile, err := file.Open()
		if err != nil {
			destFile.Close()
			return err
		}

		// Copy the file contents to the destination file
		_, err = io.Copy(destFile, srcFile)

		// Close files
		destFile.Close()
		srcFile.Close()

		if err != nil {
			return err
		}
	}

	return nil
}

func doesFileOrDirExist(dir string) bool {
	_, err := os.Stat(dir)

	return err == nil
}

func checkAndCreateDir(dir string) error {
	// Check if the directory exists
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		// Create the directory
		err := os.MkdirAll(dir, os.ModePerm)
		if err != nil {
			return fmt.Errorf("could not create directory: %w", err)
		}
		fmt.Printf("Directory '%s' created.\n", dir)
	} else {
		fmt.Printf("Directory '%s' already exists.\n", dir)
	}
	return nil
}

// downloadFile will download a URL to a local file
func downloadFile(filepath string, url string) error {
	// return fmt.Errorf("wow")
	// Create the file
	out, err := os.Create(filepath)
	if err != nil {
		return err
	}
	defer out.Close()

	// Get the data
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	// Check for a successful response
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("failed to download file: %s", resp.Status)
	}

	// Write the body to file
	_, err = io.Copy(out, resp.Body)
	return err
}
