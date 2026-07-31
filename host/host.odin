package host

import "base:runtime"
import "core:bufio"
import "core:fmt"
import "core:io"
import "core:mem"
import "core:os"
import "core:strings"

// Host environment. Embeds RocEnv so the Roc runtime sees a pointer
// to a standard RocEnv while hosted functions can recover the full
// HostEnv via pointer arithmetic.
HostEnv :: struct {
	roc_env:            RocEnv,
	tracking_allocator: mem.Tracking_Allocator,
	stdin_reader:       bufio.Reader,
}

// Private RocHost used by host helpers and exported runtime symbols.
g_roc_host: ^RocHost

// -----------------------------------------------------------------------------
// Entry point
// -----------------------------------------------------------------------------

when ODIN_OS == .Windows {
	@(export)
	__main :: proc "c" () {
		// Windows MinGW/MSVCRT compatibility stub.
	}
}

main :: proc() {
	env: HostEnv
	mem.tracking_allocator_init(&env.tracking_allocator, context.allocator)
	env.roc_env.allocator = mem.tracking_allocator(&env.tracking_allocator)
	env.roc_env.roc_io = roc_io_default()

	bufio.reader_init(&env.stdin_reader, os.to_stream(os.stdin), 256, env.roc_env.allocator)

	roc_host := make_roc_host(&env.roc_env)
	g_roc_host = &roc_host

	args_list := build_args_list_from_os_args(&roc_host)

	exit_code := roc_main(args_list)

	bufio.reader_destroy(&env.stdin_reader)

	// Check for memory leaks before returning.
	bad := tracking_allocator_check(&env.tracking_allocator)
	if bad {
		fmt.fprintln(os.stderr, "Memory leak detected!")
		os.exit(1)
	}

	os.exit(int(exit_code))
}

// -----------------------------------------------------------------------------
// Try helpers
// -----------------------------------------------------------------------------

stderr_line_ok :: proc() -> StderrResult {
	return StderrResult{payload = StderrResultPayload{ok = struct{}{}}, tag = .Ok}
}

stderr_line_err :: proc(err: string, roc_host: ^RocHost) -> StderrResult {
	return StderrResult {
		payload = StderrResultPayload{err = roc_str_from_slice(err, roc_host)},
		tag = .Err,
	}
}

stdin_line_ok :: proc(line: RocStr) -> StdinResult {
	return StdinResult{payload = StdinResultPayload{ok = line}, tag = .Ok}
}

stdin_line_err :: proc(err: string, roc_host: ^RocHost) -> StdinResult {
	return StdinResult {
		payload = StdinResultPayload{err = roc_str_from_slice(err, roc_host)},
		tag = .Err,
	}
}

stdout_line_ok :: proc() -> StdoutResult {
	return StdoutResult{payload = StdoutResultPayload{ok = struct{}{}}, tag = .Ok}
}

stdout_line_err :: proc(err: string, roc_host: ^RocHost) -> StdoutResult {
	return StdoutResult {
		payload = StdoutResultPayload{err = roc_str_from_slice(err, roc_host)},
		tag = .Err,
	}
}

// -----------------------------------------------------------------------------
// Hosted functions
// -----------------------------------------------------------------------------

@(export)
roc_stderr_line :: proc "c" (str: RocStr) -> StderrResult {
	context = runtime.default_context()
	roc_host := g_roc_host
	local_str := str
	defer roc_str_decref(local_str, roc_host)

	message := roc_str_as_slice(&local_str)
	_, err := os.write(os.stderr, transmute([]u8)message)
	if err != os.ERROR_NONE {
		return stderr_line_err("stderr write failed", roc_host)
	}
	_, err2 := os.write(os.stderr, []u8{'\n'})
	if err2 != os.ERROR_NONE {
		return stderr_line_err("stderr write failed", roc_host)
	}
	return stderr_line_ok()
}

@(export)
roc_stdin_line :: proc "c" () -> StdinResult {
	context = runtime.default_context()
	roc_host := g_roc_host
	env := host_env_from_roc_host(roc_host)

	line_bytes, err := bufio.reader_read_bytes(&env.stdin_reader, '\n', env.roc_env.allocator)
	if err != nil && err != .EOF {
		delete(line_bytes, env.roc_env.allocator)
		return stdin_line_err("stdin read failed", roc_host)
	}

	line := string(line_bytes)
	if strings.has_suffix(line, "\r\n") {
		line = line[:len(line) - 2]
	} else if strings.has_suffix(line, "\n") {
		line = line[:len(line) - 1]
	}

	result := roc_str_from_slice(line, roc_host)
	delete(line_bytes, env.roc_env.allocator)
	return stdin_line_ok(result)
}

@(export)
roc_stdout_line :: proc "c" (str: RocStr) -> StdoutResult {
	context = runtime.default_context()
	roc_host := g_roc_host
	local_str := str
	defer roc_str_decref(local_str, roc_host)

	message := roc_str_as_slice(&local_str)
	_, err := os.write(os.stdout, transmute([]u8)message)
	if err != os.ERROR_NONE {
		return stdout_line_err("stdout write failed", roc_host)
	}
	_, err2 := os.write(os.stdout, []u8{'\n'})
	if err2 != os.ERROR_NONE {
		return stdout_line_err("stdout write failed", roc_host)
	}
	return stdout_line_ok()
}

@(export)
roc_alloc :: proc "c" (length: uint, alignment: uint) -> rawptr {
	context = runtime.default_context()
	return default_roc_alloc(g_roc_host, length, alignment)
}

@(export)
roc_dealloc :: proc "c" (ptr: rawptr, alignment: uint) {
	context = runtime.default_context()
	default_roc_dealloc(g_roc_host, ptr, alignment)
}

@(export)
roc_realloc :: proc "c" (ptr: rawptr, new_length: uint, alignment: uint) -> rawptr {
	context = runtime.default_context()
	return default_roc_realloc(g_roc_host, ptr, new_length, alignment)
}

@(export)
roc_dbg :: proc "c" (bytes: [^]u8, len: uint) {
	context = runtime.default_context()
	default_roc_dbg(g_roc_host, bytes, len)
}

@(export)
roc_expect_failed :: proc "c" (bytes: [^]u8, len: uint) {
	context = runtime.default_context()
	default_roc_expect_failed(g_roc_host, bytes, len)
}

@(export)
roc_crashed :: proc "c" (bytes: [^]u8, len: uint) {
	context = runtime.default_context()
	default_roc_crashed(g_roc_host, bytes, len)
}

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------

host_env_from_roc_host :: proc(roc_host: ^RocHost) -> ^HostEnv {
	roc_env := (^RocEnv)(roc_host.env)
	return (^HostEnv)(roc_env)
}

build_args_list_from_os_args :: proc(roc_host: ^RocHost) -> RocList(RocStr) {
	if len(os.args) == 0 {
		return roc_list_empty(RocStr)
	}

	list := roc_list_allocate(RocStr, true, uint(len(os.args)), roc_host)
	for i in 0 ..< len(os.args) {
		list.elements_ptr[i] = roc_str_from_slice(os.args[i], roc_host)
	}
	return list
}

tracking_allocator_check :: proc(t: ^mem.Tracking_Allocator) -> bool {
	return len(t.allocation_map) != 0 || len(t.bad_free_array) != 0
}
