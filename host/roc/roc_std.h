#ifndef ROC_STD
#define ROC_STD

#include <stdlib.h>
#include <stdint.h>

struct RocStr {
    char* bytes;
    size_t len;
    size_t capacity;
};

struct RocList {
    char* bytes;
    size_t len;
    size_t capacity;
};

#endif
