app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.default_config

test_cases = [
    test1,
    test2,
    test3,
    test4,
]

test1 = test(
    "elementShouldBeVisible 1s",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        button1 = browser |> Browser.find_element!(Css("#show-opacity")) |> try
        button1 |> Element.click! |> try

        div1 = browser |> Browser.find_element!(Css(".hide-by-opacity")) |> try
        div1 |> Assert.element_should_be_visible! |> try

        button2 = browser |> Browser.find_element!(Css("#show-display")) |> try
        button2 |> Element.click! |> try

        div2 = browser |> Browser.find_element!(Css(".hide-by-display")) |> try
        div2 |> Assert.element_should_be_visible!,
)

test2 = test(
    "elementShouldBeVisible timeout",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        div1 = browser |> Browser.find_element!(Css(".hide-by-opacity")) |> try
        result = div1 |> Assert.element_should_be_visible!
        when result is
            Ok(_) -> Assert.fail_with("should not be visible")
            Err(err) -> Assert.should_be((err |> Inspect.to_str), "(AssertionError \"Expected element (Css \".hide-by-opacity\") to be visible (waited for 3000ms)\")"),
)

test3 = test(
    "elementShouldHaveText 1s",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        button1 = browser |> Browser.find_element!(Css("#show-opacity")) |> try
        button1 |> Element.click! |> try

        div1 = browser |> Browser.find_element!(Css(".hide-by-opacity")) |> try
        div1 |> Assert.element_should_have_text!("Hidden by opacity..."),
)

test4 = test(
    "elementShouldHaveText timeout",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        button1 = browser |> Browser.find_element!(Css("#show-opacity")) |> try
        result = button1 |> Assert.element_should_have_text!("fail")
        when result is
            Ok(_) -> Assert.fail_with("should fail")
            Err(err) -> Assert.should_be((err |> Inspect.to_str), "(AssertionError \"Expected element (Css \"#show-opacity\") to have text \"fail\", but got \"Show via opacity\" (waited for 3000ms)\")"),
)

# TODO test Assert.elementShouldHaveValue
