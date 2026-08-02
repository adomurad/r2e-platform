#include "roc_std.h"

struct ResultVoidI64 {
    union {int64_t exit_code;} payload;
    unsigned char disciminant;
    unsigned char padding[7];
};

struct ResultI64Str {
    union {
      int64_t num;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
    unsigned char padding[7];
};

struct ResultU64Str {
    union {
      uint64_t num;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
    unsigned char padding[7];
};

struct ResultVoidStr {
    union {struct RocStr str;} payload;
    unsigned char disciminant;
    unsigned char padding[7];
};

struct ResultListStr {
    union {
      struct RocList list;
      struct RocStr str;
    } payload;
    unsigned char disciminant;
    unsigned char padding[7];
};

int32_t roc_main(void);
