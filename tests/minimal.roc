app [test_cases, config] { pf: platform "../platform/main.roc" }

import pf.Debug
import pf.Config
import pf.TestCase exposing [test]

config = Config.default_config()

test_cases = [test1]

test1 = test(
    "minimal",
    |_browser| {
        Debug.print_line!("hello")
        Try.Ok({})
    },
)
