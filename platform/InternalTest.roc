module [test, testWith, runTests]

import Internal exposing [Browser]
import Debug
import Utils
import Browser
import InternalReporting
import Config exposing [R2EConfiguration]
import Error

# import Assert # without an even number of imports in this module, Roc compiler fails

ConfigOverride : {
    assertTimeout : [Inherit, Override U64],
    pageLoadTimeout : [Inherit, Override U64],
    scriptExecutionTimeout : [Inherit, Override U64],
    elementImplicitTimeout : [Inherit, Override U64],
    windowSize : [Inherit, Override [Size U64 U64]],
    screenshotOnFail : [Inherit, Override [Yes, No]],
    attempts : [Inherit, Override U64],
}

TestBody err : Browser -> Task {} [WebDriverError Str]err

TestCase err := {
    name : Str,
    testBody : TestBody err,
    config : ConfigOverride,
}

TestCaseResult err : {
    name : Str,
    result : Result {} []err,
    duration : U64,
    screenshot : [NoScreenshot, Screenshot Str],
    logs : List Str,
    type : [FinalResult, Attempt],
} where err implements Inspect

test = \name, testBody ->
    @TestCase {
        name,
        testBody,
        config: {
            assertTimeout: Inherit,
            pageLoadTimeout: Inherit,
            scriptExecutionTimeout: Inherit,
            elementImplicitTimeout: Inherit,
            windowSize: Inherit,
            screenshotOnFail: Inherit,
            attempts: Inherit,
        },
    }

testWith = \{ assertTimeout ? Inherit, pageLoadTimeout ? Inherit, scriptExecutionTimeout ? Inherit, elementImplicitTimeout ? Inherit, windowSize ? Inherit, screenshotOnFail ? Inherit, attempts ? Inherit } ->
    \name, testBody ->
        @TestCase {
            name,
            testBody,
            config: {
                assertTimeout,
                pageLoadTimeout,
                scriptExecutionTimeout,
                elementImplicitTimeout,
                windowSize,
                screenshotOnFail,
                attempts,
            },
        }

runTests : List (TestCase _), R2EConfiguration _ -> Task {} _
runTests = \testCases, config ->
    # Assert.shouldBe! 1 1 # suppressing the warning

    Debug.printLine! "Starting test run..."

    testFilter = Utils.getTestNameFilter!
    printFilterWarning! testFilter

    startTime = Utils.getTimeMilis!

    filteredTestCases =
        testCases
        |> List.keepIf (filterTestCase testFilter)

    results = Task.loop! { resultsL: [], testCasesL: filteredTestCases, indexL: 0, attempt: 1 } \{ resultsL, testCasesL, indexL, attempt } ->
        when testCasesL is
            [] -> Task.ok (Done resultsL)
            [testCase, .. as rest] ->
                # TODO better tests
                numberOfAttempts = getOrOverrideAttempts config testCase

                res = runTest! indexL attempt testCase config
                if res.result |> Result.isOk then
                    Task.ok (Step { resultsL: List.append resultsL res, testCasesL: rest, indexL: indexL + 1, attempt: 1 })
                else if attempt < numberOfAttempts then
                    attemptRes = { res & type: Attempt }
                    Task.ok (Step { resultsL: List.append resultsL attemptRes, testCasesL: testCasesL, indexL: indexL, attempt: attempt + 1 })
                else
                    Task.ok (Step { resultsL: List.append resultsL res, testCasesL: rest, indexL: indexL + 1, attempt: 1 })

    endTime = Utils.getTimeMilis!
    duration = endTime - startTime

    reporters = config.reporters
    outDir = config.resultsDirName
    # TODO - fail gracefully
    InternalReporting.runReporters! reporters results outDir duration

    printResultSummary! results

    anyFailures = results |> List.any (\{ result } -> result |> Result.isErr)
    if
        anyFailures
    then
        Task.err TestRunFailed
    else
        Task.ok {}

runTest : U64, U64, TestCase _, R2EConfiguration _ -> Task (TestCaseResult [WebDriverError Str, AssertionError Str]_) []
runTest = \i, attempt, @TestCase { name, testBody, config: testConfigOverride }, config ->
    indexStr = (i + 1) |> Num.toStr

    testConfigOverride.assertTimeout |> runIfOverride! Utils.setAssertTimeoutOverride
    testConfigOverride.pageLoadTimeout |> runIfOverride! Utils.setPageLoadTimeoutOverride
    testConfigOverride.scriptExecutionTimeout |> runIfOverride! Utils.setScriptTimeoutOverride
    testConfigOverride.elementImplicitTimeout |> runIfOverride! Utils.setImplicitTimeoutOverride
    testConfigOverride.windowSize |> runIfOverride! Utils.setWindowSizeOverride

    mergedConfig =
        when testConfigOverride.screenshotOnFail is
            Override val -> { config & screenshotOnFail: val }
            Inherit -> config

    attemptStr =
        if attempt > 1 then
            " (attempt $(attempt |> Num.toStr))"
        else
            ""

    Debug.printLine! "" # empty line for readability
    Debug.printLine! "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\"$(attemptStr): Running..."

    Utils.resetTestLogBucket!

    startTime = Utils.getTimeMilis!
    resultWithMaybeScreenshot = (runTestSafe testBody mergedConfig) |> Task.result!

    endTime = Utils.getTimeMilis!
    duration = endTime - startTime

    Utils.resetTestOverrides!

    { result, screenshot } =
        when resultWithMaybeScreenshot is
            Ok {} -> { result: Ok {}, screenshot: NoScreenshot }
            Err (ResultWithoutScreenshot res) -> { result: Err res, screenshot: NoScreenshot }
            Err (ResultWithScreenshot res screenBase64) -> { result: Err res, screenshot: Screenshot screenBase64 }

    testLogs = Utils.getLogsFromBucket!

    testCaseResult = {
        name,
        result,
        duration,
        screenshot,
        logs: testLogs,
        type: FinalResult,
    }

    resultLogMessage =
        when result is
            Ok {} ->
                "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.green)OK$(color.end)"

            Err err ->
                when Error.webDriverErrorToStr err is
                    StringError strErr ->
                        "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.red)$(strErr)$(color.end)"

                    unhandledError ->
                        "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.red)$(unhandledError |> Inspect.toStr)$(color.end)"

    Debug.printLine! resultLogMessage

    Task.ok testCaseResult

# runTestSafe : TestBody err -> Task {} _
runTestSafe = \testBody, config ->
    browser = Browser.openNewWindow |> Task.mapErr! ResultWithoutScreenshot

    testResult = testBody browser |> Task.result!

    shouldTakeScreenshot = (testResult |> Result.isErr) && (config.screenshotOnFail == Yes)
    screenshot = shouldTakeScreenshot |> takeConditionalScreenshot browser |> Task.mapErr! ResultWithoutScreenshot

    Browser.closeWindow browser |> Task.mapErr! ResultWithoutScreenshot

    when testResult is
        Ok {} -> Task.ok {}
        Err res ->
            when screenshot is
                NoScreenshot -> Task.err (ResultWithoutScreenshot res)
                ScreenshotBase64 str -> Task.err (ResultWithScreenshot res str)

# takeConditionalScreenshot : Bool, Internal.Browser -> Task [ScreenshotBase64 Str, NoScreenshot] _
takeConditionalScreenshot = \shouldTakeScreenshot, browser ->
    if shouldTakeScreenshot then
        screenshot = browser |> Browser.takeScreenshotBase64!
        Task.ok (ScreenshotBase64 screenshot)
    else
        Task.ok NoScreenshot

isFinalResult = \{ type } -> type == FinalResult

printResultSummary : List (TestCaseResult _) -> Task.Task {} _
printResultSummary = \results ->
    Debug.printLine! "" # empty line
    Debug.printLine! "Summary:"

    finalResults = results |> List.keepIf isFinalResult
    totalCount = finalResults |> List.len
    errorCount = finalResults |> List.countIf \{ result } -> result |> Result.isErr
    successCount = totalCount - errorCount
    totalCountStr = totalCount |> Num.toStr
    errorCountStr = errorCount |> Num.toStr
    successCountStr = successCount |> Num.toStr

    msg = "Total:\t$(totalCountStr)\nPass:\t$(successCountStr)\nFail:\t$(errorCountStr)"
    msgWithColor =
        if errorCount > 0 then
            "$(color.red)$(msg)$(color.end)"
        else
            "$(color.green)$(msg)$(color.end)"

    Debug.printLine "$(msgWithColor)\n"

printFilterWarning = \testFilter ->
    when testFilter is
        FilterTests str -> Debug.printLine "\n$(color.yellow)FILTER: running only tests containing the str: \"$(str)\"$(color.end)"
        NoFilter -> Task.ok {}

getOrOverrideAttempts = \mainConfig, @TestCase testCase ->
    when testCase.config.attempts is
        Inherit -> mainConfig.attempts
        Override num -> num

filterTestCase = \filter ->
    \@TestCase { name } ->
        when filter is
            FilterTests str -> name |> Str.contains str
            NoFilter -> Bool.true

runIfOverride = \value, task ->
    when value is
        Override val -> task val
        Inherit -> Task.ok {}

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    yellow: "\u(001b)[33m",
    end: "\u(001b)[0m",
}
