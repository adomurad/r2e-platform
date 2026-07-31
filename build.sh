#!/usr/bin/env bash
# Roc platform build script for Odin

set -euo pipefail

# Detect native platform.
UNAME_S=$(uname -s)
UNAME_M=$(uname -m)

NATIVE_TARGET=""

if [[ "$UNAME_S" == "Linux" ]]; then
    if [[ "$UNAME_M" == "x86_64" ]]; then
        NATIVE_TARGET="x64musl"
    elif [[ "$UNAME_M" == "aarch64" ]]; then
        NATIVE_TARGET="arm64musl"
    fi
elif [[ "$UNAME_S" == "Darwin" ]]; then
    if [[ "$UNAME_M" == "x86_64" ]]; then
        NATIVE_TARGET="x64mac"
    elif [[ "$UNAME_M" == "arm64" ]]; then
        NATIVE_TARGET="arm64mac"
    fi
fi

# Roc targets supported by the platform.
TARGETS=(x64mac x64win x64musl arm64mac arm64musl)

# Odin target names for each Roc target.
declare -A TGT_MAP=(
    [x64mac]=darwin_amd64
    [x64win]=windows_amd64
    [x64musl]=linux_amd64
    [arm64mac]=darwin_arm64
    [arm64musl]=linux_arm64
)

# Library filename for each Roc target.
declare -A LIB_MAP=(
    [x64mac]=libhost.a
    [x64win]=host.lib
    [x64musl]=libhost.a
    [arm64mac]=libhost.a
    [arm64musl]=libhost.a
)

# Source files.
SRC=(host/host.odin host/roc_platform_abi.odin)

build_target() {
    local target="$1"
    local odin_tgt="${TGT_MAP[$target]}"
    local lib_name="${LIB_MAP[$target]}"
    local outdir="platform/targets/$target"
    local outfile="$outdir/$lib_name"

    mkdir -p "$outdir"
    echo "Building $target -> $outfile"
    odin build host -build-mode:static -target:"$odin_tgt" -out:"$outfile"
}

build_native() {
    if [[ -z "$NATIVE_TARGET" ]]; then
        echo "Could not detect native target for $UNAME_S / $UNAME_M" >&2
        exit 1
    fi
    build_target "$NATIVE_TARGET"
}

build_all() {
    for target in "${TARGETS[@]}"; do
        build_target "$target"
    done
}

clean() {
    echo "Cleaning built libraries..."
    rm -f platform/targets/*/libhost.a platform/targets/*/host.lib
}

run_test() {
    build_native
    echo "Running tests..."
    roc run examples/echo.roc <<< "hello"
}

usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
  native   Build the native host library (default)
  all      Build all supported target libraries
  clean    Remove built libraries
  test     Build native and run echo example test

EOF
}

CMD="${1:-native}"

case "$CMD" in
    native)
        build_native
        ;;
    all)
        build_all
        ;;
    clean)
        clean
        ;;
    test)
        run_test
        ;;
    -h|--help|help)
        usage
        exit 0
        ;;
    *)
        echo "Unknown command: $CMD" >&2
        usage >&2
        exit 1
        ;;
esac
