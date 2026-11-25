import InternalReporting
import BasicHtmlReporter

Config := {
	# the directory name where the results will be stored
	results_dir_name : Str,
	# what reporters to use
	reporters : List(InternalReporting.ReporterDefinition),
	# how long asserts wait for condition | Default: 3s
	assert_timeout : U64,
	# how long to wait for page | Default: 10s
	page_load_timeout : U64,
	# how long to wait for JavaScript execution | Default: 10s
	script_execution_timeout : U64,
	# how long to wait when searching for Elements, and for Elements to become interactive | Default: 5s
	element_implicit_timeout : U64,
	# starting browser dimensions
	window_size : [Size(U64, U64)],
	# should take a screenshot on test fail? | Default: Yes
	screenshot_on_fail : [Yes, No],
	# number of attempts | Default: 2
	attempts : U64,
}.{

	## The default test configuration to run your tests.
	##
	## The defaults:
	##
	## **results_dir_name** - *"testResults"*
	##
	## **reporters** - *[BasicHtmlReporter.reporter]*
	##
	## **assert_timeout** - *3s*
	##
	## **page_load_timeout** - *10s*
	##
	## **script_execution_timeout** - *10s*
	##
	## **element_implicit_timeout** - *5s*
	##
	## **window_size** - *Size 1024 768*
	##
	## **screenshot_on_fail** - *Yes*
	##
	## **attempts** - *2*
	default_config : Config
	default_config = {
		results_dir_name: "testResults",
		reporters: [BasicHtmlReporter.reporter],
		assert_timeout: 3_000,
		page_load_timeout: 10_000,
		script_execution_timeout: 10_000,
		element_implicit_timeout: 5_000,
		window_size: Size(1024, 768),
		screenshot_on_fail: Yes,
		attempts: 2,
	}

	## The default test configuration with overrides.
	##
	## ```
	## config = Config.default_config_with({
	##     results_dir_name: "my-results",
	##     reporters: [BasicHtmlReporter.reporter, my_json_reporter],
	##     assert_timeout: 5_000,
	## })
	## ```
	default_config_with :
		{
			results_dir_name ?: Str,
			reporters ?: List(InternalReporting.ReporterDefinition),
			assert_timeout ?: U64,
			page_load_timeout ?: U64,
			script_execution_timeout ?: U64,
			element_implicit_timeout ?: U64,
			window_size ?: [Size(U64, U64)],
			screenshot_on_fail ?: [Yes, No],
			attempts ?: U64,
		}
		-> Config
	default_config_with = |overrides| {
		{
			results_dir_name: overrides.?results_dir_name ?? default_config.results_dir_name,
			reporters: overrides.?reporters ?? default_config.reporters,
			assert_timeout: overrides.?assert_timeout ?? default_config.assert_timeout,
			page_load_timeout: overrides.?page_load_timeout ?? default_config.page_load_timeout,
			script_execution_timeout: overrides.?script_execution_timeout ?? default_config.script_execution_timeout,
			element_implicit_timeout: overrides.?element_implicit_timeout ?? default_config.element_implicit_timeout,
			window_size: overrides.?window_size ?? default_config.window_size,
			screenshot_on_fail: overrides.?screenshot_on_fail ?? default_config.screenshot_on_fail,
			attempts: overrides.?attempts ?? default_config.attempts,
		}
	}
}
