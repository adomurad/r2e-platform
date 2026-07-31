module [handle_element_error, handle_cookie_error, handle_alert_error]

handle_element_error = |err|
    when err is
        e if e |> Str.starts_with("WebDriverNotFoundError") -> ElementNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
        e -> WebDriverError(e)

handle_alert_error = |err|
    when err is
        e if e |> Str.starts_with("WebDriverNotFoundError") -> AlertNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
        e -> WebDriverError(e)

handle_cookie_error = |err|
    when err is
        e if e |> Str.starts_with("WebDriverNotFoundError") -> CookieNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
        e -> WebDriverError(e)
