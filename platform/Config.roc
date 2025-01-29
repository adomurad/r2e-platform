module [R2EConfiguration, default_config, default_config_with]

import InternalReporting exposing [ReporterDefinition]
import BasicHtmlReporter

R2EConfiguration test_error : {
    # the directory name where the results will be stored
    results_dir_name : Str,
    # what reporters to use
    reporters : List (ReporterDefinition test_error),
    # how long asserts wait for condition | Default: 3s
    assert_timeout : U64,
    # how long to wait for page | Default: 10s
    page_load_timeout : U64,
    # how long to wait for JavaScript execution | Default: 10s
    script_execution_timeout : U64,
    # how long to wait when searching for Elements, and for Elements to become interactive | Default: 5s
    element_implicit_timeout : U64,
    # starting browser dimensions
    window_size : [Size U64 U64],
    # should take a screenshot on test fail? | Default: Yes
    screenshot_on_fail : [Yes, No],
    # number of attempts | Default: 2
    attempts : U64,
}

## The default test configuration to run your tests.
##
## The defaults:
##
## **resultsDirName** - *"testResults"*
##
## **reporters** - *[BasicHtmlReporter.reporter]*
##
## **assertTimeout** - *3s*
##
## **pageLoadTimeout** - *10s*
##
## **scriptExecutionTimeout** - *10s*
##
## **elementImplicitTimeout** - *5s*
##
## **windowSize** - *Size 1024 768*
##
## **screenshotOnFail** - *Yes*
##
## **attempts** - *2*
##
## ```
## app [testCases, config] { r2e: platform "..." }
##
## import r2e.Test exposing [test]
## import r2e.Config
##
## config = Config.defaultConfig
##
## testCases = [
##     test1,
## ]
## ```
default_config : R2EConfiguration _
default_config = {
    results_dir_name: "testResults",
    reporters: [BasicHtmlReporter.reporter],
    assert_timeout: 3_000,
    page_load_timeout: 10_000,
    script_execution_timeout: 10_000,
    element_implicit_timeout: 5_000,
    window_size: Size(1024, 768),
    screenshot_on_fail: Yes,
    attempts: 2,
}

## The default test configuration with overrides.
##
## ```
## config = Config.defaultConfigWith {
##     resultsDirName: "my-results",
##     reporters: [BasicHtmlReporter.reporter, myJsonReporter],
##     assertTimeout: 5_000,
## }
## ```
default_config_with :
    {
        results_dir_name ?? Str,
        reporters ?? List (ReporterDefinition _),
        assert_timeout ?? U64,
        page_load_timeout ?? U64,
        script_execution_timeout ?? U64,
        element_implicit_timeout ?? U64,
        window_size ?? [Size U64 U64],
        screenshot_on_fail ?? [Yes, No],
        attempts ?? U64,
    }
    -> R2EConfiguration _
default_config_with = |{ results_dir_name ?? default_config.results_dir_name, reporters ?? default_config.reporters, assert_timeout ?? 3_000, page_load_timeout ?? 10_000, script_execution_timeout ?? 10_000, element_implicit_timeout ?? 5_000, window_size ?? Size(1024, 768), screenshot_on_fail ?? Yes, attempts ?? 2 }| {
    results_dir_name,
    reporters,
    assert_timeout,
    page_load_timeout,
    script_execution_timeout,
    element_implicit_timeout,
    window_size,
    screenshot_on_fail,
    attempts,
}
