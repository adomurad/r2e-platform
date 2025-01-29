module [test, test_with, run_tests!]

import Internal exposing [Browser]
import Debug
import Utils
import Browser
import InternalReporting
import Config exposing [R2EConfiguration]
import Error

# import Assert # without an even number of imports in this module, Roc compiler fails

ConfigOverride : {
    assert_timeout : [Inherit, Override U64],
    page_load_timeout : [Inherit, Override U64],
    script_execution_timeout : [Inherit, Override U64],
    element_implicit_timeout : [Inherit, Override U64],
    window_size : [Inherit, Override [Size U64 U64]],
    screenshot_on_fail : [Inherit, Override [Yes, No]],
    attempts : [Inherit, Override U64],
}

TestBody err : Browser => Result {} [WebDriverError Str]err

TestCase err := {
    name : Str,
    test_body : TestBody err,
    config : ConfigOverride,
}

TestCaseResult err : {
    name : Str,
    result : Result {} []err,
    duration : U64,
    screenshot : [NoScreenshot, Screenshot Str],
    logs : List Str,
    type : [FinalResult, Attempt],
} where err implements Inspect

test = |name, test_body|
    @TestCase(
        {
            name,
            test_body,
            config: {
                assert_timeout: Inherit,
                page_load_timeout: Inherit,
                script_execution_timeout: Inherit,
                element_implicit_timeout: Inherit,
                window_size: Inherit,
                screenshot_on_fail: Inherit,
                attempts: Inherit,
            },
        },
    )

test_with = |{ assert_timeout ?? Inherit, page_load_timeout ?? Inherit, script_execution_timeout ?? Inherit, element_implicit_timeout ?? Inherit, window_size ?? Inherit, screenshot_on_fail ?? Inherit, attempts ?? Inherit }|
    |name, test_body|
        @TestCase(
            {
                name,
                test_body,
                config: {
                    assert_timeout,
                    page_load_timeout,
                    script_execution_timeout,
                    element_implicit_timeout,
                    window_size,
                    screenshot_on_fail,
                    attempts,
                },
            },
        )

run_tests! : List (TestCase _), R2EConfiguration _ => Result {} _
run_tests! = |test_cases, config|
    # Assert.shouldBe 1 1 |> try # suppressing the warning

    Debug.print_line!("Starting test run...")

    test_filter = Utils.get_test_name_filter!({})
    print_filter_warning!(test_filter)

    start_time = Utils.get_time_milis!({})

    filtered_test_cases =
        test_cases
        |> List.keep_if(filter_test_case(test_filter))

    results = loop!(
        { results_l: [], test_cases_l: filtered_test_cases, index_l: 0, attempt: 1 },
        |{ results_l, test_cases_l, index_l, attempt }|
            when test_cases_l is
                [] -> Done(results_l)
                [test_case, .. as rest] ->
                    # TODO better tests
                    number_of_attempts = get_or_override_attempts(config, test_case)

                    res = run_test!(index_l, attempt, test_case, config)
                    if res.result |> Result.is_ok then
                        Step({ results_l: List.append(results_l, res), test_cases_l: rest, index_l: index_l + 1, attempt: 1 })
                    else if attempt < number_of_attempts then
                        attempt_res = { res & type: Attempt }
                        Step({ results_l: List.append(results_l, attempt_res), test_cases_l: test_cases_l, index_l: index_l, attempt: attempt + 1 })
                    else
                        Step({ results_l: List.append(results_l, res), test_cases_l: rest, index_l: index_l + 1, attempt: 1 }),
    )

    end_time = Utils.get_time_milis!({})
    duration = end_time - start_time

    reporters = config.reporters
    out_dir = config.results_dir_name
    # TODO - fail gracefully
    InternalReporting.run_reporters!(reporters, results, out_dir, duration) |> try

    print_result_summary!(results) |> try

    any_failures = results |> List.any(|{ result }| result |> Result.is_err)
    if
        any_failures
    then
        Err(TestRunFailed)
    else
        Ok({})

loop! = |initial_state, callback!|
    output = callback!(initial_state)
    when output is
        Done(result) -> result
        Step(result) -> loop!(result, callback!)

run_test! : U64, U64, TestCase _, R2EConfiguration _ => TestCaseResult [WebDriverError Str, AssertionError Str]_
run_test! = |i, attempt, @TestCase({ name, test_body, config: test_config_override }), config|
    index_str = (i + 1) |> Num.to_str

    test_config_override.assert_timeout |> run_if_override!(Utils.set_assert_timeout_override!)
    test_config_override.page_load_timeout |> run_if_override!(Utils.set_page_load_timeout_override!)
    test_config_override.script_execution_timeout |> run_if_override!(Utils.set_script_timeout_override!)
    test_config_override.element_implicit_timeout |> run_if_override!(Utils.set_implicit_timeout_override!)
    test_config_override.window_size |> run_if_override!(Utils.set_window_size_override!)

    merged_config =
        when test_config_override.screenshot_on_fail is
            Override(val) -> { config & screenshot_on_fail: val }
            Inherit -> config

    attempt_str =
        if attempt > 1 then
            " (attempt ${attempt |> Num.to_str})"
        else
            ""

    Debug.print_line!("") # empty line for readability
    Debug.print_line!("${color.gray}Test ${index_str}:${color.end} \"${name}\"${attempt_str}: Running...")

    Utils.reset_test_log_bucket!({})

    start_time = Utils.get_time_milis!({})
    result_with_maybe_screenshot = run_test_safe!(test_body, merged_config)

    end_time = Utils.get_time_milis!({})
    duration = end_time - start_time

    Utils.reset_test_overrides!({})

    { result, screenshot } =
        when result_with_maybe_screenshot is
            Ok({}) -> { result: Ok({}), screenshot: NoScreenshot }
            Err(ResultWithoutScreenshot(res)) -> { result: Err(res), screenshot: NoScreenshot }
            Err(ResultWithScreenshot(res, screen_base64)) -> { result: Err(res), screenshot: Screenshot(screen_base64) }

    test_logs = Utils.get_logs_from_bucket!({})

    test_case_result = {
        name,
        result,
        duration,
        screenshot,
        logs: test_logs,
        type: FinalResult,
    }

    result_log_message =
        when result is
            Ok({}) ->
                "${color.gray}Test ${index_str}:${color.end} \"${name}\": ${color.green}OK${color.end}"

            Err(err) ->
                when Error.web_driver_error_to_str(err) is
                    StringError(str_err) ->
                        "${color.gray}Test ${index_str}:${color.end} \"${name}\": ${color.red}${str_err}${color.end}"

                    unhandled_error ->
                        "${color.gray}Test ${index_str}:${color.end} \"${name}\": ${color.red}${unhandled_error |> Inspect.to_str}${color.end}"

    Debug.print_line!(result_log_message)

    test_case_result

run_test_safe! = |test_body!, config|
    browser = Browser.open_new_window!({}) |> Result.map_err(ResultWithoutScreenshot) |> try

    test_result = test_body!(browser)

    should_take_screenshot = (test_result |> Result.is_err) and (config.screenshot_on_fail == Yes)
    screenshot_result = should_take_screenshot |> take_conditional_screenshot!(browser)

    Browser.close_window!(browser) |> Result.map_err(ResultWithoutScreenshot) |> try

    when test_result is
        Ok({}) -> Ok({})
        Err(res) ->
            when screenshot_result is
                NoScreenshot -> Err(ResultWithoutScreenshot(res))
                ScreenshotBase64(screenshot) -> Err(ResultWithScreenshot(res, screenshot))
                err -> Err(ResultWithoutScreenshot(err))

take_conditional_screenshot! : Bool, Browser => [ScreenshotBase64 Str, NoScreenshot, WebDriverError Str]
take_conditional_screenshot! = |should_take_screenshot, browser|
    if should_take_screenshot then
        when browser |> Browser.take_screenshot_base64! is
            Ok(screenshot) ->
                ScreenshotBase64(screenshot)

            Err(err) -> err
    else
        NoScreenshot

is_final_result = |{ type }| type == FinalResult

print_result_summary! : List (TestCaseResult _) => Result {} _
print_result_summary! = |results|
    Debug.print_line!("") # empty line
    Debug.print_line!("Summary:")

    final_results = results |> List.keep_if(is_final_result)
    total_count = final_results |> List.len
    error_count = final_results |> List.count_if(|{ result }| result |> Result.is_err)
    success_count = total_count - error_count
    total_count_str = total_count |> Num.to_str
    error_count_str = error_count |> Num.to_str
    success_count_str = success_count |> Num.to_str

    msg = "Total:\t${total_count_str}\nPass:\t${success_count_str}\nFail:\t${error_count_str}"
    msg_with_color =
        if error_count > 0 then
            "${color.red}${msg}${color.end}"
        else
            "${color.green}${msg}${color.end}"

    Debug.print_line!("${msg_with_color}\n")

    Ok({})

print_filter_warning! = |test_filter|
    when test_filter is
        FilterTests(str) -> Debug.print_line!("\n${color.yellow}FILTER: running only tests containing the str: \"${str}\"${color.end}")
        NoFilter -> {}

get_or_override_attempts = |main_config, @TestCase(test_case)|
    when test_case.config.attempts is
        Inherit -> main_config.attempts
        Override(num) -> num

filter_test_case = |filter|
    |@TestCase({ name })|
        when filter is
            FilterTests(str) -> name |> Str.contains(str)
            NoFilter -> Bool.true

run_if_override! = |value, task!|
    when value is
        Override(val) -> task!(val)
        Inherit -> {}

color = {
    gray: "\u(001b)[4;90m",
    red: "\u(001b)[91m",
    green: "\u(001b)[92m",
    yellow: "\u(001b)[33m",
    end: "\u(001b)[0m",
}
