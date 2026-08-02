module [
    get_time_milis!,
    reset_test_log_bucket!,
    get_logs_from_bucket!,
    get_test_name_filter!,
    set_timeouts!,
    set_window_size!,
    get_assert_timeout!,
    set_implicit_timeout_override!,
    set_script_timeout_override!,
    set_page_load_timeout_override!,
    set_assert_timeout_override!,
    reset_test_overrides!,
    set_window_size_override!,
]

import Effect

get_time_milis! : {} => U64
get_time_milis! = |{}|
    Effect.get_time_milis!({}) |> Num.to_u64

reset_test_log_bucket! : {} => {}
reset_test_log_bucket! = |{}|
    Effect.reset_test_log_bucket!({})

get_logs_from_bucket! : {} => List Str
get_logs_from_bucket! = |{}|
    Effect.get_logs_from_bucket!({})

get_test_name_filter! : {} => [FilterTests Str, NoFilter]
get_test_name_filter! = |{}|
    val = Effect.get_test_name_filter!({})

    if val |> Str.is_empty then
        NoFilter
    else
        FilterTests(val)

set_timeouts! : { assert_timeout : U64, page_load_timeout : U64, script_execution_timeout : U64, element_implicit_timeout : U64 } => {}
set_timeouts! = |{ assert_timeout, page_load_timeout, script_execution_timeout, element_implicit_timeout }|
    Effect.set_timeouts!(assert_timeout, page_load_timeout, script_execution_timeout, element_implicit_timeout)

set_assert_timeout_override! : U64 => {}
set_assert_timeout_override! = |timeout|
    Effect.set_assert_timeout_override!(timeout)

set_page_load_timeout_override! : U64 => {}
set_page_load_timeout_override! = |timeout|
    Effect.set_page_load_timeout_override!(timeout)

set_script_timeout_override! : U64 => {}
set_script_timeout_override! = |timeout|
    Effect.set_script_timeout_override!(timeout)

set_implicit_timeout_override! : U64 => {}
set_implicit_timeout_override! = |timeout|
    Effect.set_implicit_timeout_override!(timeout)

reset_test_overrides! : {} => {}
reset_test_overrides! = |{}|
    Effect.reset_test_overrides!({})

set_window_size! : [Size U64 U64] => {}
set_window_size! = |Size(x, y)|
    size = "${x |> Num.to_str},${y |> Num.to_str}"
    Effect.set_window_size!(size)

set_window_size_override! : [Size U64 U64] => {}
set_window_size_override! = |Size(x, y)|
    size = "${x |> Num.to_str},${y |> Num.to_str}"
    Effect.set_window_size_override!(size)

get_assert_timeout! : {} => U64
get_assert_timeout! = |{}|
    Effect.get_assert_timeout!({})
