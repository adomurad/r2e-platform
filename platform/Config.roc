module [R2EConfiguration, defaultConfig, defaultConfigWith]

import InternalReporting exposing [ReporterDefinition]
import BasicHtmlReporter

R2EConfiguration testError : {
    # the directory name where the results will be stored
    resultsDirName : Str,
    # what reporters to use
    reporters : List (ReporterDefinition testError),
    # how long asserts wait for condition | Default: 3s
    assertTimeout : U64,
    # how long to wait for page | Default: 10s
    pageLoadTimeout : U64,
    # how long to wait for JavaScript execution | Default: 10s
    scriptExecutionTimeout : U64,
    # how long to wait when searching for Elements, and for Elements to become interactive | Default: 5s
    elementImplicitTimeout : U64,
    # starting browser dimensions
    windowSize : [Size U64 U64],
    # should take a screenshot on test fail? | Default: Yes
    screenshotOnFail : [Yes, No],
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
defaultConfig : R2EConfiguration _
defaultConfig = {
    resultsDirName: "testResults",
    reporters: [BasicHtmlReporter.reporter],
    assertTimeout: 3_000,
    pageLoadTimeout: 10_000,
    scriptExecutionTimeout: 10_000,
    elementImplicitTimeout: 5_000,
    windowSize: Size 1024 768,
    screenshotOnFail: Yes,
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
defaultConfigWith :
    {
        resultsDirName ? Str,
        reporters ? List (ReporterDefinition _),
        assertTimeout ? U64,
        pageLoadTimeout ? U64,
        scriptExecutionTimeout ? U64,
        elementImplicitTimeout ? U64,
        windowSize ? [Size U64 U64],
        screenshotOnFail ? [Yes, No],
        attempts ? U64,
    }
    -> R2EConfiguration _
defaultConfigWith = \{ resultsDirName ? defaultConfig.resultsDirName, reporters ? defaultConfig.reporters, assertTimeout ? 3_000, pageLoadTimeout ? 10_000, scriptExecutionTimeout ? 10_000, elementImplicitTimeout ? 5_000, windowSize ? Size 1024 768, screenshotOnFail ? Yes, attempts ? 2 } -> {
    resultsDirName,
    reporters,
    assertTimeout,
    pageLoadTimeout,
    scriptExecutionTimeout,
    elementImplicitTimeout,
    windowSize,
    screenshotOnFail,
    attempts,
}
