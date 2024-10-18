app [main] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.15.0/SlwdbJ-3GR7uBWQo6zlmYWNYOxnvo8r6YABXD-45UOw.tar.br" }

import cli.Cmd
import cli.Stdout

main =
    buildForLegacyLinker!

buildForLegacyLinker =
    [MacosArm64, MacosX64, LinuxArm64, LinuxX64, WindowsArm64, WindowsX64]
        |> List.map \target -> buildDotA target
        |> Task.sequence
        |> Task.map \_ -> {}
        |> Task.mapErr! \_ -> BuildForLegacyLinker

buildDotA = \target ->
    (goos, goarch, zigTarget, prebuiltBinary) =
        when target is
            MacosArm64 -> ("darwin", "arm64", "aarch64-macos", "macos-arm64.a")
            MacosX64 -> ("darwin", "amd64", "x86_64-macos", "macos-x64.a")
            LinuxArm64 -> ("linux", "arm64", "aarch64-linux", "linux-arm64.a")
            LinuxX64 -> ("linux", "amd64", " x86_64-linux", "linux-x64.a")
            WindowsArm64 -> ("windows", "arm64", "aarch64-windows", "windows-arm64.obj")
            WindowsX64 -> ("windows", "amd64", "x86_64-windows", "windows-x64.obj")
    Stdout.line! "build host for $(Inspect.toStr target)"
    Cmd.new "go"
        |> Cmd.envs [("GOOS", goos), ("GOARCH", goarch), ("CC", "zig cc -target $(zigTarget)"), ("CGO_ENABLED", "1")]
        |> Cmd.args ("build -C host -buildmode c-archive -o ../platform/$(prebuiltBinary) -tags legacy,netgo" |> Str.split " ")
        |> Cmd.status
        |> Task.mapErr! \err -> BuildErr target (Inspect.toStr err)
