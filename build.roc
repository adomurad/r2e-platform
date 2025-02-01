app [main!] { cli: platform "https://github.com/roc-lang/basic-cli/releases/download/0.19.0/Hj-J_zxz7V9YurCSTFcFdu6cQJie4guzsPMUi5kBYUk.tar.br" }

import cli.Cmd

main! = |_args|

    # generate glue for builtins and platform
    # Cmd.exec "roc" ["glue", "glue.roc", "host/", "platform/main.roc"]
    # |> Task.mapErr! ErrGeneratingGlue

    # get the native target
    native = get_native_target!({})?

    # build the target
    build_go_target!({ target: native, host_dir: "host", platform_dir: "platform" })

build_go_target! : { target : RocTarget, host_dir : Str, platform_dir : Str } => Result {} _
build_go_target! = |{ target, host_dir, platform_dir }|

    (goos, goarch, prebuilt_binary) =
        when target is
            MacosArm64 -> ("darwin", "arm64", "macos-arm64.a")
            MacosX64 -> ("darwin", "amd64", "macos-x64")
            LinuxArm64 -> ("linux", "arm64", "linux-arm64.a")
            LinuxX64 -> ("linux", "amd64", "linux-x64.a")
            WindowsArm64 -> ("windows", "arm64", "windows-arm64.a")
            WindowsX64 -> ("windows", "amd64", "windows-x64")

    _ =
        Cmd.new("go")
        |> Cmd.envs([("GOOS", goos), ("GOARCH", goarch), ("CC", "zig cc")])
        |> Cmd.args(["build", "-C", host_dir, "-buildmode=c-archive", "-o", "libhost.a"])
        |> Cmd.status!()
        |> Result.map_err(|err| BuildErr(goos, goarch, Inspect.to_str(err)))?

    Cmd.exec!("cp", ["${host_dir}/libhost.a", "${platform_dir}/${prebuilt_binary}"])
    |> Result.map_err(|err| CpErr(Inspect.to_str(err)))

RocTarget : [
    MacosArm64,
    MacosX64,
    LinuxArm64,
    LinuxX64,
    WindowsArm64,
    WindowsX64,
]

get_native_target! : {} => Result RocTarget _
get_native_target! = |_|

    arch_from_str = |bytes|
        when Str.from_utf8(bytes) is
            Ok(str) if str == "arm64\n" -> Arm64
            Ok(str) if str == "x86_64\n" -> X64
            Ok(str) -> UnsupportedArch(str)
            _ -> crash("invalid utf8 from uname -m")

    cmd_output =
        Cmd.new("uname")
        |> Cmd.arg("-m")
        |> Cmd.output!()

    _ = cmd_output.status |> Result.map_err(|err| ErrGettingNativeArch(Inspect.to_str(err)))?

    arch =
        cmd_output.stdout |> arch_from_str()

    os_from_str = |bytes|
        when Str.from_utf8(bytes) is
            Ok(str) if str == "Darwin\n" -> Macos
            Ok(str) if str == "Linux\n" -> Linux
            Ok(str) -> UnsupportedOS(str)
            _ -> crash("invalid utf8 from uname -s")

    os_output =
        Cmd.new("uname")
        |> Cmd.arg("-s")
        |> Cmd.output!()

    _ = os_output.status |> Result.map_err(|err| ErrGettingNativeOS(Inspect.to_str(err)))?

    os =
        os_output.stdout
        |> os_from_str()

    when (os, arch) is
        (Macos, Arm64) -> Ok(MacosArm64)
        (Macos, X64) -> Ok(MacosX64)
        (Linux, Arm64) -> Ok(LinuxArm64)
        (Linux, X64) -> Ok(LinuxX64)
        _ -> Err(UnsupportedNative(os, arch))
