Error :: [].{

	web_driver_error_to_str = |error_tag|
		match error_tag {
			WebDriverError(msg) => StringError("WebDriverError: ${msg}")
			ElementNotFound(msg) => StringError("ElementNotFound: ${msg}")
			AssertionError(msg) => StringError("AssertionError: ${msg}")
			PropertyTypeError(msg) => StringError("PropertyTypeError: ${msg}")
			err => err
		}
}
