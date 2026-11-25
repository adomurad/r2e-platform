app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Reporting
import r2e.BasicHtmlReporter
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

renamed_reporter = BasicHtmlReporter.reporter |> Reporting.rename("basicRenamed")

custom_reporter = Reporting.create_reporter(
    "myCustomReporter",
    |results, _meta| {
        len_str = results.len().to_str()
        index_file = { file_path: "index.html", content: "<h3>Test count: ${len_str}</h3>" }
        test_file = { file_path: "test.txt", content: "this is just a test" }
        screenshot_count =
            results
            |> List.count_if(
                |{ screenshot, .. }|
                    match screenshot {
                        Screenshot(_) => {
                            True
                        }
                        NoScreenshot => {
                            False
                        }
                    }
            )
        screenshot_file = { file_path: "screens-${screenshot_count.to_str()}.txt", content: "empty" }

        [index_file, test_file, screenshot_file]
    },
)

config = Config.default_config_with(
    {
        results_dir_name: "testTestDir78",
        reporters: [renamed_reporter, custom_reporter],
        assert_timeout: 1000,
        page_load_timeout: 1011,
        script_execution_timeout: 12,
        element_implicit_timeout: 13,
        window_size: Size(500, 500),
        screenshot_on_fail: No,
        attempts: 3,
    },
)

test_cases = [
    test1,
    # test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
]

test1_override = Test.test_with(
    {
        page_load_timeout: Override(5000),
        element_implicit_timeout: Override(5000),
    },
)
test1 = test1_override(
    "assertTimeout test",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        div1 = browser.find_element!(Css(".hide-by-opacity"))?
        res = div1 |> Assert.element_should_be_visible!
        match res {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AssertionError(err)) => {
                err |> Assert.should_be("Expected element Css(\".hide-by-opacity\") to be visible (waited for 1000ms)")
            }
            Err(_) => {
                Assert.fail_with("should fail for different reason")
            }
        }
    },
)

# TODO - compiler error
# test2 = test "pageLoadTimeout" \browser ->
#     res = browser |> Browser.navigateTo "https://adomurad.github.io/e2e-test-page/waiting" |> Task.result!
#
#     when res is
#         Ok {} -> Assert.failWith "should fail"
#         Err (WebDriverError err) -> err |> Assert.shouldBe "hmm"

test3 = test(
    "elementImplicitTimeout",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        input1 = browser.find_element!(Css("#create-element-input"))?
        input1.clear!()?
        input1.input_text!("1")?

        button1 = browser.find_element!(Css("#create-element-btn"))?
        button1.click!()?

        _ = browser.find_element!(Css(".created-el"))?

        browser.reload_page!()?

        input = browser.find_element!(Css("#create-element-input"))?
        input.clear!()?
        input.input_text!("100")?

        button = browser.find_element!(Css("#create-element-btn"))?
        button.click!()?

        res = browser.find_element!(Css(".created-el"))

        match res {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(ElementNotFound(_)) => {
                Ok({})
            }
            Err(_) => {
                Assert.fail_with("should fail for different reason")
            }
        }
    },
)

test4 = test(
    "scriptExecutionTimeout",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        res =
            browser.execute_js!(
                \\return new Promise(res => {
                \\setTimeout(() => res(), 15)
                \\})
            )

        match res {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(err) => {
                if err |> Str.inspect |> Str.contains("script timeout") {
                    Ok({})
                } else {
                    Assert.fail_with((err |> Str.inspect))
                }
            }
        }
    },
)

test5 = test(
    "windowSize",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        { width, height, .. } = browser.get_window_rect!()?

        width |> Assert.should_be_greater_than(499)?
        width |> Assert.should_be_lesser_than(530)?

        height |> Assert.should_be_greater_than(499)?
        height |> Assert.should_be_lesser_than(530)?

        Ok({})
    },
)

custom_test = Test.test_with(
    {
        assert_timeout: Override(1),
        page_load_timeout: Override(1000),
        script_execution_timeout: Override(200),
        element_implicit_timeout: Override(4),
        screenshot_on_fail: Override(Yes),
        window_size: Override(Size(1800, 1000)),
        attempts: Override(5),
    },
)

test6 = custom_test(
    "windowSize override",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        { width, height, .. } = browser.get_window_rect!()?

        width |> Assert.should_be_greater_than(1799)?
        width |> Assert.should_be_lesser_than(1830)?

        height |> Assert.should_be_greater_than(999)?
        height |> Assert.should_be_lesser_than(1030)?

        Ok({})
    },
)

test7 = custom_test(
    "assertTimeout override",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        div1 = browser.find_element!(Css(".hide-by-opacity"))?
        res = div1 |> Assert.element_should_be_visible!
        match res {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(AssertionError(err)) => {
                err |> Assert.should_be("Expected element Css(\".hide-by-opacity\") to be visible (waited for 1ms)")
            }
            Err(_) => {
                Assert.fail_with("should fail for different reason")
            }
        }
    },
)

test8 = custom_test(
    "scriptExecutionTimeout override",
    |browser| {
        browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

        browser.execute_js!(
            \\return new Promise(res => {
            \\setTimeout(() => res(), 180)
            \\})
        )?

        res =
            browser.execute_js!(
                \\return new Promise(res => {
                \\setTimeout(() => res(), 210)
                \\})
            )

        match res {
            Ok(_) => {
                Assert.fail_with("should fail")
            }
            Err(err) => {
                if err |> Str.inspect |> Str.contains("script timeout") {
                    Ok({})
                } else {
                    Assert.fail_with((err |> Str.inspect))
                }
            }
        }
    },
)
