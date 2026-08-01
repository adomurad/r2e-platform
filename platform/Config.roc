Config := { results_dir_name : Str }.{

	default_config = || { results_dir_name: "testResults" }

}

## default_config : R2EConfiguration _
## default_config = {
##     # the directory name where the results will be stored
##     results_dir_name: "testResults",
##     # what reporters to use (see the Reporters chapter)
##     reporters: [BasicHtmlReporter.reporter],
##     # timeout for the assertions
##     assert_timeout: 3_000,
##     # timeout for the page loads
##     page_load_timeout: 10_000,
##     # timeout for the JavaScript executions
##     script_execution_timeout: 10_000,
##     # timeout for interaction with the browser (e.g. findElement)
##     element_implicit_timeout: 5_000,
##     # browser window size
##     window_size: Size(1024, 768),
##     # should take a screenshot on test fail?
##     screenshot_on_fail : Yes
##     # number of attempts
##     attempts : 2,
## }
