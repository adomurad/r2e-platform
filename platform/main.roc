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
    imports [Console, InternalTest]
    provides [mainForHost]

mainForHost : Task {} I32
mainForHost =
    testCases
    |> InternalTest.runTests
    |> Task.attempt \res ->
        when res is
            Ok {} -> Task.ok {}
            Err err ->
                Console.printLine "Program exited early with error: $(Inspect.toStr err)"
                |> Task.onErr \_ -> Task.err 1
                |> Task.await \_ -> Task.err 1
