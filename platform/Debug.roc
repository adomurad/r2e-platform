module [printLine, wait, waitForEnterKey, showElement, showElements]

import Effect
import DebugMode
import Internal exposing [Element]

## Write `Str` to Stdout
## followed by a newline.
##
## ```
## Debug.printLine "Hello World"
## ```
printLine : Str -> Task {} []
printLine = \str ->
    Effect.stdoutLine str
    |> Task.mapErr \_ -> crash "stdout should not fail"

# readLine : Task Str []
# readLine =
#     Effect.stdinLine {} |> Task.mapErr \_ -> crash "stdin should not fail"

## Stops the test execution for specified amount of time.
##
## `timeout` - time in [ms]
##
## ```
## # wait for 3s
## Debug.wait 3000
## ```
wait : U64 -> Task {} []
wait = \timeout ->
    Effect.wait timeout |> Task.mapErr \_ -> crash "sleep should not fail"

## Stops the test execution till the "enter" key is pressed in the terminal.
##
## ```
## Debug.waitForEnterKey!
## ```
waitForEnterKey : Task {} []
waitForEnterKey =
    # TODO how to test this?
    printLine! "\nPress <enter> to continue the test run..."
    _ = Effect.stdinLine {} |> Task.mapErr! \_ -> crash "stdin should not fail"
    Task.ok {}

## Blink an `Element` in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## button |> Debug.showElement!
## ```
showElement : Element -> Task {} [WebDriverError Str, JsReturnTypeError Str]
showElement = \element ->
    { sessionId, locator } = Internal.unpackElementData element
    DebugMode.flashElements! sessionId locator Single

    wait 1000

## Blink a `List` of `Element`s in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## checkboxes |> Debug.showElements!
## ```
showElements : List Element -> Task {} [WebDriverError Str, JsReturnTypeError Str]
showElements = \elements ->
    when elements is
        [] -> Task.ok {}
        [element, ..] ->
            { sessionId, locator } = Internal.unpackElementData element
            DebugMode.flashElements! sessionId locator All

            wait 1000
