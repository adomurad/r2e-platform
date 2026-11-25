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
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        browser |> Assert.url_should_be!("https://devexpress.github.io/testcafe/example/")?

        browser.navigate_to!("https://www.roc-lang.org/")?
        browser |> Assert.url_should_be!("https://www.roc-lang.org/")?

        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        browser |> Assert.url_should_be!("https://devexpress.github.io/testcafe/example/")
    },
)

test2 = test(
    "open and close browser windows",
    |_browser| {
        browser2 = Browser.open_new_window!({})?
        browser2.navigate_to!("https://www.roc-lang.org/")?
        browser2.close_window!()
    },
)

test3 = test(
    "openNewWindowWithCleanup",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        Browser.open_new_window_with_cleanup!(
            |browser2| {
                browser2.navigate_to!("https://www.roc-lang.org/")
            },
        )
    },
)

test4 = test(
    "window move",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        _newRect = browser.set_window_rect!(Move({ x: 400, y: 600 }))?

        # newRect.x |> Assert.shouldBe 406
        Ok({})
    },
)

test5 = test(
    "window resize",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        _newRect = browser.set_window_rect!(Resize({ width: 800, height: 750 }))?

        # newRect.width |> Assert.shouldBe 800
        Ok({})
    },
)

test6 = test(
    "window move and resize",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        _newRect = browser.set_window_rect!(MoveAndResize({ x: 400, y: 600, width: 800, height: 750 }))?

        # newRect.x |> Assert.shouldBe! 406
        # newRect.width |> Assert.shouldBe 800
        Ok({})
    },
)

test7 = test(
    "getWindowRect",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        _rect = browser.get_window_rect!()?

        # rect.x |> Assert.shouldBe! 16
        # rect.width |> Assert.shouldBeGreaterThan 0
        Ok({})
    },
)

test8 = test(
    "getTitle",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        title = browser.get_title!()?

        title |> Assert.should_be("TestCafe Example Page")
    },
)

test9 = test(
    "getTitle assert",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        browser |> Assert.title_should_be!("TestCafe Example Page")
    },
)

test10 = test(
    "getUrl",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        url = browser.get_url!()?

        url |> Assert.should_be("https://devexpress.github.io/testcafe/example/")
    },
)

test11 = test(
    "browser navigation operations",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        browser.navigate_to!("https://google.com")?
        browser.navigate_to!("https://roc-lang.org")?
        browser.reload_page!()?
        browser.navigate_back!()?
        browser.navigate_back!()?
        browser.navigate_forward!()?
        browser.navigate_forward!()
    },
)

test12 = test(
    "window max, min, full",
    |browser| {

        # cannot run this on my machine
        # rect2 = browser |> Browser.minimizeWindow!
        # rect2.x |> Assert.shouldBe! 16
        # rect2.width |> Assert.shouldBe! 1919

        _rect3 = browser.full_screen_window!()?
        # rect3.x |> Assert.shouldBe! 0
        # rect3.width |> Assert.shouldBe! 3840

        match browser.maximize_window!() {
            Ok(_) => {
                Ok({})
            }
            Err(err) => {
                Err(err)
            }
        }
    },
)
# Ok {}
# rect1.x |> Assert.shouldBe! 6
# rect1.width |> Assert.shouldBe! 3828

test13 = test(
    "executeJs return int",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response = browser.execute_js_with_output!("return 50 + 5;")?
        response |> Assert.should_be(55)
    },
)

test14 = test(
    "executeJs return float",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response = browser.execute_js_with_output!("return 50.5 + 5;")?
        response |> Assert.should_be(55.5)
    },
)

test15 = test(
    "executeJs return string",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response = browser.execute_js_with_output!("return 50.5 + 5;")?
        response |> Assert.should_be("55.5")
    },
)

test16 = test(
    "executeJs return bool to str",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response : Str
        response = browser.execute_js_with_output!("return true")?
        response |> Assert.should_be("true")
    },
)

test17 = test(
    "executeJs return bool",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response : Bool
        response = browser.execute_js_with_output!("return true")?
        response |> Assert.should_be(True)
    },
)

test18 = test(
    "executeJs",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        browser.execute_js!("console.log(\"test\");")
    },
)

test19 = test(
    "executeJsWithArgs",
    |browser| {
        browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        response = browser.execute_js_with_args!("return 50.5 + 5;", [Number(55.5), String("5")])?
        response |> Assert.should_be(55.5)
    },
)

test20 = test(
    "cookies add, get, getAll",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.add_cookie!({ name: "myCookie", value: "value1" })?

        cookies1 = browser.get_all_cookies!()?
        cookies1 |> List.len |> Assert.should_be(1)?

        browser.add_cookie!({ name: "myCookie2", value: "value2" })?

        cookies2 = browser.get_all_cookies!()?
        cookies2 |> List.len |> Assert.should_be(2)?

        cookie1 = browser.get_cookie!("myCookie")?
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
                secure: True,
                http_only: False,
            },
        )
    },
)

test21 = test(
    "cookies delete, deleteAll",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.add_cookie!({ name: "myCookie", value: "value1" })?
        browser.add_cookie!({ name: "myCookie2", value: "value2" })?
        browser.add_cookie!({ name: "myCookie3", value: "value3" })?

        cookies1 = browser.get_all_cookies!()?
        cookies1 |> List.len |> Assert.should_be(3)?

        browser.delete_cookie!("myCookie2")?

        cookies2 = browser.get_all_cookies!()?
        cookies2 |> List.len |> Assert.should_be(2)?

        browser.delete_cookie!("fake-cookie")?

        cookies3 = browser.get_all_cookies!()?
        cookies3 |> List.len |> Assert.should_be(2)?

        browser.delete_all_cookies!()?

        cookies4 = browser.get_all_cookies!()?
        cookies4 |> List.len |> Assert.should_be(0)
    },
)

test22 = test(
    "cookies custom",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.add_cookie!(
            {
                name: "myCookie",
                value: "value1",
                # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
                domain: "adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Lax,
                secure: True,
                http_only: True,
                expiry: MaxAge(1893456000),
            },
        )?

        cookie1 = browser.get_cookie!("myCookie")?
        cookie1
        |> Assert.should_be(
            {
                name: "myCookie",
                value: "value1",
                domain: ".adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Lax,
                expiry: cookie1.expiry,
                secure: True,
                http_only: True,
            },
        )?

        browser.add_cookie!(
            {
                name: "myCookie2",
                value: "value2",
                # TODO have to find a domain on which I can test subdomains // github.io is on public suffix
                domain: "adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Strict,
                secure: True,
                http_only: True,
                expiry: MaxAge(1893456000),
            },
        )?

        cookie2 = browser.get_cookie!("myCookie2")?
        cookie2
        |> Assert.should_be(
            {
                name: "myCookie2",
                value: "value2",
                domain: ".adomurad.github.io",
                path: "/e2e-test-page",
                same_site: Strict,
                expiry: cookie2.expiry,
                secure: True,
                http_only: True,
            },
        )
    },
)

test23 = test(
    "getAlertText fail",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        match browser.get_alert_text!() {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AlertNotFound(err)) => {
                err |> Assert.should_contain_text("no such alert")
            }
            Err(_) => {
                Assert.fail_with("should fail with other")
            }
        }
    },
)

test24 = test(
    "acceptAlert fail",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        match browser.accept_alert!() {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AlertNotFound(err)) => {
                err |> Assert.should_contain_text("no such alert")
            }
            Err(_) => {
                Assert.fail_with("should fail with other")
            }
        }
    },
)

test25 = test(
    "dismissAlert fail",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        match browser.dismiss_alert!() {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AlertNotFound(err)) => {
                err |> Assert.should_contain_text("no such alert")
            }
            Err(_) => {
                Assert.fail_with("should fail with other")
            }
        }
    },
)

test26 = test(
    "sentTextToAlert fail",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        match browser.send_text_to_alert!("wow") {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AlertNotFound(err)) => {
                err |> Assert.should_contain_text("no such alert")
            }
            Err(_) => {
                Assert.fail_with("should fail with other")
            }
        }
    },
)

test27 = test(
    "getAlertText",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.execute_js!(
            \\alert("abcdef");
        )?

        text = browser.get_alert_text!()?
        text |> Assert.should_be("abcdef")
    },
)

test28 = test(
    "acceptAlert",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.execute_js!(
            \\alert("abcdef");
        )?

        browser.accept_alert!()
    },
)

test29 = test(
    "dismissAlert",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.execute_js!(
            \\alert("abcdef");
        )?

        browser.dismiss_alert!()
    },
)

test30 = test(
    "sendTextToAlert",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.execute_js!(
            \\prompt("abcdef");
        )?

        browser.send_text_to_alert!("response")?
        browser.accept_alert!()
    },
)

test31 = test(
    "getPageHtml",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        html = browser.get_page_html!()?
        html |> Assert.should_contain_text("<h1 class=\"heading\" data-testid=\"header\">Wait for elements</h1>")
    },
)
