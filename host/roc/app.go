package roc

// #include "app.h"
import "C"

import (
	"fmt"
	"unsafe"
)

func Main() int {
	size := C.roc__mainForHost_1_exposed_size()
	capturePtr := roc_alloc(size, 0)
	defer roc_dealloc(capturePtr, 0)

	C.roc__mainForHost_1_exposed_generic(capturePtr)

	var result C.struct_ResultVoidI32
	C.roc__mainForHost_0_caller(nil, capturePtr, &result)
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
