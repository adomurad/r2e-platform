Config := {
	results_dir_name : Str,
	attempts : U64,
	screenshot_on_fail : [Yes, No],
	assert_timeout : U64,
	page_load_timeout : U64,
	script_execution_timeout : U64,
	element_implicit_timeout : U64,
	window_size : [Size(U64, U64)],
}.{

	default_config : () -> Config
	default_config = || {
		results_dir_name: "testResults",
		screenshot_on_fail: Yes,
		attempts: 2,
		assert_timeout: 3_000,
		page_load_timeout: 30_000,
		script_execution_timeout: 30_000,
		element_implicit_timeout: 5_000,
		window_size: Size(1024, 768),
	}

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
