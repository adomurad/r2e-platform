platform ""
	requires {
		test_cases : List(TestCase),
		config : Config
	}
	exposes [Stdout, Stderr, Stdin, TestCase, Config]
	packages {}
	provides { "roc_main": main_for_host! }
	hosted {
		"roc_stderr_line": Host.stderr_line!,
		"roc_stdin_line": Host.stdin_line!,
		"roc_stdout_line": Host.stdout_line!,
	}
	targets: {
		inputs_dir: "targets/",
		x64mac: { inputs: ["libhost.a", app] },
		arm64mac: { inputs: ["libhost.a", app] },
		x64musl: { inputs: ["crt1.o", "libhost.a", app, "libc.a"] },
		arm64musl: { inputs: ["crt1.o", "libhost.a", app, "libc.a"] },
		x64win: { inputs: ["host.lib", app] },
		arm64win: { inputs: ["host.lib", app] },
	}

import Stdout
import Stderr
import Stdin
import Host
import Config
import TestRunner
import TestCase

main_for_host! : List(Str) => I32
main_for_host! = |_args| {
	# result = main!(args)
	match TestRunner.run_tests!(test_cases) {
		Ok({}) => 0
		Err(_) => 1
	}

	# match result {
	# 	Ok({}) => 0
	# 	Err(Exit(code)) => code
	# 	Err(other) => {
	# 		_ = Stderr.line!("ERROR: ${Str.inspect(other)}")
	# 		-1
	# 	}
	# }
}
