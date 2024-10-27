app [testCases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Assert
import r2e.Debug

config = Config.defaultConfig

testCases = [
    test1,
    test2,
]

# TODO craete a mock webpage to test better test this

test1 = test "debug selectors" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    _h1 = browser |> Browser.findElement! (TestId "name-input")
    _h2 = browser |> Browser.findElement! (Css "h1")
    _h3 = browser |> Browser.findElement! (XPath "//div")

    _h10 = browser |> Browser.findElements! (Css "input")
    _h12 = browser |> Browser.findElements! (TestId "name-input")
    _h11 = browser |> Browser.findElements! (XPath "//div")

    browser |> Browser.navigateTo! "https://www.roc-lang.org/"
    _h5 = browser |> Browser.findElements! (LinkText "examples")
    _h4 = browser |> Browser.findElement! (LinkText "examples")
    _h7 = browser |> Browser.findElements! (PartialLinkText "xam")
    _h6 = browser |> Browser.findElement! (PartialLinkText "xam")

    Assert.shouldBe 1 1

test2 = test "showElements" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    browser |> Debug.showCurrentFrame!
    browser |> Debug.showCurrentFrame!

    el1 = browser |> Browser.findElement! (TestId "name-input")
    el1 |> Debug.showElement!
    [el1] |> Debug.showElements!

    el2 = browser |> Browser.findElement! (Css "h1")
    el2 |> Debug.showElement!
    [el2] |> Debug.showElements!

    el3 = browser |> Browser.findElement! (XPath "//div")
    el3 |> Debug.showElement!
    [el3] |> Debug.showElements!

    browser |> Browser.navigateTo! "https://www.roc-lang.org/"

    el4 = browser |> Browser.findElement! (LinkText "examples")
    el4 |> Debug.showElement!
    [el4] |> Debug.showElements!

    el5 = browser |> Browser.findElement! (PartialLinkText "xam")
    el5 |> Debug.showElement!
    [el5] |> Debug.showElements!
