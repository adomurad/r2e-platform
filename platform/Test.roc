import Browser
import Error

## `Test` module exposes the `test` and `test_with` constructors used in
## application test suites.
Test :: [].{

	ConfigOverride : {
		assert_timeout : [Inherit, Override(U64)],
		page_load_timeout : [Inherit, Override(U64)],
		script_execution_timeout : [Inherit, Override(U64)],
		element_implicit_timeout : [Inherit, Override(U64)],
		window_size : [Inherit, Override([Size(U64, U64)])],
		screenshot_on_fail : [Inherit, Override([Yes, No])],
		attempts : [Inherit, Override(U64)],
	}

	TestBody : Browser => Try({}, Error.PlatformError)

	TestCase := {
		name : Str,
		test_body : TestBody,
		config : ConfigOverride,
	}

	default_overrides : ConfigOverride
	default_overrides = {
		assert_timeout: Inherit,
		page_load_timeout: Inherit,
		script_execution_timeout: Inherit,
		element_implicit_timeout: Inherit,
		window_size: Inherit,
		screenshot_on_fail: Inherit,
		attempts: Inherit,
	}

	## Create a r2e test.
	##
	## ```
	## my_test = test("open roc-lang.org website", |browser|
	##     browser.navigate_to!("http://roc-lang.org")?
	## )
	## ```
	test : Str, TestBody -> TestCase
	test = |name, test_body|
		TestCase.{
			name,
			test_body,
			config: default_overrides,
		}

	## Create a new configured function to create test cases.
	##
	## ```
	## long_test = Test.test_with({
	##     page_load_timeout: Override(30_000),
	##     script_execution_timeout: Override(30_000),
	##     assert_timeout: Override(8000),
	##     screenshot_on_fail: Override(No),
	##     window_size: Override(Size(1800, 400)),
	## })
	## ```
	test_with :
		{
			assert_timeout ?: [Inherit, Override(U64)],
			page_load_timeout ?: [Inherit, Override(U64)],
			script_execution_timeout ?: [Inherit, Override(U64)],
			element_implicit_timeout ?: [Inherit, Override(U64)],
			window_size ?: [Inherit, Override([Size(U64, U64)])],
			screenshot_on_fail ?: [Inherit, Override([Yes, No])],
			attempts ?: [Inherit, Override(U64)],
		}
		-> (Str, TestBody -> TestCase)
	test_with = |overrides| {
		config = {
			assert_timeout: overrides.?assert_timeout ?? Inherit,
			page_load_timeout: overrides.?page_load_timeout ?? Inherit,
			script_execution_timeout: overrides.?script_execution_timeout ?? Inherit,
			element_implicit_timeout: overrides.?element_implicit_timeout ?? Inherit,
			window_size: overrides.?window_size ?? Inherit,
			screenshot_on_fail: overrides.?screenshot_on_fail ?? Inherit,
			attempts: overrides.?attempts ?? Inherit,
		}

		|name, test_body| TestCase.{ name, test_body, config }
	}
}
