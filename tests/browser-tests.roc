app [testCases] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Browser

testCases = [
    test1,
    test2,
    test3,
]

test1 = test "navigation" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Browser.navigateTo! "https://www.roc-lang.org/"
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

test2 = test "open and close browser windows" \browser ->
    browser2 = Browser.openNewWindow!
    browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"
    browser2 |> Browser.closeWindow!

test3 = test "openNewWindowWithCleanup" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    Browser.openNewWindowWithCleanup! \browser2 ->
        browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"
