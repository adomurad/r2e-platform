#!/bin/bash
# Build the Go host as a Roc-compatible c-archive for linux/amd64.
#
# The aarch64/other targets are built the same way, with GOARCH/GOOS and the
# matching platform/targets/<target> output directory.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GOOS="${GOOS:-linux}"
GOARCH="${GOARCH:-amd64}"
CC="${CC:-zig cc}"
OUT_DIR="${OUT_DIR:-x64musl}"

cd "$ROOT"

GOOS="$GOOS" GOARCH="$GOARCH" CC="$CC" \
	go build -C host -buildmode=c-archive -o libhost.a -tags=legacy,netgo

# The Go runtime registers _rt0_* as a constructor AND main_stub.c calls it
# manually (musl/lld do not run the constructor). Keep exactly one path:
# drop .init_array and make the runtime entry point visible to the linker.
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

(cd "$WORK" && ar x "$ROOT/host/libhost.a")
objcopy --remove-section=.init_array "$WORK/go.o"
rm -f host/libhost.a
ar rcs host/libhost.a "$WORK"/*.o
objcopy --globalize-symbol=_rt0_amd64_linux_lib host/libhost.a

mkdir -p "platform/targets/$OUT_DIR"
cp host/libhost.a "platform/targets/$OUT_DIR/libhost.a"
echo "built host/libhost.a -> platform/targets/$OUT_DIR/libhost.a"
