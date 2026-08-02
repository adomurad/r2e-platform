import Debug
import Browser
import TestCase
import Config
import Utils
import Error

TestRunner :: [].{

	run_tests! : List(TestCase), Config => Try({}, _)
	run_tests! = |test_cases, config| {
		Debug.print_line!("Starting test run...")

		test_filter = Utils.get_test_name_filter!({})
		print_filter_warning!(test_filter)

		start_time = Utils.get_time_milis!({})

		filtered_test_cases =
			test_cases.keep_if(filter_test_case(test_filter))

		var $results = []
		var $test_index = 0

		for test_case in filtered_test_cases {
			# //
			$test_index = $test_index + 1
			number_of_attempts = get_or_override_attempts(config, test_case)

			attempt = 1

			test_result = run_test!($test_index, attempt, test_case, config)
			$results = $results.append(test_result)
		}

		end_time = Utils.get_time_milis!({})
		duration = end_time - start_time

		print_result_summary!($results)?

		any_failures = $results.keep_if(|res| res.type == FinalResult) |> List.any(|res| res.result.is_err())
		if any_failures {
			Err(TestRunFailed)
		} else {
			Ok({})
		}
	}

}

TestCaseResult(err) : {
	name : Str,
	result : Try({}, [..err]),
	duration : U64,
	screenshot : [NoScreenshot, Screenshot(Str)],
	logs : List(Str),
	type : [FinalResult, Attempt],
}

run_test! : U64, U64, TestCase, Config => TestCaseResult
run_test! = |index, attempt, test_case, config| {
	index_str = index.to_str()
	attempt_str = if attempt > 1 " (attempt ${attempt.to_str()})" else ""

	merged_config = config

	Debug.print_line!("") # empty line for readability
	Debug.print_line!("${color.gray}Test ${index_str}:${color.end} \"${test_case.name}\"${attempt_str}: Running...")

	Utils.reset_test_log_bucket!({})

	start_time = Utils.get_time_milis!({})
	result_with_maybe_screenshot = run_test_safe!(test_case.test_body, merged_config)
	end_time = Utils.get_time_milis!({})
	duration = end_time - start_time

	Utils.reset_test_overrides!({})

	# TODO: screenshot
	{ result, screenshot } =
		match result_with_maybe_screenshot {
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

	result_log_message =
		match result {
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

run_test_safe! : _, Config => Try({}, [ResultWithScreenshot(_, _), ResultWithoutScreenshot(_)])
run_test_safe! = |test_body!, config| {
	# browser = Browser.open_new_window!({}).map_err(|err| ResultWithoutScreenshot(err))?
	browser_t = Browser.open_new_window!({})

	browser = browser_t.map_err(|err| ResultWithoutScreenshot(err))?

	test_result = test_body!(browser)

	# should_take_screenshot = (test_result.is_err()) and (config.screenshot_on_fail == Yes)
	# screenshot_result = should_take_screenshot |> take_conditional_screenshot!(browser)
	screenshot_result = NoScreenshot

	Browser.close_window!(browser).map_err(|err| ResultWithoutScreenshot(err))?

	# match test_result {
	# 	Ok({}) => Ok({})
	# 	Err(res) =>
	# 		Err(ResultWithoutScreenshot(res))
	# 	}

	# match test_result {
	# 	Ok({}) => Ok({})
	#      Err(res) =>
	# }

	match test_result {
		Ok({}) => Ok({})
		Err(res) =>
			match screenshot_result {
				NoScreenshot => Err(ResultWithoutScreenshot(res))
				ScreenshotBase64(screenshot) => Err(ResultWithScreenshot(res, screenshot))
			}
		}
}

filter_test_case = |filter|
	|test_case|
		match filter {
			FilterTests(str) => test_case.name |> Str.contains(str)
			NoFilter => True
		}

print_filter_warning! = |test_filter|
	match test_filter {
		FilterTests(str) => Debug.print_line!("\n${color.yellow}FILTER: running only tests containing the str: \"${str}\"${color.end}")
		NoFilter => {}
	}

get_or_override_attempts : Config, TestCase -> U64
get_or_override_attempts = |main_config, test_case| {
	main_config.attempts

	# match test_case.config.attempts {
	# Inherit(main_config.attempts)
	# Override(num) => num
	# }
}

color = {
	gray: "\u(001b)[4;90m",
	red: "\u(001b)[91m",
	green: "\u(001b)[92m",
	yellow: "\u(001b)[33m",
	end: "\u(001b)[0m",
}

is_final_result = |test_case| test_case.type == FinalResult

print_result_summary! : List(TestCaseResult) => Try({}, _)
print_result_summary! = |results| {
	Debug.print_line!("") # empty line
	Debug.print_line!("Summary:")

	final_results = results.keep_if(is_final_result)
	total_count = final_results.len()
	error_count = final_results.count_if(|res| res.result.is_err())
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

	Ok({})
}
