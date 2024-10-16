package roc

// #include "app.h"
import "C"

import (
	"fmt"
	"host/driversetup"
	"host/utils"
	"host/webdriver"
	"time"
	"unsafe"
)

func Main() int {
	fmt.Println(utils.FG_BLUE + "=============================" + utils.RESET)
	fmt.Println(utils.FG_BLUE + "============SETUP============" + utils.RESET)
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

	fmt.Println(utils.FG_BLUE + "Driver and Browser are ready." + utils.RESET)
	fmt.Println(utils.FG_BLUE + "=============================" + utils.RESET)
	fmt.Print("\n\n")

	size := C.roc__mainForHost_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	C.roc__mainForHost_1_exposed_generic(capturePtr)

	var result C.struct_ResultVoidI32
	C.roc__mainForHost_0_caller(nil, capturePtr, &result)

	// TODO - error handling
	driversetup.HandleCleanup(cmd)

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
	fmt.Println("session id from go: ", sessionId)
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

//export roc_fx_browserNavigateTo
func roc_fx_browserNavigateTo(sessionId, url *RocStr) C.struct_ResultVoidStr {
	err := webdriver.NavigateTo(sessionId.String(), url.String())
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

	// result.disciminant = 1
	result.disciminant = C.uchar(resultType)

	payloadPtr := unsafe.Pointer(&result.payload)
	*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

	return result
}
