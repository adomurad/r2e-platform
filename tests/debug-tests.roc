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
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    _h1 = browser |> Browser.findElement! (TestId "name-input") |> try
    _h2 = browser |> Browser.findElement! (Css "h1") |> try
    _h3 = browser |> Browser.findElement! (XPath "//div") |> try

    _h10 = browser |> Browser.findElements! (Css "input") |> try
    _h12 = browser |> Browser.findElements! (TestId "name-input") |> try
    _h11 = browser |> Browser.findElements! (XPath "//div") |> try

    browser |> Browser.navigateTo! "https://www.roc-lang.org/" |> try
    _h5 = browser |> Browser.findElements! (LinkText "examples") |> try
    _h4 = browser |> Browser.findElement! (LinkText "examples") |> try
    _h7 = browser |> Browser.findElements! (PartialLinkText "xam") |> try
    _h6 = browser |> Browser.findElement! (PartialLinkText "xam") |> try

    Assert.shouldBe 1 1

test2 = test "showElements" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    browser |> Debug.showCurrentFrame! |> try
    browser |> Debug.showCurrentFrame! |> try

    el1 = browser |> Browser.findElement! (TestId "name-input") |> try
    el1 |> Debug.showElement! |> try
    [el1] |> Debug.showElements! |> try

    el2 = browser |> Browser.findElement! (Css "h1") |> try
    el2 |> Debug.showElement! |> try
    [el2] |> Debug.showElements! |> try

    el3 = browser |> Browser.findElement! (XPath "//div") |> try
    el3 |> Debug.showElement! |> try
    [el3] |> Debug.showElements! |> try

    browser |> Browser.navigateTo! "https://www.roc-lang.org/" |> try

    el4 = browser |> Browser.findElement! (LinkText "examples") |> try
    el4 |> Debug.showElement! |> try
    [el4] |> Debug.showElements! |> try

    el5 = browser |> Browser.findElement! (PartialLinkText "xam") |> try
    el5 |> Debug.showElement! |> try
    [el5] |> Debug.showElements!

