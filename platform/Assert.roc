## `Assert` module contains assertion functions to check properties of` Elements`
## and data extracted from the browser.
##
## All assert functions return a `Task` with the `[AssertionError Str]` error.
module [
    shouldBe,
    # urlShouldBe,
    # titleShouldBe,
    shouldBeGreaterOrEqualTo,
    shouldBeGreaterThan,
    shouldBeLesserOrEqualTo,
    shouldBeLesserThan,
    failWith,
]

# import Internal exposing [Browser]
# import Browser

## Checks if the value of __actual__ is equal to the __expected__.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonText = button |> Element.getText!
## # assert text
## buttonText |> Assert.shouldBe! "Roc"
## ```
shouldBe : a, a -> Task.Task {} [AssertionError Str] where a implements Eq & Inspect
shouldBe = \actual, expected ->
    if expected == actual then
        Task.ok {}
    else
        actualStr = Inspect.toStr actual
        expectedStr = Inspect.toStr expected
        Task.err (AssertionError "Expected $(actualStr) to be $(expectedStr)")

## Checks if the __actual__ `Num` is grater than the __expected__.
##
## ```
## 3 |> Assert.shouldBeGreaterThan! 2
## ```
shouldBeGreaterThan : Num a, Num a -> Task.Task {} [AssertionError Str] where a implements Bool.Eq
shouldBeGreaterThan = \actual, expected ->
    if actual > expected then
        Task.ok {}
    else
        actualStr = actual |> Num.toStr
        expectedStr = expected |> Num.toStr
        Task.err (AssertionError "Expected $(actualStr) to be greater than $(expectedStr)")

## Checks if the __actual__ `Num` is grater or equal than the __expected__.
##
## ```
## 3 |> Assert.shouldBeGreaterOrEqualTo! 2
## ```
shouldBeGreaterOrEqualTo : Num a, Num a -> Task.Task {} [AssertionError Str] where a implements Bool.Eq
shouldBeGreaterOrEqualTo = \actual, expected ->
    if actual >= expected then
        Task.ok {}
    else
        actualStr = actual |> Num.toStr
        expectedStr = expected |> Num.toStr
        Task.err (AssertionError "Expected $(actualStr) to be equal to or greater than $(expectedStr)")

## Checks if the __actual__ `Num` is grater than the __expected__.
##
## ```
## 3 |> Assert.shouldBeGreaterThan! 2
## ```
shouldBeLesserThan : Num a, Num a -> Task.Task {} [AssertionError Str] where a implements Bool.Eq
shouldBeLesserThan = \actual, expected ->
    if actual < expected then
        Task.ok {}
    else
        actualStr = actual |> Num.toStr
        expectedStr = expected |> Num.toStr
        Task.err (AssertionError "Expected $(actualStr) to be lesser than $(expectedStr)")

## Checks if the __actual__ `Num` is grater or equal than the __expected__.
##
## ```
## 3 |> Assert.shouldBeLesserOrEqualTo! 2
## ```
shouldBeLesserOrEqualTo : Num a, Num a -> Task.Task {} [AssertionError Str] where a implements Bool.Eq
shouldBeLesserOrEqualTo = \actual, expected ->
    if actual <= expected then
        Task.ok {}
    else
        actualStr = actual |> Num.toStr
        expectedStr = expected |> Num.toStr
        Task.err (AssertionError "Expected $(actualStr) to be equal to or lesser than $(expectedStr)")

## Checks if the __URL__ is equal to the __expected__.
##
## ```
## # assert text
## browser |> Assert.urlShouldBe! "https://roc-lang.org/"
## ```
# urlShouldBe : Browser, Str -> Task.Task {} [AssertionError Str, WebDriverError Str]
# urlShouldBe = \browser, expected ->
#     actual = browser |> Browser.getUrl!
#
#     if expected == actual then
#         Task.ok {}
#     else
#         Task.err (AssertionError "Expected URL $(actual) to be $(expected)")

## Checks if the __title__ of the page is equal to the __expected__.
##
## ```
## # assert text
## browser |> Assert.urlShouldBe! "https://roc-lang.org/"
## ```
# titleShouldBe : Browser, Str -> Task.Task {} [AssertionError Str, WebDriverError Str]
# titleShouldBe = \browser, expected ->
#     actual = browser |> Browser.getTitle!
#
#     if expected == actual then
#         Task.ok {}
#     else
#         Task.err (AssertionError "Expected page title $(actual) to be $(expected)")

## Fails with given error message.
##
## ```
## # fail the test
## Assert.failWith! "this should not happen"
## ```
failWith : Str -> Task.Task _ [AssertionError Str]
failWith = \msg ->
    Task.err (AssertionError msg)
