app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Assert

config = Config.default_config

test_cases = [
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

test1 = test(
    "navigation",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try
        browser |> Assert.url_should_be!("https://devexpress.github.io/testcafe/example/") |> try

        browser |> Browser.navigate_to!("https://www.roc-lang.org/") |> try
        browser |> Assert.url_should_be!("https://www.roc-lang.org/") |> try

        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try
        browser |> Assert.url_should_be!("https://devexpress.github.io/testcafe/example/"),
)

test2 = test(
    "open and close browser windows",
    |_browser|
        browser2 = Browser.open_new_window!({}) |> try
        browser2 |> Browser.navigate_to!("https://www.roc-lang.org/") |> try
        browser2 |> Browser.close_window!,
)

test3 = test(
    "openNewWindowWithCleanup",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        Browser.open_new_window_with_cleanup!(
            |browser2|
                browser2 |> Browser.navigate_to!("https://www.roc-lang.org/"),
        ),
)

test4 = test(
    "window move",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        _newRect = browser |> Browser.set_window_rect!(Move({ x: 400, y: 600 })) |> try

        # newRect.x |> Assert.shouldBe 406
        Ok({}),
)

test5 = test(
    "window resize",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        _newRect = browser |> Browser.set_window_rect!(Resize({ width: 800, height: 750 })) |> try

        # newRect.width |> Assert.shouldBe 800
        Ok({}),
)

test6 = test(
    "window move and resize",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        _newRect = browser |> Browser.set_window_rect!(MoveAndResize({ x: 400, y: 600, width: 800, height: 750 })) |> try

        # newRect.x |> Assert.shouldBe! 406
        # newRect.width |> Assert.shouldBe 800
        Ok({}),
)

test7 = test(
    "getWindowRect",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        _rect = browser |> Browser.get_window_rect! |> try

        # rect.x |> Assert.shouldBe! 16
        # rect.width |> Assert.shouldBeGreaterThan 0
        Ok({}),
)

test8 = test(
    "getTitle",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try
        title = browser |> Browser.get_title! |> try

        title |> Assert.should_be("TestCafe Example Page"),
)

test9 = test(
    "getTitle assert",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        browser |> Assert.title_should_be!("TestCafe Example Page"),
)

test10 = test(
    "getUrl",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try
        url = browser |> Browser.get_url! |> try

        url |> Assert.should_be("https://devexpress.github.io/testcafe/example/"),
)

test11 = test(
    "browser navigation operations",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try
        browser |> Browser.navigate_to!("https://google.com") |> try
        browser |> Browser.navigate_to!("https://roc-lang.org") |> try
        browser |> Browser.reload_page! |> try
        browser |> Browser.navigate_back! |> try
        browser |> Browser.navigate_back! |> try
        browser |> Browser.navigate_forward! |> try
        browser |> Browser.navigate_forward!,
)

test12 = test(
    "window max, min, full",
    |browser|

        # cannot run this on my machine
        # rect2 = browser |> Browser.minimizeWindow!
        # rect2.x |> Assert.shouldBe! 16
        # rect2.width |> Assert.shouldBe! 1919

        _rect3 = browser |> Browser.full_screen_window! |> try
        # rect3.x |> Assert.shouldBe! 0
        # rect3.width |> Assert.shouldBe! 3840

        when browser |> Browser.maximize_window! is
            Ok(_) -> Ok({})
            Err(err) -> Err(err),
)
# Ok {}
# rect1.x |> Assert.shouldBe! 6
# rect1.width |> Assert.shouldBe! 3828

test13 = test(
    "executeJs return int",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_output!("return 50 + 5;") |> try
        response |> Assert.should_be(55),
)

test14 = test(
    "executeJs return float",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;") |> try
        response |> Assert.should_be(55.5),
)

test15 = test(
    "executeJs return string",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;") |> try
        response |> Assert.should_be("55.5"),
)

test16 = test(
    "executeJs return bool to str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_output!("return true") |> try
        response |> Assert.should_be("true"),
)

test17 = test(
    "executeJs return bool",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_output!("return true") |> try
        response |> Assert.should_be(Bool.true),
)

test18 = test(
    "executeJs",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        browser |> Browser.execute_js!("console.log(\"test\");"),
)

test19 = test(
    "executeJsWithArgs",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        response = browser |> Browser.execute_js_with_args!("return 50.5 + 5;", [Number(55.5), String("5")]) |> try
        response |> Assert.should_be(55.5),
)

test20 = test(
    "cookies add, get, getAll",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser |> Browser.add_cookie!({ name: "myCookie", value: "value1" }) |> try

        cookies1 = browser |> Browser.get_all_cookies! |> try
        cookies1 |> List.len |> Assert.should_be(1) |> try

        browser |> Browser.add_cookie!({ name: "myCookie2", value: "value2" }) |> try

        cookies2 = browser |> Browser.get_all_cookies! |> try
        cookies2 |> List.len |> Assert.should_be(2) |> try

        cookie1 = browser |> Browser.get_cookie!("myCookie") |> try
        cookie1
        |> Assert.should_be(
            {
                name: "myCookie",
                value: "value1",
                domain: "adomurad.github.io",
                path: "/",
                same_site: None,
                expiry: Session,
                # TODO webdriver always sets true... need to investigate
                secure: Bool.true,
                http_only: Bool.false,
            },
        ),
)

test21 = test(
    "cookies delete, deleteAll",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser |> Browser.add_cookie!({ name: "myCookie", value: "value1" }) |> try
        browser |> Browser.add_cookie!({ name: "myCookie2", value: "value2" }) |> try
        browser |> Browser.add_cookie!({ name: "myCookie3", value: "value3" }) |> try

        cookies1 = browser |> Browser.get_all_cookies! |> try
        cookies1 |> List.len |> Assert.should_be(3) |> try

        browser |> Browser.delete_cookie!("myCookie2") |> try

        cookies2 = browser |> Browser.get_all_cookies! |> try
        cookies2 |> List.len |> Assert.should_be(2) |> try

        browser |> Browser.delete_cookie!("fake-cookie") |> try

        cookies3 = browser |> Browser.get_all_cookies! |> try
        cookies3 |> List.len |> Assert.should_be(2) |> try

        browser |> Browser.delete_all_cookies! |> try

        cookies4 = browser |> Browser.get_all_cookies! |> try
        cookies4 |> List.len |> Assert.should_be(0),
)

test22 = test(
    "cookies custom",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser
        |> Browser.add_cookie!(
            {
                name: "myCookie",
                value: "value1",
                # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
                domain: "adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Lax,
                secure: Bool.true,
                http_only: Bool.true,
                expiry: MaxAge(2865848396),
            },
        )
        |> try

        cookie1 = browser |> Browser.get_cookie!("myCookie") |> try
        cookie1
        |> Assert.should_be(
            {
                name: "myCookie",
                value: "value1",
                domain: ".adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Lax,
                # TODO - bug in Roc compiler - U32 -> I64
                expiry: Session,
                secure: Bool.true,
                http_only: Bool.true,
            },
        )
        |> try

        browser
        |> Browser.add_cookie!(
            {
                name: "myCookie2",
                value: "value2",
                # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
                domain: "adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Strict,
                secure: Bool.true,
                http_only: Bool.true,
                expiry: MaxAge(2865848396),
            },
        )
        |> try

        cookie2 = browser |> Browser.get_cookie!("myCookie2") |> try
        cookie2
        |> Assert.should_be(
            {
                name: "myCookie2",
                value: "value2",
                domain: ".adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Strict,
                # TODO - bug in Roc compiler - U32 -> I64
                expiry: Session,
                secure: Bool.true,
                http_only: Bool.true,
            },
        ),
)

test23 = test(
    "getAlertText fail",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        when browser |> Browser.get_alert_text! is
            Ok(_) -> Assert.fail_with("should fail")
            Err(AlertNotFound(err)) -> err |> Assert.should_contain_text("no such alert")
            Err(_) -> Assert.fail_with("should fail with other"),
)

test24 = test(
    "acceptAlert fail",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        when browser |> Browser.accept_alert! is
            Ok(_) -> Assert.fail_with("should fail")
            Err(AlertNotFound(err)) -> err |> Assert.should_contain_text("no such alert")
            Err(_) -> Assert.fail_with("should fail with other"),
)

test25 = test(
    "dismissAlert fail",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        when browser |> Browser.dismiss_alert! is
            Ok(_) -> Assert.fail_with("should fail")
            Err(AlertNotFound(err)) -> err |> Assert.should_contain_text("no such alert")
            Err(_) -> Assert.fail_with("should fail with other"),
)

test26 = test(
    "sentTextToAlert fail",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        when browser |> Browser.send_text_to_alert!("wow") is
            Ok(_) -> Assert.fail_with("should fail")
            Err(AlertNotFound(err)) -> err |> Assert.should_contain_text("no such alert")
            Err(_) -> Assert.fail_with("should fail with other"),
)

test27 = test(
    "getAlertText",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser
        |> Browser.execute_js!(
            """
                alert("abcdef");
            """,
        )
        |> try

        text = browser |> Browser.get_alert_text! |> try
        text |> Assert.should_be("abcdef"),
)

test28 = test(
    "acceptAlert",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser
        |> Browser.execute_js!(
            """
                alert("abcdef");
            """,
        )
        |> try

        browser |> Browser.accept_alert!,
)

test29 = test(
    "dismissAlert",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser
        |> Browser.execute_js!(
            """
                alert("abcdef");
            """,
        )
        |> try

        browser |> Browser.dismiss_alert!,
)

test30 = test(
    "sendTextToAlert",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        browser
        |> Browser.execute_js!(
            """
                prompt("abcdef");
            """,
        )
        |> try

        browser |> Browser.send_text_to_alert!("response") |> try
        browser |> Browser.accept_alert!,
)

test31 = test(
    "getPageHtml",
    |browser|
        browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting") |> try

        html = browser |> Browser.get_page_html! |> try
        html |> Assert.should_contain_text("<h1 class=\"heading\" data-testid=\"header\">Wait for elements</h1>"),
)
