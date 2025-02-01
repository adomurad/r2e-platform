platform ""
    requires {} { test_cases : List _, config : Config.R2EConfiguration _ }
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
    provides [main_for_host!]

main_for_host! : {} => I32
main_for_host! = |{}|
    Utils.set_timeouts!(
        {
            assert_timeout: config.assert_timeout,
            page_load_timeout: config.page_load_timeout,
            script_execution_timeout: config.script_execution_timeout,
            element_implicit_timeout: config.element_implicit_timeout,
        },
    )
    Utils.set_window_size!(config.window_size)

    when test_cases |> InternalTest.run_tests!(config) is
        Ok({}) ->
            0

        Err(_) ->
            1
