module [test, runTests]

import Internal exposing [Browser]
import Console
import Session
import Time
import Browser
import BasicHtmlReporter
import InternalReporting
# import Fs # without this import the compiler crashes
import Error

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
} where err implements Inspect

test = \name, testBody ->
    @TestCase {
        name,
        testBody,
    }

runTests = \testCases ->
    Console.printLine! "Starting test run..."

    startTime = Time.getTimeMilis!

    results =
        testCases
            |> List.mapWithIndex \testCase, i ->
                runTest i testCase
            |> Task.sequence!

    endTime = Time.getTimeMilis!
    duration = endTime - startTime

    reporters = [BasicHtmlReporter.reporter]
    outDir = "testResults"
    # TODO - fail gracefully
    InternalReporting.runReporters! reporters results outDir duration

    printResultSummary! results

    Task.ok {}

runTest : U64, TestCase _ -> Task (TestCaseResult [WebDriverError Str, AssertionError Str]_) []
runTest = \i, @TestCase { name, testBody } ->
    indexStr = (i + 1) |> Num.toStr

    Console.printLine! "" # empty line for readability
    Console.printLine! "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": Running..."

    startTime = Time.getTimeMilis!
    # result = runTestSafe testBody |> Task.result!
    resultWithMaybeScreenshot = (runTestSafe testBody) |> Task.result!

    endTime = Time.getTimeMilis!
    duration = endTime - startTime

    { result, screenshot } =
        when resultWithMaybeScreenshot is
            Ok {} -> { result: Ok {}, screenshot: NoScreenshot }
            Err (ResultWithoutScreenshot res) -> { result: Err res, screenshot: NoScreenshot }
            Err (ResultWithScreenshot res screenBase64) -> { result: Err res, screenshot: Screenshot screenBase64 }
    # result = Ok {}
    # screenshot = NoScreenshot

    testCaseResult = {
        name,
        result,
        duration,
        # screenshot: NoScreenshot,
        screenshot,
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

    Console.printLine! resultLogMessage

    Task.ok testCaseResult

# runTestSafe : TestBody err -> Task {} _
runTestSafe = \testBody ->
    sessionId = Session.createSession |> Task.mapErr! ResultWithoutScreenshot
    # TODO - this hack might help with test flickers
    Console.wait! 20

    browser = Internal.packBrowserData { sessionId }
    testResult = testBody browser |> Task.result!

    shouldTakeScreenshot = testResult |> Result.isErr
    screenshot = shouldTakeScreenshot |> takeConditionalScreenshot browser |> Task.mapErr! ResultWithoutScreenshot

    Session.deleteSession sessionId |> Task.mapErr! ResultWithoutScreenshot

    when testResult is
        Ok {} -> Task.ok {}
        Err res ->
            when screenshot is
                NoScreenshot -> Task.err (ResultWithoutScreenshot res)
                ScreenshotBase64 str -> Task.err (ResultWithScreenshot res str)

# takeConditionalScreenshot : Bool, Internal.Browser -> Task [ScreenshotBase64 Str, NoScreenshot] _
takeConditionalScreenshot = \shouldTakeScreenshot, browser ->
    if shouldTakeScreenshot then
        screenshot =
            browser
                |> Browser.getScreenshotBase64!
        Task.ok (ScreenshotBase64 screenshot)
    else
        Task.ok NoScreenshot

printResultSummary : List (TestCaseResult _) -> Task.Task {} _
printResultSummary = \results ->
    Console.printLine! "" # empty line
    Console.printLine! "Summary:"

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

    Console.printLine "$(msgWithColor)\n"

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    end: "\u(001b)[0m",
}
