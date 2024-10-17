module [test, runTests]

import Internal exposing [Browser]
import Console
import Session
import Time
import InternalReporting
import Reporting.BasicHtmlReporter

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

    reporters = [Reporting.BasicHtmlReporter.reporter]
    outDir = "testResults"
    # TODO - fail gracefully
    InternalReporting.runReporters! reporters results outDir duration

    printResultSummary! results

    Task.ok {}

runTest : U64, TestCase err -> Task (TestCaseResult [WebDriverError Str]err) [] where err implements Inspect
runTest = \i, @TestCase { name, testBody } ->
    indexStr = (i + 1) |> Num.toStr

    Console.printLine! "" # empty line for readability
    Console.printLine! "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": Running..."

    startTime = Time.getTimeMilis!
    result = runTestSafe testBody |> Task.result!

    endTime = Time.getTimeMilis!
    duration = endTime - startTime

    testCaseResult = {
        name,
        result,
        duration,
        screenshot: NoScreenshot,
    }

    resultLogMessage =
        when result is
            Ok {} ->
                "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.green)OK$(color.end)"

            Err err ->
                "$(color.gray)Test $(indexStr):$(color.end) \"$(name)\": $(color.red)$(err |> Inspect.toStr)$(color.end)"

    Console.printLine! resultLogMessage

    Task.ok testCaseResult

# runTestSafe : TestBody err -> Task {} _
runTestSafe = \testBody ->
    sessionId = Session.createSession!

    browser = Internal.packBrowserData { sessionId }
    testResult = testBody browser |> Task.result!

    Session.deleteSession! sessionId

    Task.fromResult testResult

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
