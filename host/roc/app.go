package roc

// #include "app.h"
import "C"

import (
	"fmt"
	driversetup "host/driver_setup"
	"host/webdriver"
	"time"
	"unsafe"
)

func Main() int {
	err := setup()
	if err != nil {
		fmt.Println("Setup failed with: ", err)
		return 1
	}

	cmd, err := driversetup.RunChromedriver()
	// TODO - wait for driver to start
	time.Sleep(2 * time.Second)
	if err != nil {
		fmt.Println("could not run chrome: ", err)
		return 1
	}

	size := C.roc__mainForHost_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	C.roc__mainForHost_1_exposed_generic(capturePtr)

	var result C.struct_ResultVoidI32
	C.roc__mainForHost_0_caller(nil, capturePtr, &result)

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
	return C.struct_ResultVoidStr{
		disciminant: 1,
	}
}

//export roc_fx_stdinLine
func roc_fx_stdinLine() C.struct_ResultVoidStr {
	var input string
	fmt.Scanln(&input)

	rocStr := NewRocStr(input)

	var result C.struct_ResultVoidStr

	result.disciminant = 1

	payloadPtr := unsafe.Pointer(&result.payload)
	*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

	return result
}

//export roc_fx_wait
func roc_fx_wait(timeout int64) C.struct_ResultVoidStr {
	// fmt.Println(msg)
	time.Sleep(time.Duration(time.Duration(timeout) * time.Millisecond))
	return C.struct_ResultVoidStr{
		disciminant: 1,
	}
}

func setup() error {
	fmt.Println("trying to setup some stuff")

	err := driversetup.DownloadChromeAndDriver()
	if err != nil {
		panic(err)
	}

	return nil
}

//export roc_fx_startsession
func roc_fx_startsession() C.struct_ResultVoidStr {
	sessionId, err := webdriver.CreateSession()
	if err != nil {
		rocStr := NewRocStr(err.Error())

		var result C.struct_ResultVoidStr

		result.disciminant = 0

		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

		return result
	} else {
		rocStr := NewRocStr(sessionId)

		var result C.struct_ResultVoidStr

		result.disciminant = 1

		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

		return result
	}
}

//export roc_fx_deletesession
func roc_fx_deletesession(sessionId *RocStr) C.struct_ResultVoidStr {
	err := webdriver.DeleteSession(sessionId.String())
	if err != nil {
		rocStr := NewRocStr(err.Error())

		var result C.struct_ResultVoidStr

		result.disciminant = 0

		payloadPtr := unsafe.Pointer(&result.payload)
		*(*C.struct_RocStr)(payloadPtr) = rocStr.C()

		return result
	} else {
		return C.struct_ResultVoidStr{
			disciminant: 1,
		}
	}
}
