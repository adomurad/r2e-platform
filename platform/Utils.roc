import Host

Utils :: [].{
	get_time_milis! : {} => U64
	get_time_milis! = |{}| {
		Host.get_time_milis!({}).to_u64_wrap()
	}

	reset_test_log_bucket! : {} => {}
	reset_test_log_bucket! = |{}|
		Host.reset_test_log_bucket!({})

	get_logs_from_bucket! : {} => List(Str)
	get_logs_from_bucket! = |{}|
		Host.get_logs_from_bucket!({})

	get_test_name_filter! : {} => [FilterTests(Str), NoFilter]
	get_test_name_filter! = |{}| {
		val = Host.get_test_name_filter!({})

		if val |> Str.is_empty {
			NoFilter
		} else {
			FilterTests(val)
		}
	}

	set_timeouts! : { assert_timeout : U64, page_load_timeout : U64, script_execution_timeout : U64, element_implicit_timeout : U64 } => {}
	set_timeouts! = |{ assert_timeout, page_load_timeout, script_execution_timeout, element_implicit_timeout }|
		Host.set_timeouts!(assert_timeout, page_load_timeout, script_execution_timeout, element_implicit_timeout)

	set_assert_timeout_override! : U64 => {}
	set_assert_timeout_override! = |timeout|
		Host.set_assert_timeout_override!(timeout)

	set_page_load_timeout_override! : U64 => {}
	set_page_load_timeout_override! = |timeout|
		Host.set_page_load_timeout_override!(timeout)

	set_script_timeout_override! : U64 => {}
	set_script_timeout_override! = |timeout|
		Host.set_script_timeout_override!(timeout)

	set_implicit_timeout_override! : U64 => {}
	set_implicit_timeout_override! = |timeout|
		Host.set_implicit_timeout_override!(timeout)

	reset_test_overrides! : {} => {}
	reset_test_overrides! = |{}|
		Host.reset_test_overrides!({})

	set_window_size! : [Size(U64, U64)] => {}
	set_window_size! = |Size(x, y)| {
		size = "${x.to_str()},${y.to_str()}"
		Host.set_window_size!(size)
	}

	set_window_size_override! : [Size(U64, U64)] => {}
	set_window_size_override! = |Size(x, y)| {
		size = "${x.to_str()},${y.to_str()}"
		Host.set_window_size_override!(size)
	}

	get_assert_timeout! : {} => U64
	get_assert_timeout! = |{}|
		Host.get_assert_timeout!({})

}
