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
    test23,
    test24,
    test25,
    test26,
    test27,
    test28,
    test29,
    test30,
    test31,
]

test1 = test "navigation" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/" |> try

    browser |> Browser.navigateTo! "https://www.roc-lang.org/" |> try
    browser |> Assert.urlShouldBe! "https://www.roc-lang.org/" |> try

    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    browser |> Assert.urlShouldBe! "https://devexpress.github.io/testcafe/example/"

test2 = test "open and close browser windows" \_browser ->
    browser2 = Browser.openNewWindow! {} |> try
    browser2 |> Browser.navigateTo! "https://www.roc-lang.org/" |> try
    browser2 |> Browser.closeWindow!

test3 = test "openNewWindowWithCleanup" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    Browser.openNewWindowWithCleanup! \browser2 ->
        browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"

test4 = test "window move" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    _newRect = browser |> Browser.setWindowRect! (Move { x: 400, y: 600 }) |> try

    # newRect.x |> Assert.shouldBe 406
    Ok {}

test5 = test "window resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    _newRect = browser |> Browser.setWindowRect! (Resize { width: 800, height: 750 }) |> try

    # newRect.width |> Assert.shouldBe 800
    Ok {}

test6 = test "window move and resize" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    _newRect = browser |> Browser.setWindowRect! (MoveAndResize { x: 400, y: 600, width: 800, height: 750 }) |> try

    # newRect.x |> Assert.shouldBe! 406
    # newRect.width |> Assert.shouldBe 800
    Ok {}

test7 = test "getWindowRect" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    _rect = browser |> Browser.getWindowRect! |> try

    # rect.x |> Assert.shouldBe! 16
    # rect.width |> Assert.shouldBeGreaterThan 0
    Ok {}

test8 = test "getTitle" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    title = browser |> Browser.getTitle! |> try

    title |> Assert.shouldBe "TestCafe Example Page"

test9 = test "getTitle assert" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    browser |> Assert.titleShouldBe! "TestCafe Example Page"

test10 = test "getUrl" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    url = browser |> Browser.getUrl! |> try

    url |> Assert.shouldBe "https://devexpress.github.io/testcafe/example/"

test11 = test "browser navigation operations" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    browser |> Browser.navigateTo! "https://google.com" |> try
    browser |> Browser.navigateTo! "https://roc-lang.org" |> try
    browser |> Browser.reloadPage! |> try
    browser |> Browser.navigateBack! |> try
    browser |> Browser.navigateBack! |> try
    browser |> Browser.navigateForward! |> try
    browser |> Browser.navigateForward!

test12 = test "window max, min, full" \browser ->

    # cannot run this on my machine
    # rect2 = browser |> Browser.minimizeWindow!
    # rect2.x |> Assert.shouldBe! 16
    # rect2.width |> Assert.shouldBe! 1919

    _rect3 = browser |> Browser.fullScreenWindow! |> try
    # rect3.x |> Assert.shouldBe! 0
    # rect3.width |> Assert.shouldBe! 3840

    when browser |> Browser.maximizeWindow! is
        Ok _ -> Ok {}
        Err err -> Err err
# Ok {}
# rect1.x |> Assert.shouldBe! 6
# rect1.width |> Assert.shouldBe! 3828

test13 = test "executeJs return int" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithOutput! "return 50 + 5;" |> try
    response |> Assert.shouldBe 55

test14 = test "executeJs return float" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;" |> try
    response |> Assert.shouldBe 55.5

test15 = test "executeJs return string" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;" |> try
    response |> Assert.shouldBe "55.5"

test16 = test "executeJs return bool to str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithOutput! "return true" |> try
    response |> Assert.shouldBe "true"

test17 = test "executeJs return bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithOutput! "return true" |> try
    response |> Assert.shouldBe Bool.true

test18 = test "executeJs" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    browser |> Browser.executeJs! "console.log(\"test\");"

test19 = test "executeJsWithArgs" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try

    response = browser |> Browser.executeJsWithArgs! "return 50.5 + 5;" [Number 55.5, String "5"] |> try
    response |> Assert.shouldBe 55.5

test20 = test "cookies add, get, getAll" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser |> Browser.addCookie! { name: "myCookie", value: "value1" } |> try

    cookies1 = browser |> Browser.getAllCookies! |> try
    cookies1 |> List.len |> Assert.shouldBe 1 |> try

    browser |> Browser.addCookie! { name: "myCookie2", value: "value2" } |> try

    cookies2 = browser |> Browser.getAllCookies! |> try
    cookies2 |> List.len |> Assert.shouldBe 2 |> try

    cookie1 = browser |> Browser.getCookie! "myCookie" |> try
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
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser |> Browser.addCookie! { name: "myCookie", value: "value1" } |> try
    browser |> Browser.addCookie! { name: "myCookie2", value: "value2" } |> try
    browser |> Browser.addCookie! { name: "myCookie3", value: "value3" } |> try

    cookies1 = browser |> Browser.getAllCookies! |> try
    cookies1 |> List.len |> Assert.shouldBe 3 |> try

    browser |> Browser.deleteCookie! "myCookie2" |> try

    cookies2 = browser |> Browser.getAllCookies! |> try
    cookies2 |> List.len |> Assert.shouldBe 2 |> try

    browser |> Browser.deleteCookie! "fake-cookie" |> try

    cookies3 = browser |> Browser.getAllCookies! |> try
    cookies3 |> List.len |> Assert.shouldBe 2 |> try

    browser |> Browser.deleteAllCookies! |> try

    cookies4 = browser |> Browser.getAllCookies! |> try
    cookies4 |> List.len |> Assert.shouldBe 0

test22 = test "cookies custom" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

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
    |> try

    cookie1 = browser |> Browser.getCookie! "myCookie" |> try
    cookie1
    |> Assert.shouldBe {
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
    |> try

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
    |> try

    cookie2 = browser |> Browser.getCookie! "myCookie2" |> try
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

test23 = test "getAlertText fail" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    when browser |> Browser.getAlertText! is
        Ok _ -> Assert.failWith "should fail"
        Err (AlertNotFound err) -> err |> Assert.shouldContainText "no such alert"
        Err _ -> Assert.failWith "should fail with other"

test24 = test "acceptAlert fail" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    when browser |> Browser.acceptAlert! is
        Ok _ -> Assert.failWith "should fail"
        Err (AlertNotFound err) -> err |> Assert.shouldContainText "no such alert"
        Err _ -> Assert.failWith "should fail with other"

test25 = test "dismissAlert fail" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    when browser |> Browser.dismissAlert! is
        Ok _ -> Assert.failWith "should fail"
        Err (AlertNotFound err) -> err |> Assert.shouldContainText "no such alert"
        Err _ -> Assert.failWith "should fail with other"

test26 = test "sentTextToAlert fail" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    when browser |> Browser.sendTextToAlert! "wow" is
        Ok _ -> Assert.failWith "should fail"
        Err (AlertNotFound err) -> err |> Assert.shouldContainText "no such alert"
        Err _ -> Assert.failWith "should fail with other"

test27 = test "getAlertText" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser
    |> Browser.executeJs!
        """
            alert("abcdef");
        """
    |> try

    text = browser |> Browser.getAlertText! |> try
    text |> Assert.shouldBe "abcdef"

test28 = test "acceptAlert" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser
    |> Browser.executeJs!
        """
            alert("abcdef");
        """
    |> try

    browser |> Browser.acceptAlert!

test29 = test "dismissAlert" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser
    |> Browser.executeJs!
        """
            alert("abcdef");
        """
    |> try

    browser |> Browser.dismissAlert!

test30 = test "sendTextToAlert" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    browser
    |> Browser.executeJs!
        """
            prompt("abcdef");
        """
    |> try

    browser |> Browser.sendTextToAlert! "response" |> try
    browser |> Browser.acceptAlert!

test31 = test "getPageHtml" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try

    html = browser |> Browser.getPageHtml! |> try
    html |> Assert.shouldContainText "<h1 class=\"heading\" data-testid=\"header\">Wait for elements</h1>"
