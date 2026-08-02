package roc

/*
#include "./roc_std.h"
#include <string.h>
*/
import "C"

import (
	"fmt"
	"os"
	"unsafe"
)

const (
	refcount_one = 1 << 63
	is64Bit      = uint64(^uintptr(0)) == ^uint64(0)
	intSize      = 32 << (^uint(0) >> 63)
	intBytes     = intSize / 8
)

// allocForRoc allocates memory. Prefixes that memory with a refcounter set to
// one.
func allocForRoc(size int) unsafe.Pointer {
	refCountPtr := roc_alloc(C.size_t(size)+intBytes, C.size_t(intBytes))
	ptr := unsafe.Add(refCountPtr, intBytes)
	setRefCountToOne(ptr)
	return ptr
}

// freeForRoc frees the memory with its refcounter.
func freeForRoc(ptr unsafe.Pointer) {
	refcountPtr := unsafe.Add(ptr, -intBytes)
	roc_dealloc(refcountPtr, 0)
}

// decRefCount reduces the refcounter by one.
//
// If the refcounter gets 0, the memory is freed.
func decRefCount(ptr unsafe.Pointer) {
	refcountPtr := unsafe.Add(ptr, -intBytes)

	switch *(*uint)(refcountPtr) {
	case refcount_one:
		freeForRoc(ptr)
	case 0:
		// Data is static. Nothing to do.
	default:
		*(*uint)(refcountPtr) -= 1
	}
}

// setRefCountToInfinity sets the refcounter to 0.
//
// This tells roc not to touch it.
//
// The value 0 is something else then a refcount of zero. The refcount ignores
// the first bit. So a refcount of zero is actually `refcount_one - 1`.
func setRefCountToInfinity(ptr unsafe.Pointer) {
	refcountPtr := unsafe.Add(ptr, -intBytes)
	*(*uint)(refcountPtr) = 0
}

// setRefCountToOne sets the refcount to 1.
//
// This tells roc to take the ownership of the value. Roc is allowed to mutate
// the value. Roc will free the value, when its finished.
func setRefCountToOne(ptr unsafe.Pointer) {
	refcountPtr := unsafe.Add(ptr, -intBytes)
	*(*uint)(refcountPtr) = 0
}

//export roc_alloc
func roc_alloc(size C.size_t, alignment C.size_t) unsafe.Pointer {
	_ = alignment
	return C.malloc(size)
}

//export roc_realloc
func roc_realloc(ptr unsafe.Pointer, newSize C.size_t, alignment C.size_t) unsafe.Pointer {
	_ = alignment
	return C.realloc(ptr, newSize)
}

//export roc_dealloc
func roc_dealloc(ptr unsafe.Pointer, alignment C.size_t) {
	_ = alignment
	C.free(ptr)
}

//export roc_panic
func roc_panic(msg *RocStr, tagID C.uint) {
	panic(msg.String())
}

//export roc_dbg
func roc_dbg(bytes *C.uint8_t, length C.size_t) {
	data := unsafe.Slice((*byte)(unsafe.Pointer(bytes)), length)
	fmt.Fprintf(os.Stderr, "[ROC DBG] %s\n", string(data))
}

//export roc_expect_failed
func roc_expect_failed(bytes *C.uint8_t, length C.size_t) {
	data := unsafe.Slice((*byte)(unsafe.Pointer(bytes)), length)
	fmt.Fprintf(os.Stderr, "[ROC EXPECT] %s\n", string(data))
}

//export roc_crashed
func roc_crashed(bytes *C.uint8_t, length C.size_t) {
	data := unsafe.Slice((*byte)(unsafe.Pointer(bytes)), length)
	fmt.Fprintf(os.Stderr, "[ROC CRASHED] %s\n", string(data))
	os.Exit(1)
}

// RocStr is a representation of a string in roc.
type RocStr C.struct_RocStr

// NewRocStr creates a RocStr from a go-string.
func NewRocStr(str string) RocStr {
	if len(str) == 0 {
		return emptyRocStr()
	}

	if len(str) < int(C.sizeof_struct_RocStr) {
		return smallRocStr(str)
	}

	ptr := allocForRoc(len(str))

	var rocStr RocStr
	rocStr.length = C.uintptr_t(len(str))
	rocStr.capacity_or_alloc_ptr = rocStr.length << 1
	rocStr.bytes = (*C.uint8_t)(unsafe.Pointer(ptr))

	dataSlice := unsafe.Slice((*byte)(ptr), len(str))
	copy(dataSlice, []byte(str))

	return rocStr
}

func emptyRocStr() RocStr {
	var s RocStr
	s.length = C.uintptr_t(1) << (intSize - 1)
	return s
}

func smallRocStr(str string) RocStr {
	var s RocStr
	p := (*byte)(unsafe.Pointer(&s))
	slice := unsafe.Slice(p, C.sizeof_struct_RocStr)
	copy(slice, []byte(str))
	slice[C.sizeof_struct_RocStr-1] = byte(len(str)) | 0x80
	return s
}

// Small returns true, if the RocStr is represented as a small string, that does
// not need a separate heap allocation.
func (r RocStr) Small() bool {
	return int64(r.length) < 0
}

// String converts a Roc string to a go string.
func (r RocStr) String() string {
	if r.Small() {
		ptr := (*byte)(unsafe.Pointer(&r))
		byteLen := C.sizeof_struct_RocStr
		shortStr := unsafe.String(ptr, byteLen)
		length := shortStr[byteLen-1] ^ 0x80
		return shortStr[:length]
	}

	ptr := (*byte)(unsafe.Pointer(r.bytes))
	return unsafe.String(ptr, r.length)
}

// C returns the C-ABI representation of the string.
func (r RocStr) C() C.struct_RocStr {
	return C.struct_RocStr(r)
}

// CPtr returns the C-ABI representation of a pointer to the string.
func (r *RocStr) CPtr() *C.struct_RocStr {
	return (*C.struct_RocStr)(r)
}

// DecRef reduces the refcount of the data of the string. It frees the data, if
// it reaches a ref count of 0.
func (r RocStr) DecRef() {
	ptr := unsafe.Pointer(r.bytes)
	if r.Small() || ptr == nil {
		return
	}

	decRefCount(ptr)
}

// RocList represents a List in Roc.
type RocList[t any] C.struct_RocList

// NewRocList creates a RocList from a go slice.
func NewRocList[t any](list []t) RocList[t] {
	if len(list) == 0 {
		return RocList[t]{}
	}

	var rocList RocList[t]
	var zero t
	typeSize := int(unsafe.Sizeof(zero))

	ptr := allocForRoc(len(list) * typeSize)

	rocList.length = C.uintptr_t(len(list))
	rocList.capacity_or_alloc_ptr = rocList.length << 1
	rocList.elements_ptr = unsafe.Pointer(ptr)

	dataSlice := unsafe.Slice((*t)(ptr), len(list))
	copy(dataSlice, list)

	return rocList
}

// List converts the RocList to a go slice.
func (r RocList[t]) List() []t {
	ptr := (*t)(unsafe.Pointer(r.elements_ptr))
	return unsafe.Slice(ptr, r.length)
}

// C returns the C-ABI representation of the list.
func (r RocList[t]) C() C.struct_RocList {
	return C.struct_RocList(r)
}

// CPtr returns the C-ABI representation of a pointer to the list.
func (r *RocList[t]) CPtr() *C.struct_RocList {
	return (*C.struct_RocList)(r)
}

// DecRef reduces the refcount of the data of the list. It frees the data, if
// it reaches a ref count of 0.
//
// If go-type of the elements of the list has a method `DecRef`, it gets called for every element.
func (r RocList[t]) DecRef() {
	ptr := unsafe.Pointer(r.elements_ptr)
	if ptr == nil {
		return
	}

	type decRefer interface {
		DecRef()
	}

	for _, e := range r.List() {
		hasDecRef, ok := any(e).(decRefer)
		if !ok {
			break
		}
		hasDecRef.DecRef()
	}

	decRefCount(ptr)
}
