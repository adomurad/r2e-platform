hosted [
    set_timeouts!,
    set_script_timeout_override!,
    set_assert_timeout_override!,
    set_page_load_timeout_override!,
    set_implicit_timeout_override!,
    reset_test_overrides!,
    set_window_size!,
    set_window_size_override!,
    get_assert_timeout!,
    stdout_line!,
    stdin_line!,
    wait!,
    start_session!,
    delete_session!,
    browser_navigate_to!,
    browser_find_element!,
    browser_find_elements!,
    element_click!,
    get_time_milis!,
    is_debug_mode!,
    is_verbose!,
    reset_test_log_bucket!,
    get_logs_from_bucket!,
    get_test_name_filter!,
    create_dir_if_not_exist!,
    file_write_utf8!,
    browser_get_screenshot!,
    add_cookie!,
    get_cookie!,
    get_all_cookies!,
    delete_cookie!,
    delete_all_cookies!,
    alert_dismiss!,
    alert_send_text!,
    alert_get_text!,
    alert_accept!,
    # browserGetPdf,
    element_get_text!,
    element_is_selected!,
    element_is_displayed!,
    element_get_attribute!,
    element_get_property!,
    element_send_keys!,
    element_clear!,
    element_find_element!,
    element_find_elements!,
    element_get_css!,
    element_get_tag!,
    element_get_rect!,
    browser_set_window_rect!,
    browser_get_window_rect!,
    browser_get_title!,
    browser_get_url!,
    browser_reload!,
    browser_navigate_back!,
    browser_navigate_forward!,
    browser_maximize!,
    browser_minimize!,
    browser_full_screen!,
    execute_js!,
    get_env!,
    get_page_source!,
    switch_to_frame_by_element_id!,
    switch_to_parent_frame!,
]

# effects that are provided by the host
set_timeouts! : U64, U64, U64, U64 => {}

set_assert_timeout_override! : U64 => {}

set_page_load_timeout_override! : U64 => {}

set_script_timeout_override! : U64 => {}

set_implicit_timeout_override! : U64 => {}

reset_test_overrides! : {} => {}

set_window_size! : Str => {}

set_window_size_override! : Str => {}

get_assert_timeout! : {} => U64

stdout_line! : Str => {}

stdin_line! : {} => Str

wait! : U64 => {}

get_time_milis! : {} => I64

is_debug_mode! : {} => I64

is_verbose! : {} => I64

reset_test_log_bucket! : {} => {}

get_logs_from_bucket! : {} => List Str

get_test_name_filter! : {} => Str

# file system
create_dir_if_not_exist! : Str => Result {} Str

file_write_utf8! : Str, Str => Result {} Str

# driver effects
start_session! : {} => Result Str Str

delete_session! : Str => Result {} Str

# browser effects
browser_navigate_to! : Str, Str => Result {} Str

browser_get_title! : Str => Result Str Str

browser_get_url! : Str => Result Str Str

browser_find_element! : Str, Str, Str => Result Str Str

browser_find_elements! : Str, Str, Str => Result (List Str) Str

browser_set_window_rect! : Str, I64, I64, I64, I64, I64 => Result (List I64) Str

browser_get_window_rect! : Str => Result (List I64) Str

browser_get_screenshot! : Str => Result Str Str

# browserGetPdf : Str, F64, F64, F64, F64, F64, F64, F64, Str, I64, I64, List Str -> Task Str Str

browser_navigate_back! : Str => Result {} Str

browser_navigate_forward! : Str => Result {} Str

browser_reload! : Str => Result {} Str

browser_maximize! : Str => Result (List I64) Str

browser_minimize! : Str => Result (List I64) Str

browser_full_screen! : Str => Result (List I64) Str

execute_js! : Str, Str, Str => Result Str Str

add_cookie! : Str, Str, Str, Str, Str, Str, I64, I64, I64 => Result {} Str

delete_cookie! : Str, Str => Result {} Str

delete_all_cookies! : Str => Result {} Str

get_cookie! : Str, Str => Result (List Str) Str

get_all_cookies! : Str => Result (List (List Str)) Str

alert_accept! : Str => Result {} Str

alert_dismiss! : Str => Result {} Str

alert_send_text! : Str, Str => Result {} Str

alert_get_text! : Str => Result Str Str

# element effects
element_click! : Str, Str => Result {} Str

element_send_keys! : Str, Str, Str => Result {} Str

element_clear! : Str, Str => Result {} Str

element_get_text! : Str, Str => Result Str Str

element_is_selected! : Str, Str => Result Str Str

element_is_displayed! : Str, Str => Result Str Str

element_get_attribute! : Str, Str, Str => Result Str Str

element_get_property! : Str, Str, Str => Result Str Str

element_find_element! : Str, Str, Str, Str => Result Str Str

element_find_elements! : Str, Str, Str, Str => Result (List Str) Str

element_get_tag! : Str, Str => Result Str Str

element_get_css! : Str, Str, Str => Result Str Str

element_get_rect! : Str, Str => Result (List F64) Str

get_env! : Str => Str

get_page_source! : Str => Result Str Str

switch_to_frame_by_element_id! : Str, Str => Result {} Str

switch_to_parent_frame! : Str => Result {} Str
