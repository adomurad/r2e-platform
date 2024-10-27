app [testCases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Reporting
import r2e.BasicHtmlReporter
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

renamedReporter = BasicHtmlReporter.reporter |> Reporting.rename "basicRenamed"

customReporter = Reporting.createReporter "myCustomReporter" \results, _meta ->
    lenStr = results |> List.len |> Num.toStr
    indexFile = { filePath: "index.html", content: "<h3>Test count: $(lenStr)</h3>" }
    testFile = { filePath: "test.txt", content: "this is just a test" }
    screenshotCount =
        results
        |> List.countIf \{ screenshot } ->
            when screenshot is
                Screenshot _ -> Bool.true
                NoScreenshot -> Bool.false
    screenshotFile = { filePath: "screens-$(screenshotCount |> Num.toStr).txt", content: "empty" }

    [indexFile, testFile, screenshotFile]

config = Config.defaultConfigWith {
    resultsDirName: "testTestDir78",
    reporters: [renamedReporter, customReporter],
    assertTimeout: 1000,
    pageLoadTimeout: 1011,
    scriptExecutionTimeout: 12,
    elementImplicitTimeout: 13,
    windowSize: Size 500 500,
    screenshotOnFail: No,
    attempts: 3,
}

testCases = [
    test1,
    # test2,
    test3,
    test4,
    test5,
    test6,
    test7,
    test8,
]

test1Override = Test.testWith {
    pageLoadTimeout: Override 5000,
    elementImplicitTimeout: Override 5000,
}
test1 = test1Override "assertTimeout test" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity")
    res = div1 |> Assert.elementShouldBeVisible |> Task.result!
    when res is
        Ok _ -> Assert.failWith "should fail"
        Err (AssertionError err) -> err |> Assert.shouldBe "Expected element (Css \".hide-by-opacity\") to be visible (waited for 1000ms)"
        Err _ -> Assert.failWith "should fail for different reason"

# TODO - compiler error
# test2 = test "pageLoadTimeout" \browser ->
#     res = browser |> Browser.navigateTo "https://adomurad.github.io/e2e-test-page/waiting" |> Task.result!
#
#     when res is
#         Ok {} -> Assert.failWith "should fail"
#         Err (WebDriverError err) -> err |> Assert.shouldBe "hmm"

test3 = test "elementImplicitTimeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    input1 = browser |> Browser.findElement! (Css "#create-element-input")
    input1 |> Element.clear!
    input1 |> Element.inputText! "1"

    button1 = browser |> Browser.findElement! (Css "#create-element-btn")
    button1 |> Element.click!

    _ = browser |> Browser.findElement! (Css ".created-el")

    browser |> Browser.reloadPage!

    input = browser |> Browser.findElement! (Css "#create-element-input")
    input |> Element.clear!
    input |> Element.inputText! "100"

    button = browser |> Browser.findElement! (Css "#create-element-btn")
    button |> Element.click!

    res = browser |> Browser.findElement (Css ".created-el") |> Task.result!

    when res is
        Ok _ -> Assert.failWith "should fail"
        Err (ElementNotFound _) -> Task.ok {}
        Err _ -> Assert.failWith "should fail for different reason"

test4 = test "scriptExecutionTimeout" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    res =
        browser
            |> Browser.executeJs
                """
                return new Promise(res => {
                    setTimeout(() => res(), 15)
                })
                """
            |> Task.result!

    when res is
        Ok _ -> Assert.failWith "should fail"
        Err err ->
            if err |> Inspect.toStr |> Str.contains "script timeout" then
                Task.ok {}
            else
                Assert.failWith (err |> Inspect.toStr)

test5 = test "windowSize" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    { width, height } = browser |> Browser.getWindowRect!

    width |> Assert.shouldBeGreaterThan! 499
    width |> Assert.shouldBeLesserThan! 530

    height |> Assert.shouldBeGreaterThan! 499
    height |> Assert.shouldBeLesserThan! 530

customTest = Test.testWith {
    assertTimeout: Override 1,
    pageLoadTimeout: Override 1000,
    scriptExecutionTimeout: Override 200,
    elementImplicitTimeout: Override 4,
    screenshotOnFail: Override Yes,
    windowSize: Override (Size 1800 1000),
    attempts: Override 5,
}

test6 = customTest "windowSize override" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    { width, height } = browser |> Browser.getWindowRect!

    width |> Assert.shouldBeGreaterThan! 1799
    width |> Assert.shouldBeLesserThan! 1830

    height |> Assert.shouldBeGreaterThan! 999
    height |> Assert.shouldBeLesserThan! 1030

test7 = customTest "assertTimeout override" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    div1 = browser |> Browser.findElement! (Css ".hide-by-opacity")
    res = div1 |> Assert.elementShouldBeVisible |> Task.result!
    when res is
        Ok _ -> Assert.failWith "should fail"
        Err (AssertionError err) -> err |> Assert.shouldBe "Expected element (Css \".hide-by-opacity\") to be visible (waited for 1ms)"
        Err _ -> Assert.failWith "should fail for different reason"

test8 = customTest "scriptExecutionTimeout override" \browser ->
    browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"

    browser
        |> Browser.executeJs!
            """
            return new Promise(res => {
                setTimeout(() => res(), 180)
            })
            """
    res =
        browser
            |> Browser.executeJs
                """
                return new Promise(res => {
                    setTimeout(() => res(), 210)
                })
                """
            |> Task.result!

    when res is
        Ok _ -> Assert.failWith "should fail"
        Err err ->
            if err |> Inspect.toStr |> Str.contains "script timeout" then
                Task.ok {}
            else
                Assert.failWith (err |> Inspect.toStr)
