## `Assert` module contains assertion functions to check properties of` Elements`
## and data extracted from the browser.
##
## All assert functions return a `Task` with the `[AssertionError Str]` error.
module [
    shouldBe,
    shouldBeEqualTo,
    # urlShouldBe,
    # titleShouldBe,
    shouldBeGreaterOrEqualTo,
    shouldBeGreaterThan,
    shouldBeLesserOrEqualTo,
    shouldBeLesserThan,
    shouldHaveLength,
    failWith,
    # element
    elementShouldHaveText,
    elementShouldHaveValue,
]

import Internal exposing [Element]
# import Browser
import Element

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

## Checks if the value of __actual__ is equal to the __expected__.
##
## Used to compare `Frac` numbers.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonSize = button |> Element.getProperty! "size"
## # assert value
## buttonSize |> Assert.shouldBeEqualTo! 20f64
## ```
shouldBeEqualTo : Frac a, Frac a -> Task.Task {} [AssertionError Str]
shouldBeEqualTo = \actual, expected ->
    if expected |> Num.isApproxEq actual {} then
        Task.ok {}
    else
        actualStr = Num.toStr actual
        expectedStr = Num.toStr expected
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

## Checks if the lenght of __list__ is equal to the __expected__ length.
##
## ```
## # find all buttons element
## buttons = browser |> Browser.findElements! (Css "button")
## # assert that there are 3 buttons
## buttons |> Assert.shouldHaveLength! 3
## ```
shouldHaveLength : List a, U64 -> Task.Task {} [AssertionError Str]
shouldHaveLength = \list, expected ->
    actualLen = list |> List.len

    if actualLen == expected then
        Task.ok {}
    else
        actualLenStr = actualLen |> Num.toStr
        expectedLenStr = expected |> Num.toStr
        actualElementsWord = pluralize actualLen "element" "elements"
        expectedElementsWord = pluralize actualLen "element" "elements"

        Task.err (AssertionError "Expected a list with $(actualLenStr) $(actualElementsWord), but got $(expectedLenStr) $(expectedElementsWord)")

pluralize : U64, a, a -> a
pluralize = \count, singular, plural ->
    if
        count == 1
    then
        singular
    else
        plural

## Checks if the `Element` has __expected__ text.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # check if button has text "Submit"
## button |> Assert.elementShouldHaveText! "Submit"
## ```
elementShouldHaveText : Element, Str -> Task {} [AssertionError Str, ElementNotFound Str, WebDriverError Str]
elementShouldHaveText = \element, expectedText ->
    elementText = element |> Element.getText!
    elementText |> shouldBe expectedText

## Checks if the `Element` has __expected__ value.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#username-input")
## # check if input has value "fake-username"
## input |> Assert.elementShouldHaveValue! "fake-username"
## ```
elementShouldHaveValue : Element, Str -> Task {} [AssertionError Str, ElementNotFound Str, WebDriverError Str, PropertyTypeError Str]
elementShouldHaveValue = \element, expectedValue ->
    elementValue = element |> Element.getValue!
    elementValue |> shouldBe expectedValue
