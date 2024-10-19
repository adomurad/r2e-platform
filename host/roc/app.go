package roc

// #include "app.h"
import "C"

import (
	"fmt"
	"host/driversetup"
	"host/utils"
	"host/webdriver"
	"os"
	"path/filepath"
	"time"
	"unsafe"
)

func Main() int {
	// fmt.Println(utils.FG_BLUE + "=============================" + utils.RESET)
	// fmt.Println(utils.FG_BLUE + "============SETUP============" + utils.RESET)
	err := setup()
	if err != nil {
		fmt.Println(utils.FG_RED+"Setup failed with: "+utils.RESET, err)
		return 1
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

	// fmt.Println(utils.FG_BLUE + "Driver and Browser are ready." + utils.RESET)
	// fmt.Println(utils.FG_BLUE + "=============================" + utils.RESET)
	// fmt.Print("\n\n")

	size := C.roc__mainForHost_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	C.roc__mainForHost_1_exposed_generic(capturePtr)

	var result C.struct_ResultVoidI32
	C.roc__mainForHost_0_caller(nil, capturePtr, &result)

	// TODO - error handling
	err = driversetup.HandleCleanup(cmd)
	if err != nil {
		fmt.Println("could not kill chromedriver: ", err)
		return 1
	}

	// TODO - this seems to be broken
	switch result.disciminant {
	case 1: // Ok
		return 0
	case 0: // Err
		return (*(*int)(unsafe.Pointer(&result.payload)))
	default:
		panic("invalid disciminat")
	}
}

//export roc_fx_stdoutLine
func roc_fx_stdoutLine(msg *RocStr) C.struct_ResultVoidStr {
	fmt.Println(msg)
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

func setup() error {
	err := driversetup.DownloadChromeAndDriver()
	if err != nil {
		return err
	}

	return nil
}

//export roc_fx_startSession
func roc_fx_startSession() C.struct_ResultVoidStr {
	sessionId, err := webdriver.CreateSession()

	if err != nil {
		fmt.Println("error value ")
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

//export roc_fx_getScreenshot
func roc_fx_getScreenshot(sessionId *RocStr) C.struct_ResultVoidStr {
	screenshotBase64, err := webdriver.GetScreenshot(sessionId.String())
	if err != nil {
		return createRocResultStr(RocErr, err.Error())
	} else {
		return createRocResultStr(RocOk, screenshotBase64)
	}
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

//export roc_fx_elementClick
func roc_fx_elementClick(sessionId, elementId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.ClickElement(sessionId.String(), elementId.String())
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

//export roc_fx_getTimeMilis
func roc_fx_getTimeMilis() C.struct_ResultI64Str {
	now := time.Now().UnixMilli()

	// return createRocResultI64(RocErr, 0, "upsi")
	return createRocResultI64(RocOk, now, "")
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
