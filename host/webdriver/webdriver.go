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
	Headless        bool
	WindowSize      string
	ImplicitTimeout uint64
	PageLoadTimeout uint64
	ScriptTimeout   uint64
}

func CreateSession(options SessionOptions) (string, error) {
	url := fmt.Sprintf("%s/session", baseUrl)
	paths, err := setup.GetChromePaths()
	if err != nil {
		return "", err
	}

	binaryArgs := []string{
		"--window-size=" + options.WindowSize,
	}

	if options.Headless {
		binaryArgs = append(binaryArgs, "--headless")
	}

	reqBody := map[string]interface{}{
		"capabilities": map[string]interface{}{
			"alwaysMatch": map[string]interface{}{
				"timeouts": map[string]interface{}{
					"implicit": options.ImplicitTimeout,
					"pageLoad": options.PageLoadTimeout,
					"script":   options.ScriptTimeout,
				},
			},
			"firstMatch": []map[string]interface{}{
				{
					"goog:chromeOptions": map[string]interface{}{
						"binary": paths.BrowserPath,
						"args":   binaryArgs,
					},
				},
			},
		},
	}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return "", err
	}

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

func Reload(sessionId string) error {
	requestUrl := fmt.Sprintf("%s/session/%s/refresh", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

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

func NavigateBack(sessionId string) error {
	requestUrl := fmt.Sprintf("%s/session/%s/back", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

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

func NavigateForward(sessionId string) error {
	requestUrl := fmt.Sprintf("%s/session/%s/forward", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

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

func BrowserGetScreenshot(sessionId string) (string, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/screenshot", baseUrl, sessionId)

	var response GetScreenshot_Response

	err := makeHttpRequest("GET", requestUrl, nil, &response)
	if err != nil {
		return "", err
	}

	return response.Value, nil
}

type ExecuteJs_Response struct {
	Value interface{} `json:"value"`
}

func ExecuteJs(sessionId, jsString, argsString string) (string, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/execute/sync", baseUrl, sessionId)

	jsEscaped, err := json.Marshal(jsString)
	if err != nil {
		return "", err
	}

	jsonData := []byte(fmt.Sprintf(`{
		"script": %s,
    "args": %s
	}`, jsEscaped, argsString))

	var response ExecuteJs_Response
	err = makeHttpRequest("POST", requestUrl, bytes.NewBuffer(jsonData), &response)
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
		return "", fmt.Errorf("unsupported type: %s", v)
	}
}

// type PdfOptions struct {
// 	Page        PdfPageOptions
// 	Margin      PdfMarginOptions
// 	Scale       float64
// 	Orientation string
// 	ShrinkToFit bool
// 	Background  bool
// 	PageRages   []string
// }
// type PdfPageOptions struct {
// 	Width  float64
// 	Height float64
// }
// type PdfMarginOptions struct {
// 	Top    float64
// 	Bottom float64
// 	Left   float64
// 	Right  float64
// }
//
// type BrowserGetPdf_Response struct {
// 	Value string `json:"value"`
// }
//
// func BrowserGetPdf(sessionId string, pdfOptions PdfOptions) (string, error) {
// 	requestUrl := fmt.Sprintf("%s/session/%s/print", baseUrl, sessionId)
//
// 	jsonData, err := json.Marshal(pdfOptions)
// 	if err != nil {
// 		return "", err
// 	}
//
// 	var response BrowserGetPdf_Response
// 	err = makeHttpRequest("GET", requestUrl, bytes.NewBuffer(jsonData), &response)
// 	if err != nil {
// 		return "", err
// 	}
//
// 	return response.Value, nil
// }

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

type WindowRect struct {
	X      int64 `json:"x"`
	Y      int64 `json:"y"`
	Width  int64 `json:"width"`
	Height int64 `json:"height"`
}

type WindowRect_Response struct {
	Value WindowRect `json:"value"`
}

func SetWindowRect(sessionId string, rect WindowRect) (*WindowRect, error) {
	url := fmt.Sprintf("%s/session/%s/window/rect", baseUrl, sessionId)

	jsonData, err := json.Marshal(rect)
	if err != nil {
		return nil, err
	}

	var response WindowRect_Response
	err = makeHttpRequest("POST", url, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

func GetWindowRect(sessionId string) (*WindowRect, error) {
	url := fmt.Sprintf("%s/session/%s/window/rect", baseUrl, sessionId)

	var response WindowRect_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

func FullScreen(sessionId string) (*WindowRect, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/window/fullscreen", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	var response WindowRect_Response
	err = makeHttpRequest("POST", requestUrl, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

func Maximize(sessionId string) (*WindowRect, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/window/maximize", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	var response WindowRect_Response
	err = makeHttpRequest("POST", requestUrl, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

func Minimize(sessionId string) (*WindowRect, error) {
	requestUrl := fmt.Sprintf("%s/session/%s/window/minimize", baseUrl, sessionId)

	reqBody := map[string]interface{}{}

	jsonData, err := json.Marshal(reqBody)
	if err != nil {
		return nil, err
	}

	var response WindowRect_Response
	err = makeHttpRequest("POST", requestUrl, bytes.NewBuffer(jsonData), &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

type FindElement_Response struct {
	Value FindElement_ResponseValue `json:"value"`
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

func FindElementInElement(sessionId, elementId, using, value string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/element", baseUrl, sessionId, elementId)

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

type GetBrowserTitle_Response struct {
	Value string `json:"value"`
}

func GetBrowserTitle(sessionId string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/title", baseUrl, sessionId)

	var response GetBrowserTitle_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return "", err
	}

	return response.Value, nil
}

type GetBrowserUrl_Response struct {
	Value string `json:"value"`
}

func GetBrowserUrl(sessionId string) (string, error) {
	url := fmt.Sprintf("%s/session/%s/url", baseUrl, sessionId)

	var response GetBrowserUrl_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return "", err
	}

	return response.Value, nil
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

func FindElementsInElement(sessionId, elementId, using, value string) ([]string, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/elements", baseUrl, sessionId, elementId)

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

type IsElementDisplayed_Response struct {
	Value bool `json:"value"`
}

func IsElementDisplayed(sessionId, elementId string) (bool, error) {
	url := fmt.Sprintf("%s/session/%s/element/%s/displayed", baseUrl, sessionId, elementId)

	var response IsElementDisplayed_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return false, err
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

type Cookie struct {
	Name     string  `json:"name"`
	Value    string  `json:"value"`
	Domain   string  `json:"domain"`
	Path     string  `json:"path"`
	HttpOnly bool    `json:"httpOnly"`
	Secure   bool    `json:"secure"`
	SameSite string  `json:"sameSite"`
	Expiry   *uint32 `json:"expiry,omitempty"` // Unix Epoch Time
}

type AddCookie_Request struct {
	Cookie Cookie `json:"cookie"`
}

func AddCookie(sessionId string, cookie Cookie) error {
	url := fmt.Sprintf("%s/session/%s/cookie", baseUrl, sessionId)

	reqBody := AddCookie_Request{
		Cookie: cookie,
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

type GetCookie_Response struct {
	Value Cookie `json:"value"`
}

func GetCookie(sessionId, name string) (*Cookie, error) {
	url := fmt.Sprintf("%s/session/%s/cookie/%s", baseUrl, sessionId, name)

	var response GetCookie_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

func DeleteCookie(sessionId, name string) error {
	url := fmt.Sprintf("%s/session/%s/cookie/%s", baseUrl, sessionId, name)

	err := makeHttpRequest[any]("DELETE", url, nil, nil)
	if err != nil {
		return err
	}

	return nil
}

func DeleteAllCookies(sessionId string) error {
	url := fmt.Sprintf("%s/session/%s/cookie", baseUrl, sessionId)

	err := makeHttpRequest[any]("DELETE", url, nil, nil)
	if err != nil {
		return err
	}

	return nil
}

type GetAllCookies_Response struct {
	Value []Cookie `json:"value"`
}

func GetAllCookies(sessionId string) (*[]Cookie, error) {
	url := fmt.Sprintf("%s/session/%s/cookie", baseUrl, sessionId)

	var response GetAllCookies_Response
	err := makeHttpRequest("GET", url, nil, &response)
	if err != nil {
		return nil, err
	}

	return &response.Value, nil
}

type WebDriverNotFoundError struct {
	Message string
}

func (e *WebDriverNotFoundError) Error() string {
	return fmt.Sprintf("WebDriverNotFoundError::%s", e.Message)
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

		return &WebDriverNotFoundError{Message: responseBody.Value.Message}
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
