#ifndef ROC_STD
#define ROC_STD

#include <stdlib.h>
#include <stdint.h>

struct RocStr {
    uint8_t* bytes;
    uintptr_t length;
    uintptr_t capacity_or_alloc_ptr;
};

struct RocList {
    void* elements_ptr;
    uintptr_t length;
    uintptr_t capacity_or_alloc_ptr;
};

struct RocListStr {
    struct RocStr* elements_ptr;
    uintptr_t length;
    uintptr_t capacity_or_alloc_ptr;
};

#endif
