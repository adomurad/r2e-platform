package roc

// #include "app.h"
import "C"

import (
	"fmt"
	"host/driversetup"
	"host/setup"
	"host/utils"
	"host/webdriver"
	"os"
	"path/filepath"
	"strconv"
	"time"
	"unsafe"
)

type Options struct {
	SetupOnly               bool
	PrintBrowserVersionOnly bool
	Headless                bool
	Verbose                 bool
	DebugMode               bool
	TestNameFilter          string
}

var options = Options{
	SetupOnly:               false,
	PrintBrowserVersionOnly: false,
	Verbose:                 false,
	Headless:                false,
	DebugMode:               false,
	TestNameFilter:          "",
}

type OptionsFromUserApp struct {
	AssertTimeout          uint64
	PageLoadTimeout        uint64
	ScriptExecutionTimeout uint64
	ElementImplicitTimeout uint64
	WindowSize             string
}

type TestOverrides struct {
	AssertTimeout          *uint64
	PageLoadTimeout        *uint64
	ScriptExecutionTimeout *uint64
	ElementImplicitTimeout *uint64
	WindowSize             *string
}

var optionsFromUserApp = OptionsFromUserApp{
	// set by the UserApp in roc_fx_setTimeouts and roc_fx_setWindowSize
}

var testOverrides = TestOverrides{
	// overrides per test basis
}

func Main(cliOptions Options) int {
	options = cliOptions

	if options.PrintBrowserVersionOnly {
		fmt.Printf("%s", setup.BrowserVersion)
		return 0
	}

	err := driversetup.DownloadChromeAndDriver()
	if err != nil {
		fmt.Println(utils.FG_RED+"Setup failed with: "+utils.RESET, err)
		return 1
	}

	if options.SetupOnly {
		fmt.Println("Browser and driver ready.")
		return 0
	}

	cmd, err := driversetup.RunChromedriver()
	if err != nil {
		// todo
		fmt.Println("could not run chrome: ", err)
		return 1
	}

	err = driversetup.WaitForDriverReady(5 * time.Second)
	if err != nil {
		// todo
		fmt.Println("could not run chrome: ", err)
		return 1
	}

	size := C.roc__main_for_host_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	result := C.roc__main_for_host_1_exposed()

	// TODO - error handling
	err = driversetup.HandleCleanup(cmd)
	if err != nil {
		fmt.Println("could not kill chromedriver: ", err)
		return 1
	}

	return (*(*int)(unsafe.Pointer(&result)))
}

//export roc_fx_set_timeouts
func roc_fx_set_timeouts(assertTimeout, pageTimeout, scriptTimeout, implicitTimeout uint64) {
	optionsFromUserApp.AssertTimeout = assertTimeout
	optionsFromUserApp.PageLoadTimeout = pageTimeout
	optionsFromUserApp.ScriptExecutionTimeout = scriptTimeout
	optionsFromUserApp.ElementImplicitTimeout = implicitTimeout
}

//export roc_fx_set_assert_timeout_override
func roc_fx_set_assert_timeout_override(timeout uint64) {
	testOverrides.AssertTimeout = &timeout
}

//export roc_fx_set_page_load_timeout_override
func roc_fx_set_page_load_timeout_override(timeout uint64) {
	testOverrides.PageLoadTimeout = &timeout
}

//export roc_fx_set_script_timeout_override
func roc_fx_set_script_timeout_override(timeout uint64) {
	testOverrides.ScriptExecutionTimeout = &timeout
}

//export roc_fx_set_implicit_timeout_override
func roc_fx_set_implicit_timeout_override(timeout uint64) {
	testOverrides.ElementImplicitTimeout = &timeout
}

//export roc_fx_reset_test_overrides
func roc_fx_reset_test_overrides() {
	testOverrides = TestOverrides{}
}

//export roc_fx_set_window_size
func roc_fx_set_window_size(size *RocStr) {
	// make sure to make a copy of the str - this memory might be realocated
	bytesCopy := make([]byte, len(size.String()))
	copy(bytesCopy, []byte(size.String()))
	sizeCopy := string(bytesCopy)
	optionsFromUserApp.WindowSize = sizeCopy
}

//export roc_fx_set_window_size_override
func roc_fx_set_window_size_override(size *RocStr) {
	// make sure to make a copy of the str - this memory might be realocated
	bytesCopy := make([]byte, len(size.String()))
	copy(bytesCopy, []byte(size.String()))
	sizeCopy := string(bytesCopy)
	testOverrides.WindowSize = &sizeCopy
}

//export roc_fx_get_assert_timeout
func roc_fx_get_assert_timeout() uint64 {
	assertTimeout := optionsFromUserApp.AssertTimeout

	if testOverrides.AssertTimeout != nil {
		assertTimeout = *testOverrides.AssertTimeout
	}

	return assertTimeout
}

var testLogBucket = make([]string, 0)

func addLogToBucket(message string) {
	// make sure to make a copy of the str - this memory will be realocated
	bytesCopy := make([]byte, len(message))
	copy(bytesCopy, []byte(message))
	messageCopy := string(bytesCopy)

	testLogBucket = append(testLogBucket, messageCopy)
}

//export roc_fx_reset_test_log_bucket
func roc_fx_reset_test_log_bucket() {
	testLogBucket = make([]string, 0)
}

//export roc_fx_get_logs_from_bucket
func roc_fx_get_logs_from_bucket() C.struct_RocList {
	logs := testLogBucket
	return createRocListStr(logs)
}

//export roc_fx_get_test_name_filter
func roc_fx_get_test_name_filter() C.struct_RocStr {
	return createRocStr(options.TestNameFilter)
}

//export roc_fx_stdout_line
func roc_fx_stdout_line(msg *RocStr) {
	fmt.Println(msg)
	addLogToBucket(msg.String())
}

//export roc_fx_stdin_line
func roc_fx_stdin_line() C.struct_RocStr {
	var input string
	fmt.Scanln(&input)

	return createRocStr(input)
}

//export roc_fx_wait
func roc_fx_wait(timeout int64) {
	time.Sleep(time.Duration(time.Duration(timeout) * time.Millisecond))
}

//export roc_fx_start_session
func roc_fx_start_session() C.struct_ResultVoidStr {
	serverOptions := webdriver.SessionOptions{
		Headless:        options.Headless,
		WindowSize:      optionsFromUserApp.WindowSize,
		ImplicitTimeout: optionsFromUserApp.ElementImplicitTimeout,
		PageLoadTimeout: optionsFromUserApp.PageLoadTimeout,
		ScriptTimeout:   optionsFromUserApp.ScriptExecutionTimeout,
	}

	if testOverrides.WindowSize != nil {
		serverOptions.WindowSize = *testOverrides.WindowSize
	}

	if testOverrides.ElementImplicitTimeout != nil {
		serverOptions.ImplicitTimeout = *testOverrides.ElementImplicitTimeout
	}

	if testOverrides.PageLoadTimeout != nil {
		serverOptions.PageLoadTimeout = *testOverrides.PageLoadTimeout
	}

	if testOverrides.ScriptExecutionTimeout != nil {
		serverOptions.ScriptTimeout = *testOverrides.ScriptExecutionTimeout
	}

	sessionId, err := webdriver.CreateSession(serverOptions)

	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, sessionId)
	}
}

//export roc_fx_delete_session
func roc_fx_delete_session(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.DeleteSession(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, "")
	}
}

//export roc_fx_browser_get_screenshot
func roc_fx_browser_get_screenshot(sessionId *RocStr) C.struct_ResultVoidStr {
	screenshotBase64, err := webdriver.BrowserGetScreenshot(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, screenshotBase64)
	}
}

//export roc_fx_execute_js
func roc_fx_execute_js(sessionId, jsString, argsStr *RocStr) C.struct_ResultVoidStr {
	result, err := webdriver.ExecuteJs(sessionId.String(), jsString.String(), argsStr.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, result)
	}
}

// //export roc_fx_browserGetPdf
// func roc_fx_browserGetPdf(sessionId *RocStr, width, height, top, bottom, left, right, scale float64, orientationStr *RocStr, shrinkToFit, background int64, pageRanges *RocList[RocStr]) C.struct_ResultVoidStr {
// 	shrinkToFitBool := false
// 	if shrinkToFit == 1 {
// 		shrinkToFitBool = true
// 	}
//
// 	backgroundBool := false
// 	if background == 1 {
// 		backgroundBool = true
// 	}
//
// 	goSlice := pageRanges.List()
// 	pageRangesArr := make([]string, len(goSlice))
// 	for i, rocStr := range goSlice {
// 		pageRangesArr[i] = rocStr.String()
// 	}
//
// 	pdfOptions := webdriver.PdfOptions{
// 		Page: webdriver.PdfPageOptions{
// 			Width:  width,
// 			Height: height,
// 		},
// 		Margin: webdriver.PdfMarginOptions{
// 			Top:    top,
// 			Bottom: bottom,
// 			Left:   left,
// 			Right:  right,
// 		},
// 		Scale:       scale,
// 		Orientation: orientationStr.String(),
// 		ShrinkToFit: shrinkToFitBool,
// 		Background:  backgroundBool,
// 		PageRages:   pageRangesArr,
// 	}
//
// 	screenshotBase64, err := webdriver.BrowserGetPdf(sessionId.String(), pdfOptions)
// 	if err != nil {
// 		return createRocResultStr(RocErr, err.Error())
// 	} else {
// 		return createRocResultStr(RocOk, screenshotBase64)
// 	}
// }

//export roc_fx_browser_set_window_rect
func roc_fx_browser_set_window_rect(sessionId *RocStr, disciminant, x, y, width, height int64) C.struct_ResultListStr {
	rect := webdriver.WindowRect{}

	switch disciminant {
	case 1: // Move
		rect.X = x
		rect.Y = y

	case 2: // Resize
		rect.Width = width
		rect.Height = height

	case 3: // MoveAndResize
		rect.X = x
		rect.Y = y
		rect.Width = width
		rect.Height = height
	}

	newRect, err := webdriver.SetWindowRect(sessionId.String(), rect)
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browser_get_window_rect
func roc_fx_browser_get_window_rect(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.GetWindowRect(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_element_get_rect
func roc_fx_element_get_rect(sessionId, elementId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.GetElementRect(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		// FIXME, don't know how to return 2 ints and 2 floats to Roc
		// for know this is skechy but should not cause any problem
		rectList := []float64{newRect.X, newRect.Y, float64(newRect.Width), float64(newRect.Height)}
		return createRocResult_ListF64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browser_maximize
func roc_fx_browser_maximize(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.Maximize(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browser_minimize
func roc_fx_browser_minimize(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.Minimize(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browser_full_screen
func roc_fx_browser_full_screen(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.FullScreen(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browser_navigate_back
func roc_fx_browser_navigate_back(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateBack(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browser_navigate_forward
func roc_fx_browser_navigate_forward(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateForward(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browser_reload
func roc_fx_browser_reload(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.Reload(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browser_navigate_to
func roc_fx_browser_navigate_to(sessionId, url *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateTo(sessionId.String(), url.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_switch_to_frame_by_element_id
func roc_fx_switch_to_frame_by_element_id(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.SwitchToFrameByElementId(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_switch_to_parent_frame
func roc_fx_switch_to_parent_frame(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.SwitchToParenFrame(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_alert_accept
func roc_fx_alert_accept(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.AlertAccept(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_alert_dismiss
func roc_fx_alert_dismiss(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.AlertDismiss(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_alert_get_text
func roc_fx_alert_get_text(sessionId *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.AlertGetText(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_alert_send_text
func roc_fx_alert_send_text(sessionId, text *RocStr) C.struct_ResultVoidStr {
	err := webdriver.AlertSendText(sessionId.String(), text.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browser_find_element
func roc_fx_browser_find_element(sessionId, using, value *RocStr) C.struct_ResultVoidStr {
	elementId, err := webdriver.FindElement(sessionId.String(), using.String(), value.String())
	// if notFoundError, ok := err.(*webdriver.WebDriverNotFoundError); ok {
	//    return createRocResultStr(RocErr, fmt.Sprintf("WebDriverNotFoundError::"))
	// }
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, elementId)
}

//export roc_fx_browserFindElements
func roc_fx_browserFindElements(sessionId, using, value *RocStr) C.struct_ResultListStr {
	elementIds, err := webdriver.FindElements(sessionId.String(), using.String(), value.String())
	if err != nil {
		return createRocResult_ListStr_Str(RocErr, nil, err.Error())
	}

	return createRocResult_ListStr_Str(RocOk, elementIds, "")
}

//export roc_fx_element_find_element
func roc_fx_element_find_element(sessionId, parentElementId, using, value *RocStr) C.struct_ResultVoidStr {
	elementId, err := webdriver.FindElementInElement(sessionId.String(), parentElementId.String(), using.String(), value.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, elementId)
}

//export roc_fx_element_find_elements
func roc_fx_element_find_elements(sessionId, parentElementId, using, value *RocStr) C.struct_ResultListStr {
	elementIds, err := webdriver.FindElementsInElement(sessionId.String(), parentElementId.String(), using.String(), value.String())
	if err != nil {
		return createRocResult_ListStr_Str(RocErr, nil, err.Error())
	}

	return createRocResult_ListStr_Str(RocOk, elementIds, "")
}

//export roc_fx_browser_get_title
func roc_fx_browser_get_title(sessionId *RocStr) C.struct_ResultVoidStr {
	title, err := webdriver.GetBrowserTitle(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, title)
}

//export roc_fx_browser_get_url
func roc_fx_browser_get_url(sessionId *RocStr) C.struct_ResultVoidStr {
	title, err := webdriver.GetBrowserUrl(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, title)
}

//export roc_fx_add_cookie
func roc_fx_add_cookie(sessionId, name, value, domain, path, sameSite *RocStr, httpOnly, secure, expiry int64) C.struct_ResultVoidStr {
	httpOnlyBool := false
	if httpOnly == 1 {
		httpOnlyBool = true
	}

	secureBool := false
	if secure == 1 {
		secureBool = true
	}

	var expiryNullable *uint32
	if expiry > 0 {
		expiryU32 := uint32(expiry)
		expiryNullable = &expiryU32
	}

	cookie := webdriver.Cookie{
		Name:     name.String(),
		Value:    value.String(),
		Domain:   domain.String(),
		Path:     path.String(),
		SameSite: sameSite.String(),
		HttpOnly: httpOnlyBool,
		Secure:   secureBool,
		Expiry:   expiryNullable,
	}

	err := webdriver.AddCookie(sessionId.String(), cookie)
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_delete_cookie
func roc_fx_delete_cookie(sessionId, name *RocStr) C.struct_ResultVoidStr {
	err := webdriver.DeleteCookie(sessionId.String(), name.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_delete_all_cookies
func roc_fx_delete_all_cookies(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.DeleteAllCookies(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_get_cookie
func roc_fx_get_cookie(sessionId, name *RocStr) C.struct_ResultListStr {
	cookie, err := webdriver.GetCookie(sessionId.String(), name.String())
	if err != nil {
		return createRocResult_ListAny_Str[any](RocErr, nil, err.Error())
	}

	rocCookie := cookieToRocList(*cookie)

	return createRocResult_ListAny_Str(RocOk, &rocCookie, "")
}

//export roc_fx_get_all_cookies
func roc_fx_get_all_cookies(sessionId *RocStr) C.struct_ResultListStr {
	cookies, err := webdriver.GetAllCookies(sessionId.String())
	if err != nil {
		return createRocResult_ListAny_Str[any](RocErr, nil, err.Error())
	}

	rocList := make([]RocList[RocStr], len(*cookies))

	for _, cookie := range *cookies {
		rocCookie := cookieToRocList(cookie)
		rocList = append(rocList, rocCookie)
	}

	rocCookies := NewRocList(rocList)

	return createRocResult_ListAny_Str(RocOk, &rocCookies, "")
}

func cookieToRocList(cookie webdriver.Cookie) RocList[RocStr] {
	expiryStr := ""
	if cookie.Expiry != nil {
		expiryStr = strconv.FormatUint(uint64(*cookie.Expiry), 10)
	}

	return NewRocList([]RocStr{
		NewRocStr(cookie.Name),
		NewRocStr(cookie.Value),
		NewRocStr(cookie.Domain),
		NewRocStr(cookie.Path),
		NewRocStr(strconv.FormatBool(cookie.HttpOnly)),
		NewRocStr(strconv.FormatBool(cookie.Secure)),
		NewRocStr(cookie.SameSite),
		NewRocStr(expiryStr),
	},
	)
}

//export roc_fx_element_click
func roc_fx_element_click(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ClickElement(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_element_send_keys
func roc_fx_element_send_keys(sessionId, elementId, text *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ElementSendKeys(sessionId.String(), elementId.String(), text.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_element_clear
func roc_fx_element_clear(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ClearElement(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_element_get_text
func roc_fx_element_get_text(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementText(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_element_get_tag
func roc_fx_element_get_tag(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementTag(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_element_get_css
func roc_fx_element_get_css(sessionId, elementId, prop *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementCss(sessionId.String(), elementId.String(), prop.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_element_get_attribute
func roc_fx_element_get_attribute(sessionId, elementId, attributeName *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementAttribute(sessionId.String(), elementId.String(), attributeName.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_element_get_property
func roc_fx_element_get_property(sessionId, elementId, propertyName *RocStr) C.struct_ResultVoidStr {
	encodedStr, err := webdriver.GetElementProperty(sessionId.String(), elementId.String(), propertyName.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, encodedStr)
}

//export roc_fx_element_is_selected
func roc_fx_element_is_selected(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	isSelected, err := webdriver.IsElementSelected(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	// TODO - not sure how to send booleans to Roc
	// will fix this when I have more time
	if isSelected {
		return createRocResultStr(RocOk, "true")
	} else {
		return createRocResultStr(RocOk, "false")
	}
}

//export roc_fx_element_is_displayed
func roc_fx_element_is_displayed(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	isDisplayed, err := webdriver.IsElementDisplayed(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	// TODO - not sure how to send booleans to Roc
	// will fix this when I have more time
	if isDisplayed {
		return createRocResultStr(RocOk, "true")
	} else {
		return createRocResultStr(RocOk, "false")
	}
}

//export roc_fx_get_page_source
func roc_fx_get_page_source(sessionId *RocStr) C.struct_ResultVoidStr {
	sourceHtml, err := webdriver.GetPageSource(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, sourceHtml)
}

//export roc_fx_get_time_milis
func roc_fx_get_time_milis() int64 {
	now := time.Now().UnixMilli()

	return now
}

//export roc_fx_is_debug_mode
func roc_fx_is_debug_mode() int64 {
	isDebugModeInt := 0
	if options.DebugMode {
		isDebugModeInt = 1
	}

	return int64(isDebugModeInt)
}

//export roc_fx_is_verbose
func roc_fx_is_verbose() int64 {
	isVerboseInt := 0
	if options.Verbose {
		isVerboseInt = 1
	}

	return int64(isVerboseInt)
}

//export roc_fx_create_dir_if_not_exist
func roc_fx_create_dir_if_not_exist(path *RocStr) C.struct_ResultVoidStr {
	err := os.MkdirAll(filepath.Dir(path.String()), os.ModePerm)
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_file_write_utf8
func roc_fx_file_write_utf8(path, content *RocStr) C.struct_ResultVoidStr {
	err := os.WriteFile(path.String(), []byte(content.String()), os.ModePerm)
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_get_env
func roc_fx_get_env(name *RocStr) C.struct_RocStr {
	value := os.Getenv(name.String())

	return createRocStr(value)
}

type RocResultType int

const (
	RocErr = iota
	RocOk
)

func createRocResultStr(resultType RocResultType, str string) C.struct_ResultVoidStr {
	rocStr := NewRocStr(str)

	var result C.struct_ResultVoidStr

	result.disciminant = C.uchar(resultType)

	payloadPtr := unsafe.Pointer(&result.payload)
	*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

	return result
}

func createRocStr(str string) C.struct_RocStr {
	rocStr := NewRocStr(str)

	return rocStr.C()
}

func createRocResult_ListAny_Str[T any](resultType RocResultType, rocList *RocList[T], error string) C.struct_ResultListStr {
	var result C.struct_ResultListStr

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocList)(payloadPtr) = rocList.C()
	} else {
		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}

	return result
}

func createRocResult_ListStr_Str(resultType RocResultType, strList []string, error string) C.struct_ResultListStr {
	var result C.struct_ResultListStr

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		listOfRocStr := make([]RocStr, len(strList))
		for i, str := range strList {
			listOfRocStr[i] = NewRocStr(str)
		}
		rocList := NewRocList(listOfRocStr)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocList)(payloadPtr) = rocList.C()
	} else {
		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}

	return result
}

func createRocListStr(strList []string) C.struct_RocList {

	listOfRocStr := make([]RocStr, len(strList))
	for i, str := range strList {
		listOfRocStr[i] = NewRocStr(str)
	}
	rocList := NewRocList(listOfRocStr)
	return rocList.C()

}

func createRocResult_ListI64_Str(resultType RocResultType, intList []int64, error string) C.struct_ResultListStr {
	var result C.struct_ResultListStr

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		rocList := NewRocList(intList)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocList)(payloadPtr) = rocList.C()
	} else {
		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}

	return result
}

func createRocResult_ListF64_Str(resultType RocResultType, floatList []float64, error string) C.struct_ResultListStr {
	var result C.struct_ResultListStr

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		rocList := NewRocList(floatList)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocList)(payloadPtr) = rocList.C()
	} else {
		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}

	return result
}

func createRocResultI64(resultType RocResultType, value int64, error string) C.struct_ResultI64Str {
	var result C.struct_ResultI64Str

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.int64_t)(payloadPtr) = C.int64_t(value)

	} else {

		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}
	return result
}

func createRocResultU64(resultType RocResultType, value uint64, error string) C.struct_ResultU64Str {
	var result C.struct_ResultU64Str

	result.disciminant = C.uchar(resultType)

	if resultType == RocOk {
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.uint64_t)(payloadPtr) = C.uint64_t(value)

	} else {

		rocStr := NewRocStr(error)
		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()
	}
	return result
}
