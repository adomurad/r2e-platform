package webdriver

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
)

func CreateSession() (string, error) {
	url := "http://localhost:9515/session"
	jsonData := []byte(`{
		"capabilities": {
			"firstMatch": [
				{
					"goog:chromeOptions": {
						"binary": "/home/arturd/Work/Roc/roc-platform-template-go/browser_files/chrome/117.0.5846.0/chrome-linux64/chrome"
					}
				}
			]
		}
	}`)

	// Create a new request using http.NewRequest
	req, err := http.NewRequest("POST", url, bytes.NewBuffer(jsonData))
	if err != nil {
		// fmt.Println("Error creating request:", err)
		return "", fmt.Errorf("could not create session: %w", err)
	}

	// Set the appropriate headers
	req.Header.Set("Content-Type", "application/json")

	// Make the request using http.Client
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		return "", fmt.Errorf("could not create session: %w", err)
	}
	defer resp.Body.Close()

	// Output the response status
	// Decode the response
	var response CreateSessionResponse
	err = json.NewDecoder(resp.Body).Decode(&response)
	if err != nil {
		fmt.Println("Error decoding response:", err)
		return "", fmt.Errorf("could not create session: %w", err)
	}

	// Output the sessionId
	// fmt.Println("Session ID:", response.Value.SessionID)
	return response.Value.SessionID, nil
}

// Define structs for the response
type CreateSessionResponseValue struct {
	SessionID string `json:"sessionId"`
}

type CreateSessionResponse struct {
	Value CreateSessionResponseValue `json:"value"`
}

func DeleteSession(sessionId string) error {
	url := fmt.Sprintf("http://localhost:9515/session/%s", sessionId)

	// Create a new request using http.NewRequest
	req, err := http.NewRequest("DELETE", url, nil)
	if err != nil {
		// fmt.Println("Error creating request:", err)
		return fmt.Errorf("could not create session: %w", err)
	}

	// Set the appropriate headers
	req.Header.Set("Content-Type", "application/json")

	// Make the request using http.Client
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		fmt.Println("Error making request:", err)
		return fmt.Errorf("could not create session: %w", err)
	}
	defer resp.Body.Close()

	// Output the response status
	// Decode the response
	// var response CreateSessionResponse
	// err = json.NewDecoder(resp.Body).Decode(&response)
	// if err != nil {
	// 	fmt.Println("Error decoding response:", err)
	// 	return "", fmt.Errorf("could not create session: %w", err)
	// }

	// Output the sessionId
	// fmt.Println("Session ID:", response.Value.SessionID)
	return nil
}
