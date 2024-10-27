## # Intro
##
## This is a tutorial page which contains information
## on how to use the `R2E Platform`.
##
## We will start with some basic examples, and then we will continue with more in depth topics.
##
## This page is designed to be easily searchable by using (ctrl/cmd + f).
##
## # Getting started
##
## To get started, all you need is `Roc` installed on your machine.
##
## Copy this code to a `test.roc` file:
## ```
## app [testCases, config] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.8.0/o-YITMnvpJZg-zxL2xKiCxBFlJzlEoEwdRY5a39WFZ0.tar.br" }
##
## import r2e.Test exposing [test]
## import r2e.Config
## import r2e.Browser
## import r2e.Element
## import r2e.Assert
##
## config = Config.defaultConfig
##
## testCases = [test1]
##
## test1 = test "validation message" \browser ->
##     # open the test page
##     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/"
##     # find the test count input by id
##     testCountInput = browser |> Browser.findElement! (Css "#testCount")
##     # send text to input
##     testCountInput |> Element.inputText! "2"
##     # find the submit button
##     submitButton = browser |> Browser.findElement! (Css "#submit-button")
##     # click the submit button
##     submitButton |> Element.click!
##     # find the error message
##     testCountError = browser |> Browser.findElement! (TestId "testCountError")
##     # check the error message text
##     testCountError |> Assert.elementShouldHaveText! "At least 5 tests are required"
## ```
## And run:
## ```
## roc test.roc
## ```
## You should see a browser window blink quickly, and the terminal should print:
## ```
## Starting test run...
##
## Test 1: "validation message": Running...
## Test 1: "validation message": OK
##
## Summary:
## Total:  1
## Pass:   1
## Fail:   0
## ```
## The test was so fast, you probably didn't see anything.
##
## You can also run the tests using the `DebugMode`.
## In the `DebugMode` R2E will:
## - wait between actions
## - highlight the elements you interact with
## - verbose log each action that is performed in the browser
##
## ```
## roc test.roc --debug
## ```
## Now you should be able to see the browser and the test being performed.
##
## The test report containing the results should be located at:
## `./testResults/basicHtmlReporter/index.html`
##
## If any of the tests fail, this report will contain a screenshot of the browser
## in the moment of failure.
## You can test this by change the assert in the test to:
## ```
## testCountError
## |> Assert.elementShouldHaveText! "wrong validation message"
## ```
##
## The test is self explanatory.
##
## The basic idea behind R2E api are the modules.
##
## If you want to interact with the browser, you use the `Browser` module:
## ```
## Browser.findElement
## Browser.navigateTo
## Browser.getCookie
## Browser.getUrl
## ```
## If you want to interact with elements on the page, you use the `Element` module:
## ```
## Element.click
## Element.inputText
## Element.getText
## Element.getValue
## ```
## If you want to make assertions (expects) then you use the `Assert` module:
## ```
## Assert.shouldBe
## Assert.urlShouldBe
## Assert.elementShouldBeVisible
## Assert.elementShouldHaveText
## ```
## If you need more tools to debug a test then you use the `Debug` module:
## ```
## Debug.printLine
## Debug.wait
## Debug.waitForEnterKey
## Debug.showElement
## ```
##
## # CLI
##
## The R2E Platform supports couple of cli params:
##
## - `--headless` - run the tests without the browser window (quicker and useful for CI/CD)
## - `--verbose` - verbose logging
## - `--debug` - verbose logging, wait between actions, show actions in browser
## - `--name somePattern` - filter tests to run by name (useful when writing new tests)
## - `--setup` - run only the browser and driver setup step (useful for CI/CD)
## - `--print-browser-version-only` - only prints the version of the used browser (useful for caching in CI/CD)
##
## # Config
##
## Each R2E test program defines a `config` for the platform to setup the whole test run.
##
## ```
## app [testCases, config] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.8.0/o-YITMnvpJZg-zxL2xKiCxBFlJzlEoEwdRY5a39WFZ0.tar.br" }
##
## import r2e.Test exposing [test]
## import r2e.Config
##
## config = Config.defaultConfig
## ```
##
## `Config.defaultConfig` - is the default configuration:
##
## ```
## defaultConfig : R2EConfiguration _
## defaultConfig = {
##     # the directory name where the results will be stored
##     resultsDirName: "testResults",
##     # what reporters to use (see the Reporters chapter)
##     reporters: [BasicHtmlReporter.reporter],
##     # timeout for the assertions
##     assertTimeout: 3_000,
##     # timeout for the page loads
##     pageLoadTimeout: 10_000,
##     # timeout for the JavaScript executions
##     scriptExecutionTimeout: 10_000,
##     # timeout for interaction with the browser (e.g. findElement)
##     elementImplicitTimeout: 5_000,
##     # browser window size
##     windowSize: Size 1024 768,
##     # should take a screenshot on test fail? | Default: Yes
##     screenshotOnFail : [Yes, No],
##     # number of attempts | Default: 2
##     attempts : U64,
## }
## ```
##
## You can override any of the defaults:
##
## ```
## config = Config.defaultConfigWith {
##     resultsDirName: "my-results",
##     reporters: [BasicHtmlReporter.reporter, myJsonReporter],
##     assertTimeout: 5_000,
## }
## ```
##
## # Custom Test
##
## Sometimes you need a custom configuration for a couple of tests
## that can use a slow action, or have some special needs.
##
## By creating a custom `test` function you can override the global
## configuration for couple of tests.
##
## ```
## longTest = Test.testWith {
##     pageLoadTimeout: Override 30_000,
##     scriptExecutionTimeout: Override 30_000,
##     assertTimeout: Override 8000,
##     screenshotOnFail: Override No,
##     windowSize: Override (Size 1800 400),
## }
##
## test1 = longTest "this is flaky test" \browser ->
##     # open the test page
##     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/"
## ```
##
## All possible overrides:
## ```
## ConfigOverride : {
##     assertTimeout : [Inherit, Override U64],
##     pageLoadTimeout : [Inherit, Override U64],
##     scriptExecutionTimeout : [Inherit, Override U64],
##     elementImplicitTimeout : [Inherit, Override U64],
##     windowSize : [Inherit, Override [Size U64 U64]],
##     screenshotOnFail : [Inherit, Override [Yes, No]],
##     attempts : [Inherit, Override U64],
## }
## ```
##
## # CI/CD
##
## R2E is designed to be used for automation.
##
## If you want to run the tests on Github Actions, then checkout this example repo:
##
## [https://github.com/adomurad/r2e-platform-example/blob/main/.github/workflows/run-tests.yaml](https://github.com/adomurad/r2e-platform-example/blob/main/.github/workflows/run-tests.yaml)
##
## The browser and driver are cached so they don't have to be downloaded for every test run.
##
## The results are saved to the job artifacts,
## but they could also be saved to a Github Pages branch for easier access.
##
## Work in progress..
##
## # Assert
##
## There are 2 kinds of functions in the `Assert` module:
## - functions that assert `Roc` values:
##
##   - `Assert.shouldBe`
##   - `Assert.shouldBeEqualTo`
##   - `Assert.shouldBeGreaterOrEqualTo`
##   - `Assert.shouldBeGreaterThan`
##   - `Assert.shouldBeLesserOrEqualTo`
##   - `Assert.shouldBeLesserThan`
##   - `Assert.shouldHaveLength`
##
## - function that assert values in the browser:
##
##   - `Assert.urlShouldBe`
##   - `Assert.titleShouldBe`
##   - `Assert.elementShouldBeVisible`
##   - `Assert.elementShouldHaveText`
##   - `Assert.elementShouldHaveValue`
##
## The first group fails immediately when the assertion is not met.
##
## But the second group, will wait for the assertion to be met for a specified amount of time.
##
## The default wait time is **3s**, but can be changed in the **configuration**
## by changing the `assertTimeout` in the config. (see the Config chapter)
##
## # Reporters
##
## The reporters define how to represent the test results.
##
## In the default config only 1 reporter is being used: `BasicHtmlReporter`.
##
## The `BasicHtmlReporter` represents the results as a single `HTML` file.
##
## The file will be stored in:
##
## `./testResults/basicHtmlReporter/index.html`
##
## Where the first segment is the `resultsDirName`,
## and the second segment is the reporter name.
##
## ## Customizing existing reporters
##
## You can change the name of existing reporters.
##
## ```
## customReporter =
##     Reporting.BasicHtmlReporter.reporter
##     |> Reporting.rename "myCustomReporter"
## ```
##
## Using this new `customReporter` will save the report in:
##
## `./testResults/myCustomReporter/index.html`
##
## ## Custom reporters
##
## You can create your own reporters like this:
##
## ```
## customReporter = Reporting.createReporter "myCustomReporter" \results, _meta ->
##     lenStr = results |> List.len |> Num.toStr
##     indexFile = { filePath: "index.html", content: "<h3>Test count: $(lenStr)</h3>" }
##     testFile = { filePath: "test.txt", content: "this is just a test" }
##     [indexFile, testFile]
## ```
## A test reporter is just a function that takes the results and returns a `List` of files:
##
## ```
## createReporter : Str, ReporterCallback err -> ReporterDefinition err
##
## ReporterCallback err :
##         List (TestRunResult err),
##         TestRunMetadata
##     -> List { filePath : Str, content : Str } where err implements Inspect
##
## TestRunResult err : {
##     # name of the test
##     name : Str,
##     # duration of the test [ms]
##     duration : U64,
##     # test result
##     result : Result {} []err,
##     # a screenshot when the test fails
##     screenshot : [NoScreenshot, Screenshot Str],
##     # Debug.printLine calls perfomed during this test
##     logs : List Str,
##     # final result of this test, or just a failed attempt?
##     type : [FinalResult, Attempt],
## } where err implements Inspect
##
## TestRunMetadata : {
##     # duration of the whole test run
##     duration : U64,
## }
## ```
##
## The `BasicHtmlReporter` is created the same way:
##
## [https://github.com/adomurad/r2e-platform/blob/main/platform/BasicHtmlReporter.roc](https://github.com/adomurad/r2e-platform/blob/main/platform/BasicHtmlReporter.roc)
##
## # Env
##
## Often in E2E tests you need to provide some secret data, like e.g. credentials.
##
## You can use the environment variables in R2E tests.
##
## ```
##  empty = Env.get! "FAKE_ENV_FOR_SURE_EMPTY"
##  empty |> Assert.shouldBe! ""
##
##  env = Env.get! "SECRET_ENV_KEY"
##  env |> Assert.shouldBe! "secret_value"
## ```
##
## # Roadmap
##
## - windows support - as soon as I setup Roc on windows...
## - automatic test retries
## - builtin reporters for common formats like JUnit, AllureReport, etc.
## - snapshot testing for elements and the whole page
## - Firefox, Edge, Safari support
## - working with browser alerts
##
## If something is missing or nice to have then feel free to create a feature request at [https://github.com/adomurad/r2e-platform/issues](https://github.com/adomurad/r2e-platform/issues)
##
module []
