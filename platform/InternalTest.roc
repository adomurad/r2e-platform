module [test, runTests]

import Internal exposing [Browser]
import Debug
import Utils
import Browser
import InternalReporting
import Config exposing [R2EConfiguration]
import Error

import Assert # wihtout an even number of imports in this module, Roc compiler fails

TestBody err : Browser -> Task {} [WebDriverError Str]err

TestCase err := {
    name : Str,
    testBody : TestBody err,
}

TestCaseResult err : {
    name : Str,
    result : Result {} []err,
    duration : U64,
    screenshot : [NoScreenshot, Screenshot Str],
    logs : List Str,
} where err implements Inspect

test = \name, testBody ->
    @TestCase {
        name,
        testBody,
    }

runTests : List (TestCase _), R2EConfiguration _ -> Task {} _
runTests = \testCases, config ->
    Assert.shouldBe! 1 1 # supressing the warning

    Debug.printLine! "Starting test run..."

    testFilter = Utils.getTestNameFilter!
    printFilterWarning! testFilter

    startTime = Utils.getTimeMilis!

    results =
        testCases
            |> List.keepIf (filterTestCase testFilter)
            |> List.mapWithIndex \testCase, i ->
                runTest i testCase config
            |> Task.sequence!

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

runTest : U64, TestCase _, R2EConfiguration _ -> Task (TestCaseResult [WebDriverError Str, AssertionError Str]_) []
runTest = \i, @TestCase { name, testBody }, config ->
    indexStr = (i + 1) |> Num.toStr

    Debug.printLine! "" # empty line for readability
    Debug.printLine! "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": Running..."

    Utils.incrementTest!

    startTime = Utils.getTimeMilis!
    resultWithMaybeScreenshot = (runTestSafe testBody config) |> Task.result!

    endTime = Utils.getTimeMilis!
    duration = endTime - startTime

    { result, screenshot } =
        when resultWithMaybeScreenshot is
            Ok {} -> { result: Ok {}, screenshot: NoScreenshot }
            Err (ResultWithoutScreenshot res) -> { result: Err res, screenshot: NoScreenshot }
            Err (ResultWithScreenshot res screenBase64) -> { result: Err res, screenshot: Screenshot screenBase64 }

    testLogs = Utils.getLogsForTest! (i + 1 |> Num.toI64)

    testCaseResult = {
        name,
        result,
        duration,
        screenshot,
        logs: testLogs,
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

printResultSummary : List (TestCaseResult _) -> Task.Task {} _
printResultSummary = \results ->
    Debug.printLine! "" # empty line
    Debug.printLine! "Summary:"

    totalCount = results |> List.len
    errorCount = results |> List.countIf \{ result } -> result |> Result.isErr
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

filterTestCase = \filter ->
    \@TestCase { name } ->
        when filter is
            FilterTests str -> name |> Str.contains str
            NoFilter -> Bool.true

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    yellow: "\u(001b)[33m",
    end: "\u(001b)[0m",
}
