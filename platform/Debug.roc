module [print_line!, wait!, wait_for_enter_key!, show_element!, show_elements!, show_current_frame!]

import Effect
import DebugMode
import Internal exposing [Element, Browser]

## Write `Str` to Stdout
## followed by a newline.
##
## ```
## Debug.print_line!("Hello World")
## ```
print_line! : Str => {}
print_line! = |str|
    Effect.stdout_line!(str)

## Stops the test execution for specified amount of time.
##
## `timeout` - time in [ms]
##
## ```
## # wait for 3s
## Debug.wait!(3000)
## ```
wait! : U64 => {}
wait! = |timeout|
    Effect.wait!(timeout)

## Stops the test execution till the "enter" key is pressed in the terminal.
##
## ```
## Debug.wait_for_enter_key!({})
## ```
wait_for_enter_key! : {} => {}
wait_for_enter_key! = |{}|
    # TODO how to test this?
    print_line!("\nPress <enter> to continue the test run...")
    _ = Effect.stdin_line!({})
    {}

## Blink an `Element` in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## button |> Debug.show_element!()?
## ```
show_element! : Element => Result {} [WebDriverError Str, JsReturnTypeError Str]
show_element! = |element|
    { session_id, locator } = Internal.unpack_element_data(element)
    DebugMode.flash_elements!(session_id, locator, Single)?

    wait!(1500)

    Ok({})

## Blink a `List` of `Element`s in the `Browser`.
##
## Can be useful for debugging and trouble shooting.
##
## ```
## checkboxes |> Debug.show_elements!()?
## ```
show_elements! : List Element => Result {} [WebDriverError Str, JsReturnTypeError Str]
show_elements! = |elements|
    when elements is
        [] -> Ok({})
        [element, ..] ->
            { session_id, locator } = Internal.unpack_element_data(element)
            DebugMode.flash_elements!(session_id, locator, All)?

            wait!(1500)

            Ok({})

## Blink the current active frame (iFrame or top level frame).
##
## Can be useful for debugging and trouble shooting.
##
## ```
## browser |> Debug.show_current_frame!()?
## ```
show_current_frame! : Browser => Result {} [WebDriverError Str, JsReturnTypeError Str]
show_current_frame! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)
    DebugMode.flash_current_frame!(session_id)?

    wait!(1500)

    Ok({})
