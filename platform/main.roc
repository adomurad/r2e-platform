platform ""
    requires {} { testCases : List _ }
    exposes [
        Tutorial,
        Test,
        Browser,
        Element,
        Assert,
        Debug,
        Error,
        Reporting,
        BasicHtmlReporter,
    ]
    packages {}
    imports [InternalTest]
    provides [mainForHost]

mainForHost : Task {} I64
mainForHost =
    testCases
    |> InternalTest.runTests
    |> Task.attempt \res ->
        when res is
            Ok {} ->
                Task.ok {}

            Err _ ->
                Task.err 1
