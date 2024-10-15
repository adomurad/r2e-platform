module [test, runTests]

import Internal exposing [Browser]
import Console
import Session

TestCase err := {
    name : Str,
    testBody : Browser -> Task {} err,
}

test = \name, testBody ->
    @TestCase {
        name,
        testBody,
    }

runTests = \testCases ->
    testCases
    |> Task.forEach \testCase ->
        testCase |> runTest

runTest = \@TestCase { name, testBody } ->
    Console.printLine! "Running test: $(name)"

    sessionId = Session.createSession!

    Console.printLine! "Session id from inside roc: $(sessionId)"

    browser = Internal.packBrowserData { sessionId: "test" }
    testResult = testBody browser |> Task.result!

    Session.deleteSession! sessionId
