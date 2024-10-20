app [testCases] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Browser
import r2e.Assert

testCases = [
    test1,
    test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
    test9,
    test10,
]

test1 = test "navigation" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/"

    browser |> Browser.navigateTo! "https://www.roc-lang.org/"
    browser |> Assert.urlShouldBe! "https://www.roc-lang.org/"

    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/"

test2 = test "open and close browser windows" \_browser ->
    browser2 = Browser.openNewWindow!
    browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"
    browser2 |> Browser.closeWindow!

test3 = test "openNewWindowWithCleanup" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    Browser.openNewWindowWithCleanup! \browser2 ->
        browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"

test4 = test "window move" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    newRect = browser |> Browser.setWindowRect! (Move { x: 400, y: 600 })

    newRect.x |> Assert.shouldBe 406

test5 = test "window resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    newRect = browser |> Browser.setWindowRect! (Resize { width: 800, height: 750 })

    newRect.width |> Assert.shouldBe 800

test6 = test "window move and resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    newRect = browser |> Browser.setWindowRect! (MoveAndResize { x: 400, y: 600, width: 800, height: 750 })

    newRect.x |> Assert.shouldBe! 406
    newRect.width |> Assert.shouldBe 800

test7 = test "getWindowRect" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    rect = browser |> Browser.getWindowRect!

    rect.x |> Assert.shouldBe! 16
    rect.width |> Assert.shouldBe 1919

test8 = test "getTitle" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    title = browser |> Browser.getTitle!

    title |> Assert.shouldBe "TestCafe Example Page"

test9 = test "getTitle assert" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    browser |> Assert.titleShouldBe "TestCafe Example Page"

test10 = test "getUrl" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    url = browser |> Browser.getUrl!

    url |> Assert.shouldBe "https://devexpress.github.io/testcafe/example/"
