module [test, testWith]

import InternalTest

## Create a r2e test
##
## ```
## myTest = test "open roc-lang.org website" \browser ->
##     # open roc-lang.org
##     browser |> Browser.navigateTo! "http://roc-lang.org"
## ```
test = InternalTest.test

## Create a new configured function to create test cases.
##
## ```
## longTest = Test.testWith {
##     pageLoadTimeout: Override 30_000,
##     scriptExecutionTimeout: Override 30_000,
##     assertTimeout: Override 8000,
##     screenshotOnFail: Override No,
##     windowSize: Override (Size 1800 400),
## }
##
## test1 = longTest "this is flaky test" \browser ->
##     # open the test page
##     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/"
## ```
##
## All possible overrides:
## ```
## ConfigOverride : {
##     assertTimeout : [Inherit, Override U64],
##     pageLoadTimeout : [Inherit, Override U64],
##     scriptExecutionTimeout : [Inherit, Override U64],
##     elementImplicitTimeout : [Inherit, Override U64],
##     windowSize : [Inherit, Override [Size U64 U64]],
##     screenshotOnFail : [Inherit, Override [Yes, No]],
## }
## ```
testWith = InternalTest.testWith
