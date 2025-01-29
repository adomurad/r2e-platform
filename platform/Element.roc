## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    click!,
    get_text!,
    get_value!,
    input_text!,
    clear!,
    is_selected!,
    is_visible!,
    get_property!,
    get_attribute!,
    get_attribute_or_empty!,
    get_property_or_empty!,
    get_tag_name!,
    get_css_property!,
    get_rect!,
    Locator,
    find_element!,
    find_elements!,
    find_single_element!,
    try_find_element!,
    use_iframe!,
]

import Internal exposing [Element]
import InternalElement
import InternalError
import PropertyDecoder
import Common.Locator as Locator
import Effect
import Debug
import DebugMode

## Click on a `Element`.
##
## ```
## # find button element
## button = browser |> Browser.find_element!(Css("#submit-button"))?
## # click the button
## button |> Element.click!()?
## ```
click! : Element => Result {} [WebDriverError Str, ElementNotFound Str]
click! = |element|
    { session_id, element_id, locator, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Trying to click element: ${selector_text}"),
    )

    Effect.element_click!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)?

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Element clicked: ${selector_text}"),
    )
    #
    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Click Element ${selector_text}")?
            DebugMode.flash_elements!(session_id, locator, Single)?
            DebugMode.wait!({})
            Ok({}),
    )

    Ok({})

## Get text of the `Element`.
##
## This function will return the displayed text in the `Browser` for this `Element` and it's children.
##
## When the `Element` is not visible, then the text will be an empty `Str`.
##
## ```
## # find button element
## button = browser |> Browser.find_element!(Css("#submit-button"))?
## # get button text
## button_text = button |> Element.get_text!()?
## ```
get_text! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
get_text! = |element|
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting element text: ${selector_text}"),
    )

    InternalElement.get_text!(element)

## Get **value** of the `Element`.
##
## When there is no **value** in this element then returns the default value for used type:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # get input value
## input_value = input |> Element.get_value!()?
## input_value |> Assert.sh uld_be("my-email@fake-email.com")
## ```
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#age-input"))?
## # get input value
## input_value = input |> Element.get_value!()?
## input_value |> Assert.should_be(18)
## ```
get_value! : Element => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
get_value! = |element|
    get_property!(element, "value")

## Check if `Element` is selected.
##
## Can be used on checkbox inputs, radio inputs, and option elements.
##
## ```
## # find checkbox element
## checkbox = browser |> Browser.find_element!(Css("#is-tasty-checkbox"))?
## # get button text
## is_tasty_state = checkbox |> Element.is_selected!()?
## # asert expected value
## is_tasty_state |> Assert.should_be(Selected)
## ```
is_selected! : Element => Result [Selected, NotSelected] [WebDriverError Str, ElementNotFound Str]
is_selected! = |element|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Checking if element is slected: ${selector_text}"),
    )

    result = Effect.element_is_selected!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)?

    if result == "true" then
        Ok(Selected)
    else
        Ok(NotSelected)

## Check if `Element` is visible in the `Browser`.
##
## ```
## # find error message element
## error_msg = browser |> Browser.find_element!(Css("#error-msg"))?
## # get button text
## is_visible = checkbox |> Element.is_visible!()?
## # assert expected value
## is_visible |> Assert.should_be(Visible)
## ```
is_visible! : Element => Result [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
is_visible! = |element|
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Checking if element is visible: ${selector_text}"),
    )

    InternalElement.is_visible!(element)

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## When the **attribute** is not present on the `Element`, this function will return empty `Str`.
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # get input type
## input_type = input |> Element.get_attribute!("type")?
## ```
get_attribute! : Element, Str => Result Str [WebDriverError Str, ElementNotFound Str]
get_attribute! = |element, attribute_name|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting attribute \"${attribute_name}\" for element: ${selector_text}"),
    )

    Effect.element_get_attribute!(session_id, element_id, attribute_name) |> Result.map_err(InternalError.handle_element_error)

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## ```
## checkbox_type = checkbox |> Element.get_attribute_or_empty!("type")?
## when checkbox_type is
##     Ok(type) -> type |> Assert.should_be("checkbox")
##     Err(Empty) -> Assert.fail_with("should not be empty")
## ```
get_attribute_or_empty! : Element, Str => Result (Result Str [Empty]) [WebDriverError Str, ElementNotFound Str]
get_attribute_or_empty! = |element, attribute_name|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting attribute \"${attribute_name}\" for element: ${selector_text}"),
    )

    result = Effect.element_get_attribute!(session_id, element_id, attribute_name) |> Result.map_err(InternalError.handle_element_error)?

    if result == "" then
        Ok(Err(Empty))
    else
        Ok(Ok(result))

## Get **property** of an `Element`.
##
## **Properties** are the keys that you get when using `GetOwnProperty` on a element in the browser.
##
## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
## R2E will try to cast the browser response to the choosen type.
##
## When the response is empty e.g. property does not exist, then the default value of the choosen type will be used:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## ```
## # get input value
## input_value = input |> Element.get_property!("value")?
## # expect to have value "email@emails.com"
## input_value |> Assert.should_be("email@emails.com")
## ```
##
## Bool:
## ```
## is_checked = name_input |> Element.get_property!("checked")?
## is_checked |> Assert.should_be(Bool.false)
## ```
##
## Bool as Str:
## ```
## is_checked = name_input |> Element.get_property!("checked")?
## is_checked |> Assert.should_be("false")
## ```
##
## Num:
## ```
## client_height = name_input |> Element.get_property!("clientHeight")?
## client_height |> Assert.should_be(17)
## ```
get_property! : Internal.Element, Str => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
get_property! = |element, property_name|
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting property \"${property_name}\" for element: ${selector_text}"),
    )

    InternalElement.get_property!(element, property_name)

## Get **property** of an `Element`.
##
## **Properties** are the keys that you get when using `GetOwnProperty` on a element in the browser.
##
## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
## R2E will try to cast the browser response to the choosen type.
##
## When the response is empty e.g. property does not exist, then `Err(Empty)` will be returned.
##
## ```
## # get input value
## input_value = input |> Element.get_property_or_empty!("value")?
## # expect to have value "email@emails.com"
## input_value |> Assert.should_be(Ok("email@emails.com"))
## ```
##
## ```
## is_checked = name_input |> Element.get_property!("checked")?
## when is_checked is
##     Ok(value) -> value |> Assert.should_be(Bool.false)
##     Err(Empty) -> Assert.fail_with("input should have a checked prop")
## ```
##
## ```
## client_height = name_input |> Element.get_property!("clientHeight")?
## client_height |> Assert.should_be(Ok(17))
## ```
get_property_or_empty! : Element, Str => Result (Result a [Empty]) [WebDriverError Str, ElementNotFound Str, PropertyTypeError Str] where a implements Decoding
get_property_or_empty! = |element, property_name|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting property \"${property_name}\" for element: ${selector_text}"),
    )

    result_str = Effect.element_get_property!(session_id, element_id, property_name) |> Result.map_err(InternalError.handle_element_error)?

    if result_str == "" then
        Ok(Err(Empty))
    else
        result_utf8 = result_str |> Str.to_utf8

        decoded : Result a _
        decoded = Decode.from_bytes(result_utf8, PropertyDecoder.utf8)

        when decoded is
            Ok(val) -> Ok(Ok(val))
            Err(_) -> Err(PropertyTypeError("could not cast property \"${property_name}\" with value \"${result_str}\" to expected type"))

## Send a `Str` to a `Element` (e.g. put text into an input).
##
## ```
## # find email input element
## email_input = browser |> Browser.find_element!(Css("#email"))?
## # input an email into the email input
## email_input |> Element.send_keys!("my.fake.email@fake-email.com")?
## ```
##
## Special key sequences:
##
## `{enter}` - simulates an "enter" key press
##
## ```
## # find search input element
## search_input = browser |> Browser.find_element!(Css("#search"))?
## # input text and submit
## search_input |> Element.send_keys!("roc lang{enter}")?
## ```
input_text! : Element, Str => Result {} [WebDriverError Str, ElementNotFound Str]
input_text! = |element, str|
    { session_id, element_id, selector_text, locator } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Sending text \"${str}\" to element: ${selector_text}"),
    )

    Effect.element_send_keys!(session_id, element_id, str) |> Result.map_err(InternalError.handle_element_error)?

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Element received text: ${selector_text}"),
    )

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Send Text ${selector_text}")?
            DebugMode.flash_elements!(session_id, locator, Single)?
            DebugMode.wait!({})
            Ok({}),
    )

    Ok({})

## Clear an editable or resetable `Element`.
##
## ```
## # find button element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # click the button
## input |> Element.clear!()?
## ```
clear! : Internal.Element => Result {} [WebDriverError Str, ElementNotFound Str]
clear! = |element|
    { session_id, element_id, selector_text, locator } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Clearing element: ${selector_text}"),
    )

    Effect.element_clear!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)?

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Element cleared: ${selector_text}"),
    )

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Clear Element ${selector_text}")?
            DebugMode.flash_elements!(session_id, locator, Single)?
            DebugMode.wait!({})
            Ok({}),
    )

    Ok({})

## Supported locator strategies
##
## `Css Str` - e.g. Css(".my-button-class")
##
## `TestId Str` - e.g. TestId("button") => Css("[data-testid=\"button\"]")
##
## `XPath Str` - e.g. XPath("/bookstore/book[price>35]/price")
##
## `LinkText Str` - e.g. LinkText("Examples") in <a href="/examples-page">Examples</a>
##
## `PartialLinkText Str` - e.g. PartialLinkText("Exam") in <a href="/examples-page">Examples</a>
##
Locator : Locator.Locator

## Find an `Element` inside the tree of another `Element` in the `Browser`.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## # find the html element with a css selector "#my-id"
## button = element |> Element.find_element!(Css("#my-id"))?
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = element |> Element.find_element!(Css(".my-class"))?
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = element |> Element.find_element!(TestId("my-element"))?
## ```
find_element! : Element, Locator => Result Element [WebDriverError Str, ElementNotFound Str]
find_element! = |element, locator|
    { session_id, element_id } = Internal.unpack_element_data(element)
    (using, value) = Locator.get_locator(locator)

    selector_text = "${locator |> Inspect.to_str}"

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Searching for element: ${selector_text}"),
    )

    new_element_id = Effect.element_find_element!(session_id, element_id, using, value) |> Result.map_err(InternalError.handle_element_error)?

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Found element: ${selector_text}"),
    )

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Find Element ${selector_text}")?
            DebugMode.flash_elements!(session_id, locator, Single)?
            DebugMode.wait!({})
            Ok({}),
    )

    Internal.pack_element_data({ session_id, element_id: new_element_id, selector_text, locator }) |> Ok

## Find an `Element` inside the tree of another `Element` in the `Browser`.
##
## This function returns a `[Found Element, NotFound]` instead of an error
## when element is not found.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## maybe_button = element |> Element.try_find_element!(Css("#submit-button"))?
##
## when maybe_button is
##     NotFound -> Stdout.line!("Button not found")
##     Found(el) ->
##         button_text = el |> Element.get_text!()?
##         Stdout.line!("Button found with text: $(button_text)")
## ```
try_find_element! : Element, Locator => Result [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
try_find_element! = |element, locator|
    find_element!(element, locator)
    |> Result.map_ok(Found)
    |> Result.on_err(
        |err|
            when err is
                ElementNotFound(_) -> Ok(NotFound)
                other -> Err(other),
    )

## Find an `Element` inside the tree of another `Element` in the `Browser`.
##
## This function will fail if the element is not found - `ElementNotFound Str`
##
## This function will fail if there are more than 1 element - `AssertionError Str`
##
##
## See supported locators at `Locator`.
##
## ```
## button = element |> Element.find_single_element!(Css("#submit-button"))?
## ```
find_single_element! : Element, Locator => Result Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
find_single_element! = |element, locator|
    { selector_text: parent_element_selector_text } = Internal.unpack_element_data(element)
    elements = find_elements!(element, locator)?
    when elements |> List.len is
        0 ->
            (_, value) = Locator.get_locator(locator)
            Err(ElementNotFound("element with selector ${value} was not found in element ${parent_element_selector_text}"))

        1 ->
            elements
            |> List.first
            |> Result.on_err(|_| crash("just checked - there is 1 element in the list"))

        n ->
            (_, value) = Locator.get_locator(locator)
            Err(AssertionError("expected to find only 1 element with selector \"${value}\", but found ${n |> Num.to_str}"))

## Find all `Elements` inside the tree of another `Element` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list in the DOM tree of **element**
## list_items = element |> Element.find_elements!(Css("#my-list li"))?
## ```
##
find_elements! : Element, Locator => Result (List Element) [WebDriverError Str, ElementNotFound Str]
find_elements! = |element, locator|
    { session_id, element_id: parent_element_id } = Internal.unpack_element_data(element)
    (using, value) = Locator.get_locator(locator)

    selector_text = "${locator |> Inspect.to_str}"

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Searching for elements: ${selector_text}"),
    )

    result = Effect.element_find_elements!(session_id, parent_element_id, using, value) |> Result.map_err(InternalError.handle_element_error)

    when result is
        Ok(element_ids) ->
            DebugMode.run_if_verbose!(
                |{}|
                    Debug.print_line!("Found ${element_ids |> List.len |> Num.to_str} elements: ${selector_text}"),
            )

            DebugMode.run_if_debug_mode!(
                |{}|
                    if element_ids |> List.is_empty then
                        Ok({})
                    else
                        DebugMode.show_debug_message_in_browser!(session_id, "Find Elements ${selector_text}")?
                        DebugMode.flash_elements!(session_id, locator, All)?
                        DebugMode.wait!({})
                        Ok({}),
            )

            element_ids
            |> List.map(
                |element_id|
                    Internal.pack_element_data({ session_id, element_id, selector_text, locator }),
            )
            |> Ok

        Err(ElementNotFound(_)) -> Ok([])
        Err(err) -> Err(err)

## Get the HTML tag name of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # get input tag name
## tag_name = input |> Element.get_tag_name!()?
## # tag name should be "input"
## tag_name |> Assert.should_be("input")
## ```
get_tag_name! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
get_tag_name! = |element|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting tag name for element: ${selector_text}"),
    )

    Effect.element_get_tag!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)

## Get a **css property** of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # get input type
## input_border = input |> Element.get_css_property!("border")?
## # assert
## input_border |> Assert.should_be("2px solid rgb(0, 0, 0)")
## ```
get_css_property! : Element, Str => Result Str [WebDriverError Str, ElementNotFound Str]
get_css_property! = |element, css_property|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting CSS property \"${css_property}\" for element: ${selector_text}"),
    )

    Effect.element_get_css!(session_id, element_id, css_property) |> Result.map_err(InternalError.handle_element_error)

ElementRect : {
    x : F64,
    y : F64,
    width : U32,
    height : U32,
}

## Get the position and size of the `Element`.
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#email-input"))?
## # get input tag name
## rect = input |> Element.get_rect!()?
## # assert the rect
## rect.height |> Assert.should_be(51)?
## rect.width |> Assert.should_be(139)?
## rect.x |> Assert.should_be_equal_to(226.1243566)?
## rect.y |> Assert.should_be_equal_to(218.3593754)
## ```
get_rect! : Element => Result ElementRect [WebDriverError Str, ElementNotFound Str]
get_rect! = |element|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting the rect for element: ${selector_text}"),
    )

    Effect.element_get_rect!(session_id, element_id)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.round, height: height_val |> Num.round }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(InternalError.handle_element_error)

## Switch the context to an iFrame.
##
## This function runs a callback in which you can interact
## with the page inside an iFrame.
##
## ```
## frame_el = browser |> Browser.find_element!(Css("iframe"))?
##
## Element.use_iframe!(frame_el, |frame|
##     span = frame |> Browser.find_element!(Css("#span-inside-frame"))?
##     span |> Assert.element_should_have_text!("This is inside an iFrame")?
## )
## ```
use_iframe! : Element, (Internal.Browser => Result {} _) => Result {} _
use_iframe! = |element, callback!|
    { session_id, element_id, selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Switching context to iFrame: ${selector_text}"),
    )

    Effect.switch_to_frame_by_element_id!(session_id, element_id) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Switched to iFrame ${selector_text}")?
            DebugMode.flash_current_frame!(session_id)?
            DebugMode.wait!({})
            Ok({}),
    )

    browser = Internal.pack_browser_data({ session_id })
    result = callback!(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Switching back to iFrame parent"),
    )

    Effect.switch_to_parent_frame!(session_id) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.show_debug_message_in_browser!(session_id, "Switched back to iFrame parent")?
            DebugMode.flash_current_frame!(session_id)?
            DebugMode.wait!({})
            Ok({}),
    )

    result
