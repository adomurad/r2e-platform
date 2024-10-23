app [testCases] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert

testCases = [
    test1,
    test2,
    test3,
    test4,
]

test1 = test "elementShouldBeVisible 1s" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    button1 = browser |> Browser.findElement! (Css "#show-opacity")
    button1 |> Element.click!

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity")
    div1 |> Assert.elementShouldBeVisible!

    button2 = browser |> Browser.findElement! (Css "#show-display")
    button2 |> Element.click!

    div2 = browser |> Browser.findElement! (Css ".hide-by-display")
    div2 |> Assert.elementShouldBeVisible!

test2 = test "elementShouldBeVisible timeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity")
    result = div1 |> Assert.elementShouldBeVisible |> Task.result!
    when result is
        Ok _ -> Assert.failWith "should not be visible"
        Err err -> Assert.shouldBe (err |> Inspect.toStr) "(AssertionError \"Expected element (Css \".hide-by-opacity\") to be visible\")"

test3 = test "elementShouldHaveText 1s" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    button1 = browser |> Browser.findElement! (Css "#show-opacity")
    button1 |> Element.click!

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity")
    div1 |> Assert.elementShouldHaveText! "Hidden by opacity..."

test4 = test "elementShouldHaveText timeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    button1 = browser |> Browser.findElement! (Css "#show-opacity")
    result = button1 |> Assert.elementShouldHaveText "fail" |> Task.result!
    when result is
        Ok _ -> Assert.failWith "should fail"
        Err err -> Assert.shouldBe (err |> Inspect.toStr) "(AssertionError \"Expected element (Css \"#show-opacity\") to have text \"fail\", but got \"Show via opacity\"\")"

# TODO test Assert.elementShouldHaveValue
