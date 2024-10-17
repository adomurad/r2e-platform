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

type FindElement_Response struct {
	Value FindElement_ResponseValue
}

type FindElement_ResponseValue struct {
	ElementId string `json:"element-6066-11e4-a52e-4f735466cecf"`
}

func FindElement(sessionId, using, value string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/element", baseUrl, sessionId)

	reqBody := map[string]interface{}{
		"using": using,
		"value": value,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

	var response FindElement_Response
	err = makeHttpRequest("POST", url, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return "", err
	}

	return response.Value.ElementId, nil
}

func ClickElement(sessionId, elementId string) error {
	url := fmt.Sprintf("%s/session/%s/element/%s/click", baseUrl, sessionId, elementId)

	reqBody := map[string]interface{}{}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return err
	}

	err = makeHttpRequest[any]("POST", url, bytes.NewBuffer(jsonData), nil)
	if err != nil {
		return err
	}

	return nil
}

type WebDriverElementNotFoundError struct {
	// ShortError string
	Message string
}

func (e *WebDriverElementNotFoundError) Error() string {
	return fmt.Sprintf("WebDriverElementNotFoundError::%s", e.Message)
}

type WebDriverNotFoundResponseBody struct {
	Value WebDriverNotFoundResponseValue `json:"value"`
}

type WebDriverNotFoundResponseValue struct {
	// Error   string `json:"error"`
	Message string `json:"message"`
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

	if resp.StatusCode == 404 {
		var responseBody WebDriverNotFoundResponseBody
		err = json.NewDecoder(resp.Body).Decode(&responseBody)
		if err != nil {
			return err
		}

		return &WebDriverElementNotFoundError{Message: responseBody.Value.Message}
	}

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
