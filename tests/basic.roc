app [test_cases, config] { pf: platform "../platform/main.roc" }

import pf.Stdin
import pf.Stdout
import pf.Config
import pf.TestCase exposing [test]

config = Config.default_config()

test_cases = [test1]

test1 = test(
	"test1",
	|_browser| {
		# //
		Stdout.line!("wow")?

		Try.Ok({})
	},
)
