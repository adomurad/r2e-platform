platform ""
    requires {} { testCases : List _, config : Config.R2EConfiguration _ }
    exposes [
        Tutorial,
        Test,
        Browser,
        Element,
        Assert,
        Debug,
        Config,
        Error,
        Reporting,
        BasicHtmlReporter,
    ]
    packages {}
    imports [InternalTest, Config, Utils]
    provides [mainForHost]

mainForHost : Task {} I64
mainForHost =
    Utils.setTimeouts! {
        assertTimeout: config.assertTimeout,
        pageLoadTimeout: config.pageLoadTimeout,
        scriptExecutionTimeout: config.scriptExecutionTimeout,
        elementImplicitTimeout: config.elementImplicitTimeout,
    }
    Utils.setWindowSize! config.windowSize

    testCases
    |> InternalTest.runTests config
    |> Task.attempt \res ->
        when res is
            Ok {} ->
                Task.ok {}

            Err _ ->
                Task.err 1
