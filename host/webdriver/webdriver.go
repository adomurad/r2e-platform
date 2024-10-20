package webdriver

import (
	"bytes"
	"encoding/json"
	"fmt"
	"host/setup"
	"io"
	"net/http"
	"strconv"
	"strings"
)

const baseUrl = "http://localhost:9515"

type CreateSession_ResponseValue struct {
	SessionID string `json:"sessionId"`
}

type CreateSession_Response struct {
	Value CreateSession_ResponseValue `json:"value"`
}

type SessionOptions struct {
	// TODO - props like window-size, timeouts, etc passed down from the  Roc app
	Headless bool
}

func CreateSession(options SessionOptions) (string, error) {
	url := fmt.Sprintf("%s/session", baseUrl)
	paths, err := setup.GetChromePaths()
	if err != nil {
		return "", err
	}

	headlessSwtich := ""
	if options.Headless {
		headlessSwtich = ", \"--headless\""
	}

	// TODO parametrize this when passing more data from Roc app is possible
	jsonData := []byte(fmt.Sprintf(`{
		"capabilities": {
      "alwaysMatch": {
        "timeouts": {
          "implicit": 5000,
          "pageLoad": 10000,
          "script": 10000
        }
      },
			"firstMatch": [
				{
					"goog:chromeOptions": {
						"binary": "%s",
            "args": ["--window-size=1920,1080"%s]
					}
				}
			]
		}
	}`, paths.BrowserPath, headlessSwtich))

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

type GetScreenshot_Response struct {
	Value string `json:"value"`
}

func GetScreenshot(sessionId string) (string, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/screenshot", baseUrl, sessionId)

	var response GetScreenshot_Response

	err := makeHttpRequest("GET", requestUrl, nil, &response)
	if err != nil {
		return "", err
	}

	return response.Value, nil
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

type FindElements_Response struct {
	Value []FindElements_ResponseValue `json:"value"`
}

type FindElements_ResponseValue struct {
	ElementId string `json:"element-6066-11e4-a52e-4f735466cecf"`
}

func FindElements(sessionId, using, value string) ([]string, error) {
	url := fmt.Sprintf("%s/session/%s/elements", baseUrl, sessionId)

	reqBody := map[string]interface{}{
		"using": using,
		"value": value,
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	var response FindElements_Response
	err = makeHttpRequest("POST", url, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return nil, err
	}

	elementIds := make([]string, len(response.Value))
	for i, element := range response.Value {
		elementIds[i] = element.ElementId
	}

	return elementIds, nil
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

var keyMappings = map[string]string{
	"{enter}": "\uE007",
}

func replaceSpecialKeys(text string) string {
	for key, code := range keyMappings {
		text = strings.ReplaceAll(text, key, code)
	}
	return text
}

func ElementSendKeys(sessionId, elementId, text string) error {
	url := fmt.Sprintf("%s/session/%s/element/%s/value", baseUrl, sessionId, elementId)

	processedText := replaceSpecialKeys(text)

	reqBody := map[string]interface{}{
		"text": processedText,
	}

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

func ClearElement(sessionId, elementId string) error {
	url := fmt.Sprintf("%s/session/%s/element/%s/clear", baseUrl, sessionId, elementId)

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

type GetElementText_Response struct {
	Value string `json:"value"`
}

func GetElementText(sessionId, elementId string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/text", baseUrl, sessionId, elementId)

	var response GetElementText_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return "", err
	}

	return response.Value, nil
}

type GetElementAttribute_Response struct {
	Value *string `json:"value"`
}

func GetElementAttribute(sessionId, elementId, attrName string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/attribute/%s", baseUrl, sessionId, elementId, attrName)

	var response GetElementAttribute_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return "", err
	}

	if response.Value == nil {
		return "", nil
	}

	return *response.Value, nil
}

type GetElementProperty_Response struct {
	Value interface{} `json:"value"`
}

func GetElementProperty(sessionId, elementId, propName string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/property/%s", baseUrl, sessionId, elementId, propName)

	var response GetElementProperty_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return "", err
	}

	switch v := response.Value.(type) {

	case nil:
		return "", nil

	case string:
		return v, nil

	case bool:
		return strconv.FormatBool(v), nil

	case float64:
		return strconv.FormatFloat(v, 'f', -1, 64), nil

	default:
		return "", fmt.Errorf("unsuported element property type: %s", v)
	}
}

type IsElementSelected_Response struct {
	Value bool `json:"value"`
}

func IsElementSelected(sessionId, elementId string) (bool, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/selected", baseUrl, sessionId, elementId)

	var response IsElementSelected_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return false, err
	}

	return response.Value, nil
}

type WebDriverElementNotFoundError struct {
	Message string
}

func (e *WebDriverElementNotFoundError) Error() string {
	return fmt.Sprintf("WebDriverElementNotFoundError::%s", e.Message)
}

type WebDriverNotFoundResponseBody struct {
	Value WebDriverNotFoundResponseValue `json:"value"`
}

type WebDriverNotFoundResponseValue struct {
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
