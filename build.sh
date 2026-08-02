#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

TARGETS="x64mac arm64mac x64musl arm64musl x64win arm64win"

declare -A GOOS=(
    [x64mac]=darwin
    [arm64mac]=darwin
    [x64musl]=linux
    [arm64musl]=linux
    [x64win]=windows
    [arm64win]=windows
)

declare -A GOARCH=(
    [x64mac]=amd64
    [arm64mac]=arm64
    [x64musl]=amd64
    [arm64musl]=arm64
    [x64win]=amd64
    [arm64win]=arm64
)

declare -A ZIG_TARGET=(
    [x64mac]=x86_64-macos
    [arm64mac]=aarch64-macos
    [x64musl]=x86_64-linux-musl
    [arm64musl]=aarch64-linux-musl
    [x64win]=x86_64-windows
    [arm64win]=aarch64-windows
)

# Go runtime init symbols that need to be globalized for Linux musl
# because lld does not apply .init_array relocations against local symbols.
declare -A GO_INIT_SYM=(
    [x64musl]=_rt0_amd64_linux_lib
    [arm64musl]=_rt0_arm64_linux_lib
)

# Library filename for each target.
declare -A LIB_NAME=(
    [x64mac]=libhost.a
    [arm64mac]=libhost.a
    [x64musl]=libhost.a
    [arm64musl]=libhost.a
    [x64win]=host.lib
    [arm64win]=host.lib
)

build_target() {
    local target=$1
    local lib_name=${LIB_NAME[$target]}
    local output="platform/targets/$target/$lib_name"
    mkdir -p "platform/targets/$target"

    local zig_target=${ZIG_TARGET[$target]}
    local goos=${GOOS[$target]}
    local goarch=${GOARCH[$target]}

    echo "==> Building $target (GOOS=$goos GOARCH=$goarch, zig=$zig_target)"

    CC="zig cc -target $zig_target" \
    CXX="zig c++ -target $zig_target" \
    GOOS=$goos \
    GOARCH=$goarch \
    CGO_ENABLED=1 \
        go build -C host -buildmode=c-archive -o "../$output" .

    local sym=${GO_INIT_SYM[$target]:-}
    if [[ -n "$sym" ]]; then
        echo "    Patching Go runtime init symbol ($sym)..."
        local tmpdir
        tmpdir=$(mktemp -d)
        (cd "$tmpdir" && ar x "$SCRIPT_DIR/$output" go.o)
        if [[ -f "$tmpdir/go.o" ]]; then
            llvm-objcopy --globalize-symbol="$sym" --remove-section=.init_array \
                "$tmpdir/go.o" "$tmpdir/go_fixed.o"
            ar d "$output" go.o 2>/dev/null || true
            ar r "$output" "$tmpdir/go_fixed.o"
        fi
        rm -rf "$tmpdir"
    fi

    echo "    Done: $output"
}

build_native() {
    local goos goarch target
    goos=$(go env GOOS)
    goarch=$(go env GOARCH)

    case "$goos/$goarch" in
        linux/amd64) target=x64musl ;;
        linux/arm64) target=arm64musl ;;
        darwin/amd64) target=x64mac ;;
        darwin/arm64) target=arm64mac ;;
        windows/amd64) target=x64win ;;
        windows/arm64) target=arm64win ;;
        *)
            echo "Unsupported native platform: $goos/$goarch"
            exit 1
            ;;
    esac

    build_target "$target"
}

clean() {
    echo "Cleaning built libraries..."
    rm -f platform/targets/*/libhost.a
    rm -f platform/targets/*/host.lib
    rm -f platform/libhost.a platform/host.lib
}

case "${1:-native}" in
    clean)
        clean
        ;;
    native)
        build_native
        ;;
    all)
        for t in $TARGETS; do
            build_target "$t"
        done
        ;;
    *)
        if [[ -n "${GOOS[$1]:-}" ]]; then
            build_target "$1"
        else
            echo "Usage: $0 {clean|native|all|<target>}"
            echo "Targets: $TARGETS"
            exit 1
        fi
        ;;
esac
