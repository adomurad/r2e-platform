package driversetup

import (
	"archive/zip"
	"fmt"
	"host/setup"
	"host/utils"
	"host/webdriver"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

// RunChromedriver runs the chromedriver and listens for crashes
func RunChromedriver() (*exec.Cmd, error) {
	paths, err := setup.GetChromePaths()
	if err != nil {
		return nil, err
	}

	// Create the command to run ./chromedriver
	cmd := exec.Command(paths.DriverPath)
	// cmd := exec.Command(paths.DriverPath, "--verbose")

	// cmd.Stdout = os.Stdout
	// cmd.Stderr = os.Stderr

	// Start the process in the background
	if err := cmd.Start(); err != nil {
		// log.Fatalf("Failed to start chromedriver: %v", err)
		return nil, err
	}

	// Log that the process has started
	// fmt.Println("Chromedriver started with PID:", cmd.Process.Pid)

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

func WaitForDriverReady(timeout time.Duration) error {
	startTime := time.Now()

	for {
		isReady, err := webdriver.GetStatus()
		if isReady {
			return nil
		}

		elapsed := time.Now().Sub(startTime)

		if elapsed > timeout {
			if err != nil {
				return fmt.Errorf("WebDriverSetupError: %w", err)
			} else {
				return fmt.Errorf("WebDriverSetupError: web driver did not start in time [%.1f s]", timeout.Seconds())
			}
		}

		time.Sleep(100 * time.Millisecond)
	}
}

// handleCleanup ensures chromedriver is killed when the app exits
func HandleCleanup(cmd *exec.Cmd) error {
	if cmd != nil && cmd.Process != nil {
		// Kill the process if it's running
		if err := cmd.Process.Kill(); err != nil {
			return err
		}
	}

	return nil
}

func DownloadChromeAndDriver() error {
	paths, err := setup.GetChromePaths()
	if err != nil {
		return err
	}

	if doesFileOrDirExist(paths.BrowserPath) && doesFileOrDirExist(paths.DriverPath) {
		// fmt.Println(utils.FG_BLUE + "Browser is ready" + utils.RESET)
		return nil
	}

	// fmt.Println("chrome or driver missing ")
	fmt.Println(utils.FG_BLUE + "Driver or/and Browser is/are missing..." + utils.RESET)
	fmt.Println(utils.FG_BLUE + "Downloading Driver and Browser." + utils.RESET)

	err = checkAndCreateDir(paths.DirPath)
	if err != nil {
		return err
	}
	// checkAndCreateDir(browserFilesDir)

	chromeUrl := fmt.Sprintf("https://storage.googleapis.com/chrome-for-testing-public/%s/%s/chrome-%s.zip", paths.BrowserVersion, paths.OsName, paths.OsName)
	driverUrl := fmt.Sprintf("https://storage.googleapis.com/chrome-for-testing-public/%s/%s/chromedriver-%s.zip", paths.BrowserVersion, paths.OsName, paths.OsName)

	// downloadFile("chrome.zip", chromeUrl)
	// fmt.Println("downloaded")
	err = downloadFile(fmt.Sprintf("%s.zip", paths.BrowserDirPath), chromeUrl)
	if err != nil {
		return err
	}
	err = downloadFile(fmt.Sprintf("%s.zip", paths.DriverDirPath), driverUrl)
	if err != nil {
		return err
	}

	err = unzip(fmt.Sprintf("%s.zip", paths.BrowserDirPath), fmt.Sprintf("%s/", paths.DirPath))
	if err != nil {
		return err
	}

	err = unzip(fmt.Sprintf("%s.zip", paths.DriverDirPath), fmt.Sprintf("%s/", paths.DirPath))
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
