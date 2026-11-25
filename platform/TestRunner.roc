import Debug
import Browser
import Test
import Config
import Utils
import Error
import InternalReporting

TestRunner :: [].{

	run_tests! : List(Test.TestCase), Config => Try({}, Error.PlatformError)
	run_tests! = |test_cases, config| {
		Debug.print_line!("Starting test run...")

		test_filter = Utils.get_test_name_filter!({})
		print_filter_warning!(test_filter)

		start_time = Utils.get_time_milis!({})

		filtered_test_cases = test_cases.keep_if(filter_test_case(test_filter))

		results = run_all!(0, filtered_test_cases, config, [])

		end_time = Utils.get_time_milis!({})
		duration = end_time - start_time

		reporters = config.reporters
		out_dir = config.results_dir_name
		InternalReporting.run_reporters!(reporters, results, out_dir, duration)?

		print_result_summary!(results)

		any_failures =
			results
				.keep_if(is_final_result)
				.any(|{ result, .. }| result.is_err())

		if any_failures {
			Err(TestRunFailed)
		} else {
			Ok({})
		}
	}

	run_all! : U64, List(Test.TestCase), Config, List(InternalReporting.TestRunResult) => List(InternalReporting.TestRunResult)
	run_all! = |index, test_cases, config, results| {
		match test_cases {
			[] => results
			[test_case, .. as rest] => {
				number_of_attempts = get_or_override_attempts(config, test_case)
				results_with_test = run_attempts!(index, 1, number_of_attempts, test_case, config, results)
				run_all!(index + 1, rest, config, results_with_test)
			}
		}
	}

	run_attempts! : U64, U64, U64, Test.TestCase, Config, List(InternalReporting.TestRunResult) => List(InternalReporting.TestRunResult)
	run_attempts! = |index, attempt, max_attempts, test_case, config, results| {
		res = run_test!(index, attempt, test_case, config)

		match res.result {
			Ok(_) => results.append(res)
			Err(_) =>
				if attempt < max_attempts {
					attempt_res = { ..res, type: Attempt }
					run_attempts!(index, attempt + 1, max_attempts, test_case, config, results.append(attempt_res))
				} else {
					results.append(res)
				},
		}
	}

	run_test! : U64, U64, Test.TestCase, Config => InternalReporting.TestRunResult
	run_test! = |index, attempt, test_case, config| {
		index_str = (index + 1).to_str()

		test_case.config.assert_timeout |> run_if_override!(Utils.set_assert_timeout_override!)
		test_case.config.page_load_timeout |> run_if_override!(Utils.set_page_load_timeout_override!)
		test_case.config.script_execution_timeout |> run_if_override!(Utils.set_script_timeout_override!)
		test_case.config.element_implicit_timeout |> run_if_override!(Utils.set_implicit_timeout_override!)
		test_case.config.window_size |> run_if_override!(Utils.set_window_size_override!)

		should_take_screenshot = match test_case.config.screenshot_on_fail {
			Override(val) => val
			Inherit => config.screenshot_on_fail
		}

		attempt_str = if attempt > 1 { " (attempt ${attempt.to_str()})" } else { "" }

		Debug.print_line!("") # empty line for readability
		Debug.print_line!("${color.gray}Test ${index_str}:${color.end} \"${test_case.name}\"${attempt_str}: Running...")

		Utils.reset_test_log_bucket!({})

		start_time = Utils.get_time_milis!({})
		result_with_maybe_screenshot = run_test_safe!(test_case.test_body, should_take_screenshot)
		end_time = Utils.get_time_milis!({})
		duration = end_time - start_time

		Utils.reset_test_overrides!({})

		{ result, screenshot } = match result_with_maybe_screenshot {
			Ok({}) => { result: Ok({}), screenshot: NoScreenshot }
			Err(ResultWithoutScreenshot(res)) => { result: Err(res), screenshot: NoScreenshot }
			Err(ResultWithScreenshot(res, screen_base64)) => { result: Err(res), screenshot: Screenshot(screen_base64) }
		}

		test_logs = Utils.get_logs_from_bucket!({})

		test_case_result = {
			name: test_case.name,
			result,
			duration,
			screenshot,
			logs: test_logs,
			type: FinalResult,
		}

		result_log_message = match result {
			Ok({}) =>
				"${color.gray}Test ${index_str}:${color.end} \"${test_case.name}\": ${color.green}OK${color.end}"

			Err(err) =>
				match Error.web_driver_error_to_str(err) {
					StringError(str_err) =>
						"${color.gray}Test ${index_str}:${color.end} \"${test_case.name}\": ${color.red}${str_err}${color.end}"

					unhandled_error =>
						"${color.gray}Test ${index_str}:${color.end} \"${test_case.name}\": ${color.red}${Str.inspect(unhandled_error)}${color.end}"
				}
		}

		Debug.print_line!(result_log_message)

		test_case_result
	}

	run_test_safe! : Test.TestBody, [Yes, No] => Try({}, [ResultWithScreenshot(Error.PlatformError, Str), ResultWithoutScreenshot(Error.PlatformError)])
	run_test_safe! = |test_body!, should_take_screenshot| {
		browser = Browser.open_new_window!({})
			.map_err(|WebDriverError(msg)| ResultWithoutScreenshot(WebDriverError(msg)))?

		test_result = test_body!(browser)

		screenshot_result =
			if test_result.is_err() and should_take_screenshot == Yes {
				take_conditional_screenshot!(browser)
			} else {
				NoScreenshot
			}

		Browser.close_window!(browser)
			.map_err(|WebDriverError(msg)| ResultWithoutScreenshot(WebDriverError(msg)))?

		match test_result {
			Ok({}) => Ok({})
			Err(res) =>
				match screenshot_result {
					NoScreenshot => Err(ResultWithoutScreenshot(res))
					ScreenshotBase64(screenshot) => Err(ResultWithScreenshot(res, screenshot))
				},
		}
	}

	take_conditional_screenshot! : Browser => [ScreenshotBase64(Str), NoScreenshot]
	take_conditional_screenshot! = |browser|
		match browser.take_screenshot_base64!() {
			Ok(screenshot) => ScreenshotBase64(screenshot)
			Err(_) => NoScreenshot
		}

	## Report helpers

	is_final_result = |{ type, .. }| type == FinalResult

	print_result_summary! : List(InternalReporting.TestRunResult) => {}
	print_result_summary! = |results| {
		Debug.print_line!("") # empty line
		Debug.print_line!("Summary:")

		final_results = results.keep_if(is_final_result)
		total_count = final_results.len()
		error_count = final_results.count_if(|{ result, .. }| result.is_err())
		success_count = total_count - error_count
		total_count_str = total_count.to_str()
		error_count_str = error_count.to_str()
		success_count_str = success_count.to_str()

		msg = "Total:\t${total_count_str}\nPass:\t${success_count_str}\nFail:\t${error_count_str}"
		msg_with_color =
			if error_count > 0 {
				"${color.red}${msg}${color.end}"
			} else {
				"${color.green}${msg}${color.end}"
			}

		Debug.print_line!("${msg_with_color}\n")
	}

	print_filter_warning! = |test_filter|
		match test_filter {
			FilterTests(str) => Debug.print_line!("\n${color.yellow}FILTER: running only tests containing the str: \"${str}\"${color.end}")
			NoFilter => {}
		}

	filter_test_case = |filter|
		|test_case|
			match filter {
				FilterTests(str) => test_case.name.contains(str)
				NoFilter => True
			}

	get_or_override_attempts = |main_config, test_case|
		match test_case.config.attempts {
			Inherit => main_config.attempts
			Override(num) => num
		}

	run_if_override! : [Inherit, Override(a)], (a => {}) => {}
	run_if_override! = |value, task!|
		match value {
			Override(val) => task!(val)
			Inherit => {}
		}

	color = {
		gray: "\u(001b)[4;90m",
		red: "\u(001b)[91m",
		green: "\u(001b)[92m",
		yellow: "\u(001b)[33m",
		end: "\u(001b)[0m",
	}
}
