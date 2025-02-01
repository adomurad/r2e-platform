# `Browser` module contains functions to interact with the `Browser`.
module [
    open_new_window!,
    open_new_window_with_cleanup!,
    close_window!,
    navigate_to!,
    navigate_back!,
    navigate_forward!,
    reload_page!,
    get_title!,
    get_url!,
    Locator,
    find_element!,
    try_find_element!,
    find_single_element!,
    find_elements!,
    take_screenshot_base64!,
    # printPdfBase64,
    maximize_window!,
    minimize_window!,
    full_screen_window!,
    set_window_rect!,
    get_window_rect!,
    execute_js!,
    execute_js_with_output!,
    execute_js_with_args!,
    Cookie,
    CookieExpiry,
    SameSiteOption,
    add_cookie!,
    get_cookie!,
    get_all_cookies!,
    delete_cookie!,
    delete_all_cookies!,
    accept_alert!,
    dismiss_alert!,
    send_text_to_alert!,
    get_alert_text!,
    get_page_html!,
]

import Effect
import Common.ExecuteJs as ExecuteJs
import Common.Locator as Locator
import DebugMode
import Debug
import Internal exposing [Browser, Element]
import InternalError

## Opens a new `Browser` window.
##
## Only the browser provided by the test will be closed automatically,
## please remember to close the browser windows you open manually.
##
## ```
## newBrowser = Browser.open_new_window!({})?
## ...
## newBrowser |> Browser.close_window!()?
## ```
open_new_window! : {} => Result Browser [WebDriverError Str]
open_new_window! = |{}|
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Opening new browser window"),
    )

    Effect.start_session!({})
    |> Result.map_err(WebDriverError)
    |> Result.map_ok(
        |session_id|
            Internal.pack_browser_data({ session_id }),
    )

## Opens a new `Browser` window and runs a callback.
## Will close the browser after the callback is finished.
##
## ```
## Browser.open_new_window_with_cleanup!(|browser2|
##     browser2 |> Browser.navigate_to!("https://www.roc-lang.org/")
## )
## ```
open_new_window_with_cleanup! : (Browser => Result val [WebDriverError Str]err) => Result val [WebDriverError Str]err
open_new_window_with_cleanup! = |callback!|
    browser = open_new_window!({})?
    result = callback!(browser)
    browser |> close_window!?
    result

## Close a `Browser` window.
##
## Do not close the browser provided by the test,
## the automatic cleanup will fail trying to close this browser.
##
## ```
## newBrowser = Browser.open_new_window!({})?
## ...
## newBrowser |> Browser.close_window!
## ```
close_window! : Browser => Result {} [WebDriverError Str]
close_window! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Closing browser window"),
    )

    Effect.delete_session!(session_id) |> Result.map_err(WebDriverError)

## Navigate the browser to the given URL.
##
## ```
## # open google.com
## browser |> Browser.navigate_to!("http://google.com")?
## ```
navigate_to! : Browser, Str => Result {} [WebDriverError Str]
navigate_to! = |browser, url|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Navigating to: ${url}"),
    )

    Effect.browser_navigate_to!(session_id, url) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Get browser title.
##
## ```
## browser |> Browser.navigate_to!("http://google.com")?
## # get title
## title = browser |> Browser.get_title!()?
## # title = "Google"
## ```
get_title! : Browser => Result Str [WebDriverError Str]
get_title! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting title of the current page"),
    )

    Effect.browser_get_title!(session_id) |> Result.map_err(WebDriverError)

## Get current URL.
##
## ```
## browser |> Browser.navigate_to!("http://google.com")?
## # get url
## url = browser |> Browser.get_url!()?
## # url = "https://google.com/"
## ```
get_url! : Browser => Result Str [WebDriverError Str]
get_url! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting url of the current page"),
    )

    Effect.browser_get_url!(session_id)
    |> Result.map_err(WebDriverError)

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

## Find an `Element` in the `Browser`.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## # find the html element with a css selector "#my-id"
## button = browser |> Browser.find_element!(Css("#my-id"))?
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = browser |> Browser.find_element!(Css(".my-class"))?
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = browser |> Browser.find_element!(TestId("my-element"))?
## ```
find_element! : Browser, Locator => Result Element [WebDriverError Str, ElementNotFound Str]
find_element! = |browser, locator|
    { session_id } = Internal.unpack_browser_data(browser)
    (using, value) = Locator.get_locator(locator)

    selector_text = "${locator |> Inspect.to_str}"

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Searching for element: ${selector_text}"),
    )

    element_id = Effect.browser_find_element!(session_id, using, value) |> Result.map_err(InternalError.handle_element_error)?

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

    Internal.pack_element_data({ session_id, element_id, selector_text, locator }) |> Ok

## Find an `Element` in the `Browser`.
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
## maybe_button = browser |> Browser.try_find_element!(Css("#submit-button"))?
##
## when maybe_button is
##     NotFound -> Stdout.line!("Button not found")
##     Found el ->
##         button_text = el |> Element.get_text!
##         Stdout.line!("Button found with text: $(button_text)")
## ```
try_find_element! : Browser, Locator => Result [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
try_find_element! = |browser, locator|
    find_element!(browser, locator)
    |> Result.map_ok(Found)
    |> Result.on_err(
        |err|
            when err is
                ElementNotFound(_) -> Ok(NotFound)
                other -> Err(other),
    )

## Find an `Element` in the `Browser`.
##
## This function will fail if the element is not found - `ElementNotFound Str`
##
## This function will fail if there are more than 1 element - `AssertionError Str`
##
##
## See supported locators at `Locator`.
##
## ```
## button = browser |> Browser.find_single_element!(Css("#submit-button"))?
## ```
find_single_element! : Browser, Locator => Result Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
find_single_element! = |browser, locator|
    elements = find_elements!(browser, locator)?
    when elements |> List.len is
        0 ->
            (_, value) = Locator.get_locator(locator)
            Err(ElementNotFound("element with selector ${value} was not found"))

        1 ->
            elements
            |> List.first
            |> Result.on_err(|_| crash("just check - there is 1 element in the list"))

        n ->
            (_, value) = Locator.get_locator(locator)
            Err(AssertionError("expected to find only 1 element with selector \"${value}\", but found ${n |> Num.to_str}"))

## Find all `Elements` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list
## listItems = browser |> Browser.find_elements!(Css("#my-list li"))?
## ```
##
find_elements! : Browser, Locator => Result (List Element) [WebDriverError Str, ElementNotFound Str]
find_elements! = |browser, locator|
    { session_id } = Internal.unpack_browser_data(browser)
    (using, value) = Locator.get_locator(locator)

    selector_text = "${locator |> Inspect.to_str}"

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Searching for elements: ${selector_text}"),
    )

    result = Effect.browser_find_elements!(session_id, using, value) |> Result.map_err(InternalError.handle_element_error)

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

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = browser |> Browser.take_screenshot_base64!()?
## ```
take_screenshot_base64! : Browser => Result Str [WebDriverError Str]
take_screenshot_base64! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Taking screenshot of the whole page"),
    )

    Effect.browser_get_screenshot!(session_id) |> Result.map_err(WebDriverError)

# PageOrientation : [Landscape, Portrait]
#
# PrintPdfPayload : {
#     page ? PageDimensions,
#     margin ? PageMargins,
#     scale ? F64, # 0.1 - 2.0 - default: 1.0
#     orientation ? PageOrientation, # default: portrait
#     shrink_to_fit ? Bool, # default: true
#     background ? Bool, # default: false
#     page_ranges ? List Str, # default []
# }
#
# PageDimensions : {
#     width : F64, # default: 21.59 cm
#     height : F64, # default: 27.94 cm
# }
#
# PageMargins : {
#     top : F64, # default: 1 cm
#     bottom : F64, # default: 1 cm
#     left : F64, # default: 1 cm
#     right : F64, # default: 1 cm
# }

## Print current page to PDF.
##
## The result will be **base64** encoded `Str`.
##
## All options are optional, with defaults:
## ```
## PageOrientation : [Landscape, Portrait]
##
## PrintPdfPayload : {
##     page ? PageDimensions,
##     margin ? PageMargins,
##     scale ? F64, # 0.1 - 2.0 - default: 1.0
##     orientation ? PageOrientation, # default: portrait
##     shrink_to_fit ? Bool, # default: true
##     background ? Bool, # default: false
##     page_ranges ? List Str, # default []
## }
##
## PageDimensions : {
##     width : F64, # default: 21.59 cm
##     height : F64, # default: 27.94 cm
## }
##
## PageMargins : {
##     top : F64, # default: 1 cm
##     bottom : F64, # default: 1 cm
##     left : F64, # default: 1 cm
##     right : F64, # default: 1 cm
## }
## ```
## ```
## base64_pdf_str = browser |> Browser.print_pdf_base64!({})?
## ```
# print_pdf_base64 : Browser, PrintPdfPayload -> Task.Task Str [WebDriverError Str]
# print_pdf_base64 = \browser, { scale ? 1.0f64, orientation ? Portrait, shrinkToFit ? Bool.true, background ? Bool.false, page ? { width: 21.59f64, height: 27.94f64 }, margin ? { top: 1.0f64, bottom: 1.0f64, left: 1.0f64, right: 1.0f64 }, pageRanges ? [] } ->
#     { sessionId } = Internal.unpackBrowserData browser
#
#     orientationStr = if orientation == Portrait then "portrait" else "landscape"
#     shrinkToFitI64 = if shrinkToFit then 1 else 0
#     backgroundI64 = if background then 1 else 0
#
#     Effect.browserGetPdf sessionId page.width page.height margin.top margin.bottom margin.left margin.right scale orientationStr shrinkToFitI64 backgroundI64 pageRanges |> Task.mapErr WebDriverError

WindowRect : {
    x : I64,
    y : I64,
    width : U32,
    height : U32,
}

SetWindowRectOptions : [
    MoveAndResize
        {
            x : I64,
            y : I64,
            width : U32,
            height : U32,
        },
    Move { x : I64, y : I64 },
    Resize
        {
            width : U32,
            height : U32,
        },
]

## Set browser window position and/or size.
##
## `x` - x position
## `y` - y position
## `width` - width
## `height` - height
##
## The result will contain new dimensions.
##
## **warning** - when running not headless,
## the input dimensions (x, y) are the outer bound dimensions (with the frame).
## But the result contain the dimension of the browser viewport!
##
## ```
## newRect = browser |> Browser.set_window_rect!(Move({ x: 400, y: 600 }))?
## # newRect is { x: 406, y: 627, width: 400, height: 600 }
## ```
## ```
## newRect = browser |> Browser.set_window_rect!(Resize({ width: 800, height: 750 }))?
## # newRect is { x: 300, y: 500, width: 800, height: 750 }
## ```
## ```
## newRect = browser |> Browser.set_window_rect!(MoveAndResize({ x: 400, y: 600, width: 800, height: 750 }))?
## # newRect is { x: 406, y: 627, width: 800, height: 750 }
## ```
set_window_rect! : Browser, SetWindowRectOptions => Result WindowRect [WebDriverError Str]
set_window_rect! = |browser, set_rect_options|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            when set_rect_options is
                Move({ x, y }) -> Debug.print_line!("Moving browser window to: (${x |> Num.to_str}, ${y |> Num.to_str})")
                Resize({ width, height }) -> Debug.print_line!("Resizing browser window to: (${width |> Num.to_str}, ${height |> Num.to_str})")
                MoveAndResize({ x, y, width, height }) -> Debug.print_line!("Moving browser window to: (${x |> Num.to_str}, ${y |> Num.to_str}), and resizing to: (${width |> Num.to_str}, ${height |> Num.to_str})"),
    )

    { disciminant, new_x, new_y, new_width, new_height } =
        when set_rect_options is
            Move({ x, y }) -> { disciminant: 1, new_x: x, new_y: y, new_width: 0, new_height: 0 }
            Resize({ width, height }) -> { disciminant: 2, new_x: 0, new_y: 0, new_width: width |> Num.to_i64, new_height: height |> Num.to_i64 }
            MoveAndResize({ x, y, width, height }) -> { disciminant: 3, new_x: x, new_y: y, new_width: width |> Num.to_i64, new_height: height |> Num.to_i64 }

    Effect.browser_set_window_rect!(session_id, disciminant, new_x, new_y, new_width, new_height)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(WebDriverError)

## Get browser window position and size.
##
## `x` - x position
## `y` - y position
## `width` - width
## `height` - height
##
## **warning** - when running not headless, the result contains the x and y of the browser's viewport,
## without the frame.
##
## ```
## rect = browser |> Browser.get_window_rect!()?
## # rect is { x: 406, y: 627, width: 400, height: 600 }
## ```
get_window_rect! : Browser => Result WindowRect [WebDriverError Str]
get_window_rect! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting browser position and size"),
    )

    Effect.browser_get_window_rect!(session_id)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(WebDriverError)

## Navigate back in the browser history.
##
## ```
## browser |> Browser.navigate_back!()?
## ```
navigate_back! : Browser => Result {} [WebDriverError Str]
navigate_back! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Navigating back"),
    )

    Effect.browser_navigate_back!(session_id) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Navigate forward in the browser history.
##
## ```
## browser |> Browser.navigate_forward!()?
## ```
navigate_forward! : Browser => Result {} [WebDriverError Str]
navigate_forward! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Navigating froward"),
    )

    Effect.browser_navigate_forward!(session_id) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Reload the current page.
##
## ```
## browser |> Browser.reload_page!()?
## ```
reload_page! : Browser => Result {} [WebDriverError Str]
reload_page! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Reloading page"),
    )

    Effect.browser_reload!(session_id) |> Result.map_err(WebDriverError)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Maximize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## new_rect = browser |> Browser.maximize_window!()?
## ```
maximize_window! : Browser => Result WindowRect [WebDriverError Str]
maximize_window! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Maximizing browser window"),
    )

    Effect.browser_maximize!(session_id)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(WebDriverError)

## Minimize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## new_rect = browser |> Browser.minimize_window!()?
## ```
minimize_window! : Browser => Result WindowRect [WebDriverError Str]
minimize_window! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Minimizing browser window"),
    )

    Effect.browser_minimize!(session_id)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(WebDriverError)

## Make the `Browser` window full screen.
##
## Can fail when the system does not support this operation.
##
## ```
## new_rect = browser |> Browser.full_screen_window!()?
## ```
full_screen_window! : Browser => Result WindowRect [WebDriverError Str]
full_screen_window! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Making browser window full screen"),
    )

    Effect.browser_full_screen!(session_id)
    |> Result.map_ok(
        |list|
            when list is
                [x_val, y_val, width_val, height_val] -> { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
                _ -> crash("the contract with host should not fail"),
    )
    |> Result.map_err(WebDriverError)

## Execute JavaScript in the `Browser`.
##
## ```
## browser |> Browser.execute_js!("console.log('wow')")?
## ```
execute_js! : Browser, Str => Result {} [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
execute_js! = |browser, script|
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Executing JavaScript in the browser"),
    )

    _output : Str
    _output = ExecuteJs.execute_js!(browser, script)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Execute JavaScript in the `Browser` and get the response.
##
## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
## R2E will try to cast the browser response to the choosen type.
##
## When the response is empty e.g. property does not exist, then the default value of the choosen type will be used:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## The output will be casted to expected Roc type:
##
## ```
##  response = browser |> Browser.execute_js_with_output!("return 50 + 5;")?
##  response |> Assert.should_be(55)
##
##  response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;")?
##  response |> Assert.should_be(55.5)
##
##  response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;")?
##  response |> Assert.should_be("55.5")
##
##  response = browser |> Browser.execute_js_with_output!("return true")?
##  response |> Assert.should_be("true")
##
##  response = browser |> Browser.execute_js_with_output!("return true")?
##  response |> Assert.should_be(Bool.true)
## ```
##
## The function can return a `Promise`.
execute_js_with_output! : Browser, Str => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
execute_js_with_output! = |browser, script|
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Executing JavaScript in the browser"),
    )

    result = ExecuteJs.execute_js!(browser, script)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok(result)

JsValue : [String Str, Number F64, Boolean Bool, Null]

## Execute JavaScript in the `Browser` with arguments and get the response.
##
## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
## R2E will try to cast the browser response to the choosen type.
##
## The arguments is a list of:
##
## ```
## JsValue : [String Str, Number F64, Boolean Bool, Null]
## ```
##
## When the response is empty e.g. property does not exist, then the default value of the choosen type will be used:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## Args can only be used using the `arguments` array in js.
##
## The output will be casted to expected Roc type:
##
## ```
##  response = browser |> Browser.execute_js_with_args!("return 50 + 5;", [])?
##  response |> Assert.should_Be(55)
##
##  response = browser |> Browser.execute_js_with_args!("return 50.5 + 5;", [Number 55.5, String "5"])?
##  response |> Assert.should_be(55.5)
## ```
##
## The function can return a `Promise`.
execute_js_with_args! : Browser, Str, List JsValue => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
execute_js_with_args! = |browser, script, arguments|
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Executing JavaScript in the browser"),
    )

    result = ExecuteJs.execute_js_with_args!(browser, script, arguments)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok(result)

# COOKIES
NewCookie : {
    name : Str,
    value : Str,
    domain ?? Str,
    path ?? Str,
    same_site ?? SameSiteOption,
    secure ?? Bool,
    http_only ?? Bool,
    expiry ?? CookieExpiry,
}

## R2E cookie representation
##
## ```
## Cookie : {
##     name : Str,
##     value : Str,
##     domain : Str,
##     path : Str,
##     sameSite : SameSiteOption,
##     secure : Bool,
##     httpOnly : Bool,
##     expiry : CookieExpiry,
## }
##
## # MaxAge is a Epoch Timestamp (browsers accepts max 400 days in the future)
## CookieExpiry : [Session, MaxAge U32]
##
## SameSiteOption : [None, Lax, Strict]
## ```
Cookie : {
    name : Str,
    value : Str,
    domain : Str,
    path : Str,
    same_site : SameSiteOption,
    secure : Bool,
    http_only : Bool,
    expiry : CookieExpiry,
}

CookieExpiry : [Session, MaxAge U32]

SameSiteOption : [None, Lax, Strict]

same_site_option_to_str : SameSiteOption -> Str
same_site_option_to_str = |option|
    when option is
        None -> "None"
        Lax -> "Lax"
        Strict -> "Strict"

same_site_str_to_option = |str|
    when str is
        "None" -> None
        "Lax" -> Lax
        "Strict" -> Strict
        # TODO - hmm
        _ -> None

bool_to_int = |bool|
    if bool then 1 else 0

## Add a cookie in the `Browser`.
##
## ```
## browser |> Browser.add_cookie!({ name: "myCookie", value: "value1" })?
## ```
## ```
## browser |> Browser.add_cookie!({
##     name: "myCookie",
##     value: "value1",
##     domain: "my-top-level-domain.com",
##     path: "/path",
##     same_site: Lax,
##     secure: Bool.true,
##     http_only: Bool.true,
##     expiry: MaxAge(2865848396), # unix epoch
## }?
## ```
add_cookie! : Browser, NewCookie => Result {} [WebDriverError Str]
add_cookie! = |browser, { name, value, domain ?? "", path ?? "", same_site ?? None, secure ?? Bool.false, http_only ?? Bool.false, expiry ?? Session }|
    { session_id } = Internal.unpack_browser_data(browser)

    same_site_str = same_site |> same_site_option_to_str
    secure_int = secure |> bool_to_int
    http_only_int = http_only |> bool_to_int
    expiry_i64 =
        when expiry is
            Session -> -1
            MaxAge(n) -> n |> Num.to_i64

    Effect.add_cookie!(session_id, name, value, domain, path, same_site_str, http_only_int, secure_int, expiry_i64)
    |> Result.map_err(WebDriverError)

## Delete a cookie in the `Browser` by name.
##
## ```
## browser |> Browser.delete_cookie!("myCookieName")?
## ```
delete_cookie! : Browser, Str => Result {} [WebDriverError Str, CookieNotFound Str]
delete_cookie! = |browser, name|
    { session_id } = Internal.unpack_browser_data(browser)

    Effect.delete_cookie!(session_id, name) |> Result.map_err(InternalError.handle_cookie_error)

## Delete all cookies in the `Browser`.
##
## ```
## browser |> Browser.delete_all_cookies!?
## ```
delete_all_cookies! : Browser => Result {} [WebDriverError Str]
delete_all_cookies! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    Effect.delete_all_cookies!(session_id) |> Result.map_err(WebDriverError)

## Get a cookie from the `Browser` by name.
##
## ```
## cookie1 = browser |> Browser.get_cookie!("myCookie")?
## cookie1 |> Assert.should_be({
##     name: "myCookie",
##     value: "value1",
##     domain: ".my-domain.io",
##     path: "/",
##     same_site: Lax,
##     expiry: Session,
##     secure: Bool.true,
##     http_only: Bool.false,
## })
## ```
get_cookie! : Browser, Str => Result Cookie [WebDriverError Str, CookieNotFound Str]
get_cookie! = |browser, cookie_name|
    { session_id } = Internal.unpack_browser_data(browser)

    cookie_array = Effect.get_cookie!(session_id, cookie_name) |> Result.map_err(InternalError.handle_cookie_error)?
    cookie_array |> cookie_array_to_roc_cookie

## Get all cookies from the `Browser`.
##
## ```
## cookies = browser |> Browser.get_all_cookies!()?
## cookies |> List.len |> Assert.should_be(3)
## ```
get_all_cookies! : Browser => Result (List Cookie) [WebDriverError Str, CookieNotFound Str]
get_all_cookies! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    cookies = Effect.get_all_cookies!(session_id) |> Result.map_err(InternalError.handle_cookie_error)?
    roc_cookies =
        cookies
        |> List.map(cookie_array_to_roc_cookie) # TODO - right now I'm ignoring errors
        |> List.keep_oks(|e| e)

    roc_cookies |> Ok

cookie_array_to_roc_cookie : List Str -> Result Cookie [WebDriverError Str]
cookie_array_to_roc_cookie = |cookie_array|
    when cookie_array is
        [name, value, domain, path, http_only_str, secure_str, same_site_str, expiry_str] ->
            http_only = if http_only_str == "true" then Bool.true else Bool.false
            secure = if secure_str == "true" then Bool.true else Bool.false
            same_site = same_site_str |> same_site_str_to_option
            expiry =
                expiry_str
                |> expiry_str_to_roc
                |> Result.map_err(|_| WebDriverError("could not parse cookie: probabably a bug in R2E"))?

            Ok({ name, value, domain, path, expiry, http_only, same_site, secure })

        _ -> Err(WebDriverError("could not parse cookie: probably a bug in R2E"))

expiry_str_to_roc = |exp_str|
    if exp_str |> Str.is_empty then
        Session |> Ok
    else
        u32 = exp_str |> Str.to_u32?
        u32 |> MaxAge |> Ok

## Get alert/prompt text.
##
## ```
## text = browser |> Browser.get_alert_text!()?
## text |> Assert.should_be("Are you sure to close tab?")
## ```
get_alert_text! : Browser => Result Str [WebDriverError Str, AlertNotFound Str]
get_alert_text! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting alert text"),
    )

    Effect.alert_get_text!(session_id) |> Result.map_err(InternalError.handle_alert_error)

## Input text in prompt.
##
## ```
## browser |> Browser.send_text_to_alert!("my reply")?
## browser |> Browser.accept_alert!()?
## ```
send_text_to_alert! : Browser, Str => Result {} [WebDriverError Str, AlertNotFound Str]
send_text_to_alert! = |browser, text|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Sending text to an alert: \"${text}\""),
    )

    Effect.alert_send_text!(session_id, text) |> Result.map_err(InternalError.handle_alert_error)

## Accept alert/prompt.
##
## ```
## browser |> Browser.accept_alert!()?
## ```
accept_alert! : Browser => Result {} [WebDriverError Str, AlertNotFound Str]
accept_alert! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Accepting an alert"),
    )

    Effect.alert_accept!(session_id) |> Result.map_err(InternalError.handle_alert_error)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Dismiss alert/prompt.
##
## ```
## browser |> Browser.dismiss_alert!()?
## ```
dismiss_alert! : Browser => Result {} [WebDriverError Str, AlertNotFound Str]
dismiss_alert! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Dismissing an alert"),
    )

    Effect.alert_dismiss!(session_id) |> Result.map_err(InternalError.handle_alert_error)?

    DebugMode.run_if_debug_mode!(
        |{}|
            DebugMode.wait!({}),
    )

    Ok({})

## Get the serialized DOM as HTML `Str`.
##
## ```
## html = browser |> Browser.get_page_html!()?
## html |> Assert.should_contain_text("<h1>Header</h1>")
## ```
get_page_html! : Browser => Result Str [WebDriverError Str]
get_page_html! = |browser|
    { session_id } = Internal.unpack_browser_data(browser)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Getting page HTML"),
    )

    Effect.get_page_source!(session_id) |> Result.map_err(WebDriverError)
