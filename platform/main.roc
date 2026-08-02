platform ""
	requires {
		test_cases : List(TestCase),
		config : Config
	}
	exposes [TestCase, Config, Debug]
	packages {}
	provides { "roc_main": main_for_host! }
	hosted {
		"roc_stdin_line": Host.stdin_line!,
		"roc_stdout_line": Host.stdout_line!,
		"roc_set_timeouts": Host.set_timeouts!,
		"roc_set_script_timeout_override": Host.set_script_timeout_override!,
		"roc_set_assert_timeout_override": Host.set_assert_timeout_override!,
		"roc_set_page_load_timeout_override": Host.set_page_load_timeout_override!,
		"roc_set_implicit_timeout_override": Host.set_implicit_timeout_override!,
		"roc_reset_test_overrides": Host.reset_test_overrides!,
		"roc_set_window_size": Host.set_window_size!,
		"roc_set_window_size_override": Host.set_window_size_override!,
		"roc_get_assert_timeout": Host.get_assert_timeout!,
		"roc_wait": Host.wait!,
		"roc_get_time_milis": Host.get_time_milis!,
		"roc_is_debug_mode": Host.is_debug_mode!,
		"roc_is_verbose": Host.is_verbose!,
		"roc_reset_test_log_bucket": Host.reset_test_log_bucket!,
		"roc_get_logs_from_bucket": Host.get_logs_from_bucket!,
		"roc_get_test_name_filter": Host.get_test_name_filter!,
		"roc_create_dir_if_not_exist": Host.create_dir_if_not_exist!,
		"roc_file_write_utf8": Host.file_write_utf8!,
		"roc_start_session": Host.start_session!,
		"roc_delete_session": Host.delete_session!,
		"roc_browser_navigate_to": Host.browser_navigate_to!,
		"roc_browser_find_element": Host.browser_find_element!,
		"roc_browser_find_elements": Host.browser_find_elements!,
		"roc_element_click": Host.element_click!,
		"roc_browser_get_screenshot": Host.browser_get_screenshot!,
		"roc_add_cookie": Host.add_cookie!,
		"roc_get_cookie": Host.get_cookie!,
		"roc_get_all_cookies": Host.get_all_cookies!,
		"roc_delete_cookie": Host.delete_cookie!,
		"roc_delete_all_cookies": Host.delete_all_cookies!,
		"roc_alert_dismiss": Host.alert_dismiss!,
		"roc_alert_send_text": Host.alert_send_text!,
		"roc_alert_get_text": Host.alert_get_text!,
		"roc_alert_accept": Host.alert_accept!,
		"roc_element_get_text": Host.element_get_text!,
		"roc_element_is_selected": Host.element_is_selected!,
		"roc_element_is_displayed": Host.element_is_displayed!,
		"roc_element_get_attribute": Host.element_get_attribute!,
		"roc_element_get_property": Host.element_get_property!,
		"roc_element_send_keys": Host.element_send_keys!,
		"roc_element_clear": Host.element_clear!,
		"roc_element_find_element": Host.element_find_element!,
		"roc_element_find_elements": Host.element_find_elements!,
		"roc_element_get_tag": Host.element_get_tag!,
		"roc_element_get_css": Host.element_get_css!,
		"roc_element_get_rect": Host.element_get_rect!,
		"roc_browser_set_window_rect": Host.browser_set_window_rect!,
		"roc_browser_get_window_rect": Host.browser_get_window_rect!,
		"roc_browser_get_title": Host.browser_get_title!,
		"roc_browser_get_url": Host.browser_get_url!,
		"roc_browser_reload": Host.browser_reload!,
		"roc_browser_navigate_back": Host.browser_navigate_back!,
		"roc_browser_navigate_forward": Host.browser_navigate_forward!,
		"roc_browser_maximize": Host.browser_maximize!,
		"roc_browser_minimize": Host.browser_minimize!,
		"roc_browser_full_screen": Host.browser_full_screen!,
		"roc_execute_js": Host.execute_js!,
		"roc_get_env": Host.get_env!,
		"roc_get_page_source": Host.get_page_source!,
		"roc_switch_to_frame_by_element_id": Host.switch_to_frame_by_element_id!,
		"roc_switch_to_parent_frame": Host.switch_to_parent_frame!,
	}
	targets: {
		inputs_dir: "targets/",
		x64mac: { inputs: ["libhost.a", app] },
		arm64mac: { inputs: ["libhost.a", app] },
		x64musl: { inputs: ["crt1.o", "libhost.a", app, "libc.a"] },
		arm64musl: { inputs: ["crt1.o", "libhost.a", app, "libc.a"] },
		x64win: { inputs: ["host.lib", app] },
		arm64win: { inputs: ["host.lib", app] },
	}

import Host
import Config
import TestRunner
import TestCase
import Debug
import DebugMode
import Browser
import Element

main_for_host! : () => I32
main_for_host! = || {
	# result = main!(args)
	match TestRunner.run_tests!(test_cases, config) {
		Ok({}) => 0
		Err(_) => 1
	}

	# match result {
	# 	Ok({}) => 0
	# 	Err(Exit(code)) => code
	# 	Err(other) => {
	# 		_ = Stderr.line!("ERROR: ${Str.inspect(other)}")
	# 		-1
	# 	}
	# }
}
