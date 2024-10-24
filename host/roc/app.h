#include "roc_std.h"

struct ResultVoidI64 {
    union {int64_t exit_code;} payload;
    unsigned char disciminant;
};

struct ResultI64Str {
    union {
      int64_t num;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
};

struct ResultU64Str {
    union {
      uint64_t num;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
};

struct ResultVoidStr {
    union {struct RocStr str;} payload;
    unsigned char disciminant;
};

struct ResultListStr {
    union {
      struct RocList list;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
};

void roc__mainForHost_1_exposed_generic(void* captures);
size_t roc__mainForHost_1_exposed_size();
void roc__mainForHost_0_caller(char* flags, void* closure_data, struct ResultVoidI64 *result);
