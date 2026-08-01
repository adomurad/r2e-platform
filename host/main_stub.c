#include <stdint.h>

extern int32_t roc_host_main(int32_t argc, char **argv);

/* Linux targets only: lld (Roc's linker) does not apply .init_array
   relocations against local symbols, and musl does not pass argc/argv
   to constructors. We must call the Go runtime initializer manually
   before entering Go code. */
#if defined(__linux__) && defined(__x86_64__)
extern void _rt0_amd64_linux_lib(int argc, char **argv);
#define ROC_GO_INIT _rt0_amd64_linux_lib
#elif defined(__linux__) && defined(__aarch64__)
extern void _rt0_arm64_linux_lib(int argc, char **argv);
#define ROC_GO_INIT _rt0_arm64_linux_lib
#endif

int main(int argc, char **argv, char **envp) {
    (void)envp;
#ifdef ROC_GO_INIT
    ROC_GO_INIT(argc, argv);
#endif
    return roc_host_main(argc, argv);
}
