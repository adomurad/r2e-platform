package roc

// #include "app.h"
import "C"

import (
	"fmt"
	"host/driversetup"
	"host/loglist"
	"host/setup"
	"host/utils"
	"host/webdriver"
	"os"
	"path/filepath"
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

// TODO change when passing more than 1 value from Roc app is possible
var options = Options{
	SetupOnly:               false,
	PrintBrowserVersionOnly: false,
	Verbose:                 false,
	Headless:                false,
	DebugMode:               false,
	TestNameFilter:          "",
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

	size := C.roc__mainForHost_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	C.roc__mainForHost_1_exposed_generic(capturePtr)

	var result C.struct_ResultVoidI64
	C.roc__mainForHost_0_caller(nil, capturePtr, &result)

	// TODO - error handling
	err = driversetup.HandleCleanup(cmd)
	if err != nil {
		fmt.Println("could not kill chromedriver: ", err)
		return 1
	}

	switch result.disciminant {
	case 1: // Ok
		return 0
	case 0: // Err
		return (*(*int)(unsafe.Pointer(&result.payload)))
	default:
		panic("invalid disciminat")
	}
}

//export roc_fx_incrementTest
func roc_fx_incrementTest() C.struct_ResultVoidStr {
	loglist.IncrementCurrentTest()
	return createRocResultStr(RocOk, "")
}

//export roc_fx_getTestNameFilter
func roc_fx_getTestNameFilter() C.struct_ResultVoidStr {
	return createRocResultStr(RocOk, options.TestNameFilter)
}

//export roc_fx_getLogsForTest
func roc_fx_getLogsForTest(testIndex int64) C.struct_ResultListStr {
	logs := loglist.GetLogsForTest(testIndex)
	return createRocResult_ListStr_Str(RocOk, logs, "")
}

//export roc_fx_stdoutLine
func roc_fx_stdoutLine(msg *RocStr) C.struct_ResultVoidStr {
	fmt.Println(msg)
	loglist.AddLogForTest(msg.String())
	return createRocResultStr(RocOk, "")
}

//export roc_fx_stdinLine
func roc_fx_stdinLine() C.struct_ResultVoidStr {
	var input string
	fmt.Scanln(&input)

	return createRocResultStr(RocOk, input)
}

//export roc_fx_wait
func roc_fx_wait(timeout int64) C.struct_ResultVoidStr {
	time.Sleep(time.Duration(time.Duration(timeout) * time.Millisecond))
	return createRocResultStr(RocOk, "")
}

//export roc_fx_startSession
func roc_fx_startSession() C.struct_ResultVoidStr {
	serverOptions := webdriver.SessionOptions{
		Headless: options.Headless,
	}

	sessionId, err := webdriver.CreateSession(serverOptions)

	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, sessionId)
	}
}

//export roc_fx_deleteSession
func roc_fx_deleteSession(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.DeleteSession(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, "")
	}
}

//export roc_fx_browserGetScreenshot
func roc_fx_browserGetScreenshot(sessionId *RocStr) C.struct_ResultVoidStr {
	screenshotBase64, err := webdriver.BrowserGetScreenshot(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, screenshotBase64)
	}
}

//export roc_fx_executeJs
func roc_fx_executeJs(sessionId, jsString, argsStr *RocStr) C.struct_ResultVoidStr {
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

//export roc_fx_browserSetWindowRect
func roc_fx_browserSetWindowRect(sessionId *RocStr, disciminant, x, y, width, height int64) C.struct_ResultListStr {
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

//export roc_fx_browserGetWindowRect
func roc_fx_browserGetWindowRect(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.GetWindowRect(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browserMaximize
func roc_fx_browserMaximize(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.Maximize(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browserMinimize
func roc_fx_browserMinimize(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.Minimize(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browserFullScreen
func roc_fx_browserFullScreen(sessionId *RocStr) C.struct_ResultListStr {
	newRect, err := webdriver.FullScreen(sessionId.String())
	if err != nil {
		return createRocResult_ListI64_Str(RocErr, nil, err.Error())
	} else {
		rectList := []int64{newRect.X, newRect.Y, newRect.Width, newRect.Height}
		return createRocResult_ListI64_Str(RocOk, rectList, "")
	}
}

//export roc_fx_browserNavigateBack
func roc_fx_browserNavigateBack(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateBack(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browserNavigateForward
func roc_fx_browserNavigateForward(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateForward(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browserReload
func roc_fx_browserReload(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.Reload(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browserNavigateTo
func roc_fx_browserNavigateTo(sessionId, url *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateTo(sessionId.String(), url.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_browserFindElement
func roc_fx_browserFindElement(sessionId, using, value *RocStr) C.struct_ResultVoidStr {
	elementId, err := webdriver.FindElement(sessionId.String(), using.String(), value.String())
	// if notFoundError, ok := err.(*webdriver.WebDriverElementNotFoundError); ok {
	//    return createRocResultStr(RocErr, fmt.Sprintf("WebDriverElementNotFoundError::"))
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

//export roc_fx_elementFindElement
func roc_fx_elementFindElement(sessionId, parentElementId, using, value *RocStr) C.struct_ResultVoidStr {
	elementId, err := webdriver.FindElementInElement(sessionId.String(), parentElementId.String(), using.String(), value.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, elementId)
}

//export roc_fx_elementFindElements
func roc_fx_elementFindElements(sessionId, parentElementId, using, value *RocStr) C.struct_ResultListStr {
	elementIds, err := webdriver.FindElementsInElement(sessionId.String(), parentElementId.String(), using.String(), value.String())
	if err != nil {
		return createRocResult_ListStr_Str(RocErr, nil, err.Error())
	}

	return createRocResult_ListStr_Str(RocOk, elementIds, "")
}

//export roc_fx_browserGetTitle
func roc_fx_browserGetTitle(sessionId *RocStr) C.struct_ResultVoidStr {
	title, err := webdriver.GetBrowserTitle(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, title)
}

//export roc_fx_browserGetUrl
func roc_fx_browserGetUrl(sessionId *RocStr) C.struct_ResultVoidStr {
	title, err := webdriver.GetBrowserUrl(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, title)
}

//export roc_fx_elementClick
func roc_fx_elementClick(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ClickElement(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_elementSendKeys
func roc_fx_elementSendKeys(sessionId, elementId, text *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ElementSendKeys(sessionId.String(), elementId.String(), text.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_elementClear
func roc_fx_elementClear(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ClearElement(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_elementGetText
func roc_fx_elementGetText(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementText(sessionId.String(), elementId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_elementGetAttribute
func roc_fx_elementGetAttribute(sessionId, elementId, attributeName *RocStr) C.struct_ResultVoidStr {
	text, err := webdriver.GetElementAttribute(sessionId.String(), elementId.String(), attributeName.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, text)
}

//export roc_fx_elementGetProperty
func roc_fx_elementGetProperty(sessionId, elementId, propertyName *RocStr) C.struct_ResultVoidStr {
	encodedStr, err := webdriver.GetElementProperty(sessionId.String(), elementId.String(), propertyName.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, encodedStr)
}

//export roc_fx_elementIsSelected
func roc_fx_elementIsSelected(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
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

//export roc_fx_elementIsDisplayed
func roc_fx_elementIsDisplayed(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
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

//export roc_fx_getTimeMilis
func roc_fx_getTimeMilis() C.struct_ResultI64Str {
	now := time.Now().UnixMilli()

	// return createRocResultI64(RocErr, 0, "upsi")
	return createRocResultI64(RocOk, now, "")
}

//export roc_fx_isDebugMode
func roc_fx_isDebugMode() C.struct_ResultI64Str {
	isDebugModeInt := 0
	if options.DebugMode {
		isDebugModeInt = 1
	}
	return createRocResultI64(RocOk, int64(isDebugModeInt), "")
}

//export roc_fx_isVerbose
func roc_fx_isVerbose() C.struct_ResultI64Str {
	isVerboseInt := 0
	if options.Verbose {
		isVerboseInt = 1
	}
	return createRocResultI64(RocOk, int64(isVerboseInt), "")
}

//export roc_fx_createDirIfNotExist
func roc_fx_createDirIfNotExist(path *RocStr) C.struct_ResultVoidStr {
	err := os.MkdirAll(filepath.Dir(path.String()), os.ModePerm)
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
}

//export roc_fx_fileWriteUtf8
func roc_fx_fileWriteUtf8(path, content *RocStr) C.struct_ResultVoidStr {
	err := os.WriteFile(path.String(), []byte(content.String()), os.ModePerm)
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	}

	return createRocResultStr(RocOk, "")
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
