app [testCases] { r2e: platform "../platform/main.roc" }

import r2e.Console
import r2e.Test exposing [test]
import r2e.Browser
import r2e.Assert

testCases = [
    test1,
]

test1 = test "navigation" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Browser.navigateTo! "https://www.roc-lang.org/"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
