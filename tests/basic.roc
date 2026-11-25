app [config, test_cases] { pf: platform "../platform/main.roc" }

import pf.Debug
import pf.Config
import pf.Test exposing [test]

config = Config.default_config

test_cases = [test1]

test1 = test(
	"test1",
	|browser| {
		# //
		Debug.print_line!("wow")
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		Debug.wait!(5000)

		Ok({})
	},
)
