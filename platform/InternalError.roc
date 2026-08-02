InternalError :: [].{

	handle_element_error = |err|
		match err {
			HostError(e) if e |> Str.starts_with("WebDriverNotFoundError") => ElementNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
			HostError(e) => WebDriverError(e)
		}

	handle_alert_error = |err|
		match err {
			HostError(e) if e |> Str.starts_with("WebDriverNotFoundError") => AlertNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
			HostError(e) => WebDriverError(e)
		}

	handle_cookie_error = |err|
		match err {
			HostError(e) if e |> Str.starts_with("WebDriverNotFoundError") => CookieNotFound((e |> Str.drop_prefix("WebDriverNotFoundError::")))
			HostError(e) => WebDriverError(e)
		}

	host_error_to_web_driver_error = |HostError(err)| WebDriverError(err)
}
