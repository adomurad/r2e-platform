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
        Env,
        Error,
        Reporting,
        BasicHtmlReporter,
    ]
    packages {}
    imports [InternalTest, Config, Utils]
    provides [mainForHost!]

mainForHost! : {} => I32
mainForHost! = \{} ->
    Utils.setTimeouts! {
        assertTimeout: config.assertTimeout,
        pageLoadTimeout: config.pageLoadTimeout,
        scriptExecutionTimeout: config.scriptExecutionTimeout,
        elementImplicitTimeout: config.elementImplicitTimeout,
    }
    Utils.setWindowSize! config.windowSize

    when testCases |> InternalTest.runTests! config is
        Ok {} ->
            0

        Err _ ->
            1
