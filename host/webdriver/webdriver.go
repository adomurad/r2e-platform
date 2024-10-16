package webdriver

import (
	"bytes"
	"encoding/json"
	"fmt"
	"host/setup"
	"io"
	"net/http"
)

const baseUrl = "http://localhost:9515"

type CreateSession_ResponseValue struct {
	SessionID string `json:"sessionId"`
}

type CreateSession_Response struct {
	Value CreateSession_ResponseValue `json:"value"`
}

func CreateSession() (string, error) {
	url := fmt.Sprintf("%s/session", baseUrl)
	paths, err := setup.GetChromePaths()
	if err != nil {
		return "", err
	}

	jsonData := []byte(fmt.Sprintf(`{
		"capabilities": {
			"firstMatch": [
				{
					"goog:chromeOptions": {
						"binary": "%s"
					}
				}
			]
		}
	}`, paths.BrowserPath))

	var response CreateSession_Response
	err = makeHttpRequest("POST", url, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return "", err
	}

	return response.Value.SessionID, nil
}

func DeleteSession(sessionId string) error {
	url := fmt.Sprintf("%s/session/%s", baseUrl, sessionId)

	err := makeHttpRequest[any]("DELETE", url, nil, nil)
	if err != nil {
		return err
	}

	return nil
}

func NavigateTo(sessionId, url string) error {
	requestUrl := fmt.Sprintf("%s/session/%s/url", baseUrl, sessionId)

	reqBody := map[string]interface{}{
		"url": url,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	err = makeHttpRequest[any]("POST", requestUrl, bytes.NewBuffer(jsonData), nil)
	if err != nil {
		return err
	}

	return nil
}

type GetStatus_ResponseValue struct {
	Ready bool `json:"ready"`
}

type GetStatus_Response struct {
	Value GetStatus_ResponseValue `json:"value"`
}

func GetStatus() (bool, error) {
	url := fmt.Sprintf("%s/status", baseUrl)

	var response GetStatus_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return false, err
	}

	return response.Value.Ready, nil
}

func makeHttpRequest[T any](method, url string, body *bytes.Buffer, result *T) error {
	var reqBody io.Reader
	if body != nil {
		reqBody = body
	} else {
		reqBody = nil
	}

	req, err := http.NewRequest(method, url, reqBody)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		body, _ := io.ReadAll(io.Reader(resp.Body))
		return fmt.Errorf("WebDriverRequest[%d]: %s", resp.StatusCode, body)
	}

	if result == nil {
		return nil
	}

	err = json.NewDecoder(resp.Body).Decode(result)
	if err != nil {
		return err
	}

	return nil
}
