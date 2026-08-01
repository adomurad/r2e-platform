# TestResult(err) :: {
#   name : Str,
#   result : Result({}, []err),
#   duration: U64,
#   screenshot: [NoScreenshot, Screenshot(Str)],
#   logs : List(Str),
#   type : [FinalResult, Attempt],
# }.{

import Browser

# TestBody(err) : Browser => Result({}, [WebDriverError(Str), err])
TestBody(err) : Browser => Try({}, [WebDriverError(Str), ..err])

TestCase(err) :: {
	name : Str,
	test_body : TestBody(err),
	# config: ConfigOverride
}.{

	test : Str, TestBody(err) -> TestCase
	test = |name, test_body|
		{ name, test_body }

}
