module [printLine!, wait!, waitForEnterKey!, showElement!, showElements!, showCurrentFrame!]

import Effect
import DebugMode
import Internal exposing [Element, Browser]

## Write `Str` to Stdout
## followed by a newline.
##
## ```
## Debug.printLine! "Hello World"
## ```
printLine! : Str => {}
printLine! = \str ->
    Effect.stdoutLine! str

# readLine : Task Str []
# readLine =
#     Effect.stdinLine {} |> Task.mapErr \_ -> crash "stdin should not fail"

## Stops the test execution for specified amount of time.
##
## `timeout` - time in [ms]
##
## ```
## # wait for 3s
## Debug.wait! 3000
## ```
wait! : U64 => {}
wait! = \timeout ->
    Effect.wait! timeout

## Stops the test execution till the "enter" key is pressed in the terminal.
##
## ```
## Debug.waitForEnterKey! {}
## ```
waitForEnterKey! : {} => {}
waitForEnterKey! = \{} ->
    # TODO how to test this?
    printLine! "\nPress <enter> to continue the test run..."
    _ = Effect.stdinLine! {}
    {}
# Task.ok {}

## Blink an `Element` in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## button |> Debug.showElement! |> try
## ```
showElement! : Element => Result {} [WebDriverError Str, JsReturnTypeError Str]
showElement! = \element ->
    { sessionId, locator } = Internal.unpackElementData element
    DebugMode.flashElements! sessionId locator Single |> try

    wait! 1500

    Ok {}

## Blink a `List` of `Element`s in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## checkboxes |> Debug.showElements! |> try
## ```
showElements! : List Element => Result {} [WebDriverError Str, JsReturnTypeError Str]
showElements! = \elements ->
    when elements is
        [] -> Ok {}
        [element, ..] ->
            { sessionId, locator } = Internal.unpackElementData element
            DebugMode.flashElements! sessionId locator All |> try

            wait! 1500

            Ok {}

## Blink the current active frame (iFrame or top level frame).
##
## Can be useful for debugging and trouble shooting.
##
## ```
## browser |> Debug.showCurrentFrame! |> try
## ```
showCurrentFrame! : Browser => Result {} [WebDriverError Str, JsReturnTypeError Str]
showCurrentFrame! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser
    DebugMode.flashCurrentFrame! sessionId |> try

    wait! 1500

    Ok {}
