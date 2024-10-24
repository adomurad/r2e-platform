app [testCases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Assert

config = Config.defaultConfig

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
    test11,
    test12,
    test13,
    test14,
    test15,
    test16,
    test17,
    test18,
    test19,
    test20,
    test21,
    test22,
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

    _newRect = browser |> Browser.setWindowRect! (Move { x: 400, y: 600 })

    # newRect.x |> Assert.shouldBe 406
    Task.ok {}

test5 = test "window resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    _newRect = browser |> Browser.setWindowRect! (Resize { width: 800, height: 750 })

    # newRect.width |> Assert.shouldBe 800
    Task.ok {}

test6 = test "window move and resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    _newRect = browser |> Browser.setWindowRect! (MoveAndResize { x: 400, y: 600, width: 800, height: 750 })

    # newRect.x |> Assert.shouldBe! 406
    # newRect.width |> Assert.shouldBe 800
    Task.ok {}

test7 = test "getWindowRect" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    _rect = browser |> Browser.getWindowRect!

    # rect.x |> Assert.shouldBe! 16
    # rect.width |> Assert.shouldBeGreaterThan 0
    Task.ok {}

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

test11 = test "browser navigation operations" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    browser |> Browser.navigateTo! "https://google.com"
    browser |> Browser.navigateTo! "https://roc-lang.org"
    browser |> Browser.reloadPage!
    browser |> Browser.navigateBack!
    browser |> Browser.navigateBack!
    browser |> Browser.navigateForward!
    browser |> Browser.navigateForward!

test12 = test "window max, min, full" \browser ->

    # cannot run this on my machine
    # rect2 = browser |> Browser.minimizeWindow!
    # rect2.x |> Assert.shouldBe! 16
    # rect2.width |> Assert.shouldBe! 1919

    _rect3 = browser |> Browser.fullScreenWindow!
    # rect3.x |> Assert.shouldBe! 0
    # rect3.width |> Assert.shouldBe! 3840

    _rect1 = browser |> Browser.maximizeWindow!
    Task.ok {}
# rect1.x |> Assert.shouldBe! 6
# rect1.width |> Assert.shouldBe! 3828

test13 = test "executeJs return int" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithOutput! "return 50 + 5;"
    response |> Assert.shouldBe! 55

test14 = test "executeJs return float" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;"
    response |> Assert.shouldBe! 55.5

test15 = test "executeJs return string" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;"
    response |> Assert.shouldBe! "55.5"

test16 = test "executeJs return bool to str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithOutput! "return true"
    response |> Assert.shouldBe! "true"

test17 = test "executeJs return bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithOutput! "return true"
    response |> Assert.shouldBe! Bool.true

test18 = test "executeJs" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    browser |> Browser.executeJs! "console.log(\"test\");"

test19 = test "executeJsWithArgs" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    response = browser |> Browser.executeJsWithArgs! "return 50.5 + 5;" [Number 55.5, String "5"]
    response |> Assert.shouldBe! 55.5

test20 = test "cookies add, get, getAll" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    browser |> Browser.addCookie! { name: "myCookie", value: "value1" }

    cookies1 = browser |> Browser.getAllCookies!
    cookies1 |> List.len |> Assert.shouldBe! 1

    browser |> Browser.addCookie! { name: "myCookie2", value: "value2" }

    cookies2 = browser |> Browser.getAllCookies!
    cookies2 |> List.len |> Assert.shouldBe! 2

    cookie1 = browser |> Browser.getCookie! "myCookie"
    cookie1
    |> Assert.shouldBe {
        name: "myCookie",
        value: "value1",
        domain: "adomurad.github.io",
        path: "/",
        sameSite: None,
        expiry: Session,
        # TODO webdriver always sets true... need to investigate
        secure: Bool.true,
        httpOnly: Bool.false,
    }

test21 = test "cookies delete, deleteAll" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    browser |> Browser.addCookie! { name: "myCookie", value: "value1" }
    browser |> Browser.addCookie! { name: "myCookie2", value: "value2" }
    browser |> Browser.addCookie! { name: "myCookie3", value: "value3" }

    cookies1 = browser |> Browser.getAllCookies!
    cookies1 |> List.len |> Assert.shouldBe! 3

    browser |> Browser.deleteCookie! "myCookie2"

    cookies2 = browser |> Browser.getAllCookies!
    cookies2 |> List.len |> Assert.shouldBe! 2

    browser |> Browser.deleteCookie! "fake-cookie"

    cookies3 = browser |> Browser.getAllCookies!
    cookies3 |> List.len |> Assert.shouldBe! 2

    browser |> Browser.deleteAllCookies!

    cookies4 = browser |> Browser.getAllCookies!
    cookies4 |> List.len |> Assert.shouldBe! 0

test22 = test "cookies custom" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    browser
        |> Browser.addCookie! {
            name: "myCookie",
            value: "value1",
            # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
            domain: "adomurad.github.io",
            path: "/e2e-test-page",
            sameSite: Lax,
            secure: Bool.true,
            httpOnly: Bool.true,
            expiry: MaxAge 2865848396,
        }

    cookie1 = browser |> Browser.getCookie! "myCookie"
    cookie1
        |> Assert.shouldBe! {
            name: "myCookie",
            value: "value1",
            domain: ".adomurad.github.io",
            path: "/e2e-test-page",
            sameSite: Lax,
            # TODO - bug in Roc compiler - U32 -> I64
            expiry: Session,
            secure: Bool.true,
            httpOnly: Bool.true,
        }

    browser
        |> Browser.addCookie! {
            name: "myCookie2",
            value: "value2",
            # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
            domain: "adomurad.github.io",
            path: "/e2e-test-page",
            sameSite: Strict,
            secure: Bool.true,
            httpOnly: Bool.true,
            expiry: MaxAge 2865848396,
        }

    cookie2 = browser |> Browser.getCookie! "myCookie2"
    cookie2
    |> Assert.shouldBe {
        name: "myCookie2",
        value: "value2",
        domain: ".adomurad.github.io",
        path: "/e2e-test-page",
        sameSite: Strict,
        # TODO - bug in Roc compiler - U32 -> I64
        expiry: Session,
        secure: Bool.true,
        httpOnly: Bool.true,
    }
