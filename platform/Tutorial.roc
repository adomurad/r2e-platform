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
## config = Config.default_config
##
## test_cases = [test1]
##
## test1 = test("validation message", |browser|
##     # open the test page
##     browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/")?
##     # find the test count input by id
##     test_count_input = browser |> Browser.find_element!(Css("#testCount"))?
##     # send text to input
##     test_count_input |> Element.input_text!("2")?
##     # find the submit button
##     submit_button = browser |> Browser.find_element!(Css("#submit-button"))?
##     # click the submit button
##     submit_button |> Element.click!()?
##     # find the error message
##     test_count_error = browser |> Browser.find_element!(TestId("testCountError"))?
##     # check the error message text
##     test_count_error |> Assert.element_should_have_text!("At least 5 tests are required")
## )
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
## test_count_error |> Assert.element_should_have_text!("wrong validation message")?
## ```
##
## The test is self explanatory.
##
## The basic idea behind R2E api are the modules.
##
## If you want to interact with the browser, you use the `Browser` module:
## ```
## Browser.find_element!
## Browser.navigate_to!
## Browser.get_cookie!
## Browser.get_url!
## ```
## If you want to interact with elements on the page, you use the `Element` module:
## ```
## Element.click!
## Element.input_text!
## Element.get_text!
## Element.get_value!
## ```
## If you want to make assertions (expects) then you use the `Assert` module:
## ```
## Assert.should_be
## Assert.url_should_be!
## Assert.element_should_be_visible!
## Assert.element_should_have_text!
## ```
## If you need more tools to debug a test then you use the `Debug` module:
## ```
## Debug.print_line!
## Debug.wait!
## Debug.wait_for_enter_key!
## Debug.show_element!
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
## app [test_cases, config] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.8.0/o-YITMnvpJZg-zxL2xKiCxBFlJzlEoEwdRY5a39WFZ0.tar.br" }
##
## import r2e.Test exposing [test]
## import r2e.Config
##
## config = Config.default_config
## ```
##
## `Config.default_config` - is the default configuration:
##
## ```
## default_config : R2EConfiguration _
## default_config = {
##     # the directory name where the results will be stored
##     results_dir_name: "testResults",
##     # what reporters to use (see the Reporters chapter)
##     reporters: [BasicHtmlReporter.reporter],
##     # timeout for the assertions
##     assert_timeout: 3_000,
##     # timeout for the page loads
##     page_load_timeout: 10_000,
##     # timeout for the JavaScript executions
##     script_execution_timeout: 10_000,
##     # timeout for interaction with the browser (e.g. findElement)
##     element_implicit_timeout: 5_000,
##     # browser window size
##     window_size: Size(1024, 768),
##     # should take a screenshot on test fail?
##     screenshot_on_fail : Yes
##     # number of attempts
##     attempts : 2,
## }
## ```
##
## You can override any of the defaults:
##
## ```
## config = Config.default_config_with {
##     results_dir_name: "my-results",
##     reporters: [BasicHtmlReporter.reporter, my_json_reporter],
##     assert_timeout: 5_000,
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
## long_test = Test.test_with({
##     page_load_timeout: Override(30_000),
##     script_execution_timeout: Override(30_000),
##     assert_timeout: Override(8000),
##     screenshot_on_fail: Override(No),
##     window_size: Override(Size(1800, 400)),
## })
##
## test1 = long_test("this is flaky test", |browser|
##     # open the test page
##     browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/")?
## )
## ```
##
## All possible overrides:
## ```
## ConfigOverride : {
##     assert_timeout : [Inherit, Override U64],
##     page_load_timeout : [Inherit, Override U64],
##     script_execution_timeout : [Inherit, Override U64],
##     element_implicit_timeout : [Inherit, Override U64],
##     window_size : [Inherit, Override [Size U64 U64]],
##     screenshot_on_fail : [Inherit, Override [Yes, No]],
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
##   - `Assert.should_be`
##   - `Assert.should_be_equal_to`
##   - `Assert.should_be_greater_or_equal_to`
##   - `Assert.should_be_greater_than`
##   - `Assert.should_be_lesser_or_equal_to`
##   - `Assert.should_be_lesser_than`
##   - `Assert.should_have_length`
##
## - function that assert values in the browser:
##
##   - `Assert.url_should_be!`
##   - `Assert.title_should_be!`
##   - `Assert.element_should_be_visible!`
##   - `Assert.element_should_have_text!`
##   - `Assert.element_should_have_value!`
##
## The first group fails immediately when the assertion is not met.
##
## But the second group, will wait for the assertion to be met for a specified amount of time.
##
## The default wait time is **3s**, but can be changed in the **configuration**
## by changing the `assert_timeout` in the config. (see the Config chapter)
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
## Where the first segment is the `results_dir_name`,
## and the second segment is the reporter name.
##
## ## Customizing existing reporters
##
## You can change the name of existing reporters.
##
## ```
## custom_reporter =
##     Reporting.BasicHtmlReporter.reporter
##     |> Reporting.rename "myCustomReporter"
## ```
##
## Using this new `custom_reporter` will save the report in:
##
## `./testResults/myCustomReporter/index.html`
##
## ## Custom reporters
##
## You can create your own reporters like this:
##
## ```
## custom_reporter = Reporting.create_reporter("myCustomReporter", |results, _meta|
##     len_str = results |> List.len |> Num.to_str
##     index_file = { file_path: "index.html", content: "<h3>Test count: $(lenStr)</h3>" }
##     test_file = { file_path: "test.txt", content: "this is just a test" }
## )
##     [index_file, test_file]
## ```
## A test reporter is just a function that takes the results and returns a `List` of files:
##
## ```
## create_reporter : Str, ReporterCallback err -> ReporterDefinition err
##
## ReporterCallback err :
##         List (TestRunResult err),
##         TestRunMetadata
##     -> List { file_path : Str, content : Str } where err implements Inspect
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
##  empty = Env.get!("FAKE_ENV_FOR_SURE_EMPTY")?
##  empty |> Assert.should_be("")?
##
##  env = Env.get!("SECRET_ENV_KEY")?
##  env |> Assert.should_be!("secret_value")?
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
