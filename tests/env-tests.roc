app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Env
import r2e.Assert

config = Config.default_config

test_cases = [
    test1,
]

test1 = test(
    "getEnv",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        empty = Env.get!("FAKE_ENV_FOR_SURE_EMPTY")
        empty |> Assert.should_be("") |> try

        env = Env.get!("THIS_ENV_SHOULD_NOT_BE_EMPTY")
        env |> Assert.should_be("secret_value"),
)
