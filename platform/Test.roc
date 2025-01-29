module [test, test_with]

import InternalTest

## Create a r2e test
##
## ```
## my_test = test("open roc-lang.org website", |browser|
##     # open roc-lang.org
##     browser |> Browser.navigate_to!("http://roc-lang.org")?
## )
## ```
test = InternalTest.test

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
##
## test1 = long_test("this is flaky test", |browser|
##     # open the test page
##     browser |> Browser.navigate_to!("https://adomurad.github.io/e2e-test-page/")?
## )
## ```
##
## All possible overrides:
## ```
## ConfigOverride : {
##     assert_timeout : [Inherit, Override U64],
##     page_load_timeout : [Inherit, Override U64],
##     script_execution_timeout : [Inherit, Override U64],
##     element_implicit_timeout : [Inherit, Override U64],
##     window_size : [Inherit, Override [Size U64 U64]],
##     screenshot_on_fail : [Inherit, Override [Yes, No]],
##     attempts : [Inherit, Override U64],
## }
## ```
test_with = InternalTest.test_with
