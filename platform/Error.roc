Error :: [].{

	# Every error a test body can fail with. Reports, retries and the test
	# runner all use this concrete union so platform values stay monomorphic.
	PlatformError : [
		WebDriverError(Str),
		ElementNotFound(Str),
		AssertionError(Str),
		PropertyTypeError(Str),
		StringError(Str),
		AlertNotFound(Str),
		CookieNotFound(Str),
		JsReturnTypeError(Str),
		OutOfBounds,
		FileSystemError(Str),
		TestRunFailed,
	]

	## Takes in any error Tag and return the same Tag or `[StringError(Str)]`
	## if the input was any of R2E errors.
	web_driver_error_to_str = |error_tag|
		match error_tag {
			WebDriverError(msg) => StringError("WebDriverError: ${msg}")
			ElementNotFound(msg) => StringError("ElementNotFound: ${msg}")
			AssertionError(msg) => StringError("AssertionError: ${msg}")
			PropertyTypeError(msg) => StringError("PropertyTypeError: ${msg}")
			err => err
		}
}
