app [testCases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.defaultConfig

testCases = [
    test1,
    test2,
    test3,
    test4,
]

test1 = test "elementShouldBeVisible 1s" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
    button1 |> Element.click! |> try

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity") |> try
    div1 |> Assert.elementShouldBeVisible! |> try

    button2 = browser |> Browser.findElement! (Css "#show-display") |> try
    button2 |> Element.click! |> try

    div2 = browser |> Browser.findElement! (Css ".hide-by-display") |> try
    div2 |> Assert.elementShouldBeVisible!

test2 = test "elementShouldBeVisible timeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity") |> try
    result = div1 |> Assert.elementShouldBeVisible!
    when result is
        Ok _ -> Assert.failWith "should not be visible"
        Err err -> Assert.shouldBe (err |> Inspect.toStr) "(AssertionError \"Expected element (Css \".hide-by-opacity\") to be visible (waited for 3000ms)\")"

test3 = test "elementShouldHaveText 1s" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
    button1 |> Element.click! |> try

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity") |> try
    div1 |> Assert.elementShouldHaveText! "Hidden by opacity..."

test4 = test "elementShouldHaveText timeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
    result = button1 |> Assert.elementShouldHaveText! "fail"
    when result is
        Ok _ -> Assert.failWith "should fail"
        Err err -> Assert.shouldBe (err |> Inspect.toStr) "(AssertionError \"Expected element (Css \"#show-opacity\") to have text \"fail\", but got \"Show via opacity\" (waited for 3000ms)\")"

# TODO test Assert.elementShouldHaveValue
