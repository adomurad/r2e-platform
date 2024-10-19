platform ""
    requires {} { testCases : List _ }
    exposes [
        Tutorial,
        Test,
        Browser,
        Element,
        Assert,
        Console,
        Error,
        Reporting,
        BasicHtmlReporter,
    ]
    packages {}
    imports [InternalTest]
    provides [mainForHost]

mainForHost : Task {} I32
mainForHost =
    testCases
    |> InternalTest.runTests
    |> Task.attempt \res ->
        when res is
            Ok {} ->
                # TODO - right now I'm unable to make Task.ok {} to be interpreted by Go as discriminant 1
                # will fix when I have more time
                Task.err 0

            Err _ ->
                Task.err 1
