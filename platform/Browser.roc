## `Browser` module contains functions to interact with the `Browser`.
module [
    openNewWindow,
    openNewWindowWithCleanup,
    closeWindow,
    navigateTo,
    navigateBack,
    navigateForward,
    reloadPage,
    getTitle,
    getUrl,
    Locator,
    findElement,
    tryFindElement,
    findSingleElement,
    findElements,
    takeScreenshotBase64,
    # printPdfBase64,
    maximizeWindow,
    minimizeWindow,
    fullScreenWindow,
    setWindowRect,
    getWindowRect,
    executeJs,
    executeJsWithOutput,
    executeJsWithArgs,
]

import Effect
import Common.ExecuteJs as ExecuteJs
import Common.Locator as Locator
import DebugMode
import Debug
import Internal exposing [Browser, Element]

## Opens a new `Browser` window.
##
## Only the browser provided by the test will be closed automatically,
## please remember to close the browser windows you open manually.
##
## ```
## newBrowser = Browser.openNewWindow!
## ...
## browser |> Browser.closeWindow!
## ```
openNewWindow : Task Browser [WebDriverError Str]
openNewWindow =
    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Opening new browser window"

    Effect.startSession {}
    |> Task.mapErr WebDriverError
    |> Task.map \sessionId ->
        Internal.packBrowserData { sessionId }

## Opens a new `Browser` window and runs a callback.
## Will close the browser after the callback is finished.
##
## ```
## Browser.openNewWindowWithCleanup! \browser2 ->
##     browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"
## ```
openNewWindowWithCleanup : (Browser -> Task val [WebDriverError Str]err) -> Task val [WebDriverError Str]err
openNewWindowWithCleanup = \callback ->
    browser = openNewWindow!
    result = callback browser |> Task.result!
    browser |> closeWindow!
    result |> Task.fromResult

## Close a `Browser` window.
##
## Do not close the browser provided by the test,
## the automatic cleanup will fail trying to close this browser.
##
## ```
## newBrowser = Browser.openNewWindow!
## ...
## browser |> Browser.closeWindow!
## ```
closeWindow : Browser -> Task {} [WebDriverError Str]
closeWindow = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Closing browser window"

    Effect.deleteSession sessionId |> Task.mapErr WebDriverError

## Navigate the browser to the given URL.
##
## ```
## # open google.com
## browser |> Browser.navigateTo! "http://google.com"
## ```
navigateTo : Browser, Str -> Task {} [WebDriverError Str]
navigateTo = \browser, url ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Navigating to: $(url)"

    Effect.browserNavigateTo sessionId url |> Task.mapErr! WebDriverError

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait!

    Task.ok {}

## Get browser title.
##
## ```
## browser |> Browser.navigateTo! "http://google.com"
## # get title
## title = browser |> Browser.getTitle!
## # title = "Google"
## ```
getTitle : Browser -> Task.Task Str [WebDriverError Str]
getTitle = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Getting title of the current page"

    Effect.browserGetTitle sessionId |> Task.mapErr WebDriverError

## Get current URL.
##
## ```
## browser |> Browser.navigateTo! "http://google.com"
## # get url
## url = browser |> Browser.getUrl!
## # url = "https://google.com/"
## ```
getUrl : Browser -> Task Str [WebDriverError Str]
getUrl = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Getting url of the current page"

    Effect.browserGetUrl sessionId
    |> Task.mapErr WebDriverError

## Supported locator strategies
##
## `Css Str` - e.g. Css ".my-button-class"
##
## `TestId Str` - e.g. TestId "button" => Css "[data-testid=\"button\"]"
##
## `XPath Str` - e.g. XPath "/bookstore/book[price>35]/price"
##
## `LinkText Str` - e.g. LinkText "Examples" in <a href="/examples-page">Examples</a>
##
## `PartialLinkText Str` - e.g. PartialLinkText "Exam" in <a href="/examples-page">Examples</a>
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
## button = browser |> Browser.findElement! (Css "#my-id")
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = browser |> Browser.findElement! (Css ".my-class")
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = browser |> Browser.findElement! (TestId "my-element")
## ```
findElement : Browser, Locator -> Task Element [WebDriverError Str, ElementNotFound Str]
findElement = \browser, locator ->
    { sessionId } = Internal.unpackBrowserData browser
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Searching for element: $(selectorText)"

    elementId = Effect.browserFindElement sessionId using value |> Task.mapErr! handleFindElementError

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Found element: $(selectorText)"
        DebugMode.showDebugMessageInBrowser! sessionId "Find Element $(selectorText)"
        DebugMode.flashElements! sessionId locator Single
        DebugMode.wait!

    Internal.packElementData { sessionId, elementId, selectorText, locator } |> Task.ok

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
## maybeButton = browser |> Browser.tryFindElement! (Css "#submit-button")
##
## when maybeButton is
##     NotFound -> Stdout.line! "Button not found"
##     Found el ->
##         buttonText = el |> Element.getText!
##         Stdout.line! "Button found with text: $(buttonText)"
## ```
tryFindElement : Browser, Locator -> Task [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
tryFindElement = \browser, locator ->
    findElement browser locator
    |> Task.map Found
    |> Task.onErr \err ->
        when err is
            ElementNotFound _ -> Task.ok NotFound
            other -> Task.err other

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
## button = browser |> Browser.findSingleElement! (Css "#submit-button")
## ```
findSingleElement : Browser, Locator -> Task Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
findSingleElement = \browser, locator ->
    elements = findElements! browser locator
    when elements |> List.len is
        0 ->
            (_, value) = Locator.getLocator locator
            Task.err (ElementNotFound "element with selector $(value) was not found")

        1 ->
            elements
            |> List.first
            |> Result.onErr \_ -> crash "just check - there is 1 element in the list"
            |> Task.fromResult

        n ->
            (_, value) = Locator.getLocator locator
            Task.err (AssertionError "expected to find only 1 element with selector \"$(value)\", but found $(n |> Num.toStr)")

## Find all `Elements` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list
## listItems = browser |> Browser.findElements! (Css "#my-list li")
## ```
##
findElements : Browser, Locator -> Task (List Element) [WebDriverError Str, ElementNotFound Str]
findElements = \browser, locator ->
    { sessionId } = Internal.unpackBrowserData browser
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Searching for elements: $(selectorText)"

    result = Effect.browserFindElements sessionId using value |> Task.mapErr handleFindElementError |> Task.result!

    when result is
        Ok elementIds ->
            DebugMode.runIfDebugMode! \{} ->
                Debug.printLine! "Found $(elementIds |> List.len |> Num.toStr) elements: $(selectorText)"
                if elementIds |> List.isEmpty then
                    Task.ok {}
                else
                    DebugMode.showDebugMessageInBrowser! sessionId "Find Elements $(selectorText)"
                    DebugMode.flashElements! sessionId locator All
                    DebugMode.wait!

            elementIds
            |> List.map \elementId ->
                Internal.packElementData { sessionId, elementId, selectorText, locator }
            |> Task.ok

        Err (ElementNotFound _) -> Task.ok []
        Err err -> Task.err err

handleFindElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = browser |> Browser.takeScreenshotBase64!
## ```
takeScreenshotBase64 : Browser -> Task Str [WebDriverError Str]
takeScreenshotBase64 = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Taking screenshot of the whole page"

    Effect.browserGetScreenshot sessionId |> Task.mapErr WebDriverError

# PageOrientation : [Landscape, Portrait]
#
# PrintPdfPayload : {
#     page ? PageDimensions,
#     margin ? PageMargins,
#     scale ? F64, # 0.1 - 2.0 - default: 1.0
#     orientation ? PageOrientation, # default: portrait
#     shrinkToFit ? Bool, # default: true
#     background ? Bool, # default: false
#     pageRanges ? List Str, # default []
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
##     shrinkToFit ? Bool, # default: true
##     background ? Bool, # default: false
##     pageRanges ? List Str, # default []
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
## base64PdfStr = browser |> Browser.printPdfBase64! {}
## ```
# printPdfBase64 : Browser, PrintPdfPayload -> Task.Task Str [WebDriverError Str]
# printPdfBase64 = \browser, { scale ? 1.0f64, orientation ? Portrait, shrinkToFit ? Bool.true, background ? Bool.false, page ? { width: 21.59f64, height: 27.94f64 }, margin ? { top: 1.0f64, bottom: 1.0f64, left: 1.0f64, right: 1.0f64 }, pageRanges ? [] } ->
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
## newRect = browser |> Browser.setWindowRect! (Move { x: 400, y: 600 })
## # newRect is { x: 406, y: 627, width: 400, height: 600 }
## ```
## ```
## newRect = browser |> Browser.setWindowRect! (Resize { width: 800, height: 750 })
## # newRect is { x: 300, y: 500, width: 800, height: 750 }
## ```
## ```
## newRect = browser |> Browser.setWindowRect! (MoveAndResize { x: 400, y: 600, width: 800, height: 750 })
## # newRect is { x: 406, y: 627, width: 800, height: 750 }
## ```
setWindowRect : Browser, SetWindowRectOptions -> Task.Task WindowRect [WebDriverError Str]
setWindowRect = \browser, setRectOptions ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        when setRectOptions is
            Move { x, y } -> Debug.printLine "Moving browser window to: ($(x |> Num.toStr), $(y |> Num.toStr))"
            Resize { width, height } -> Debug.printLine "Resizing browser window to: ($(width |> Num.toStr), $(height |> Num.toStr))"
            MoveAndResize { x, y, width, height } -> Debug.printLine "Moving browser window to: ($(x |> Num.toStr), $(y |> Num.toStr)), and resizing to: ($(width |> Num.toStr), $(height |> Num.toStr))"

    { disciminant, newX, newY, newWidth, newHeight } =
        when setRectOptions is
            Move { x, y } -> { disciminant: 1, newX: x, newY: y, newWidth: 0, newHeight: 0 }
            Resize { width, height } -> { disciminant: 2, newX: 0, newY: 0, newWidth: width |> Num.toI64, newHeight: height |> Num.toI64 }
            MoveAndResize { x, y, width, height } -> { disciminant: 3, newX: x, newY: y, newWidth: width |> Num.toI64, newHeight: height |> Num.toI64 }

    Effect.browserSetWindowRect sessionId disciminant newX newY newWidth newHeight
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError

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
## rect = browser |> Browser.getWindowRect!
## # rect is { x: 406, y: 627, width: 400, height: 600 }
## ```
getWindowRect : Browser -> Task WindowRect [WebDriverError Str]
getWindowRect = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Getting browser position and size"

    Effect.browserGetWindowRect sessionId
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError

## Navigate back in the browser history.
##
## ```
## browser |> Browser.navigateBack!
## ```
navigateBack : Browser -> Task {} [WebDriverError Str]
navigateBack = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Navigating back"

    Effect.browserNavigateBack sessionId |> Task.mapErr WebDriverError

## Navigate forward in the browser history.
##
## ```
## browser |> Browser.navigateForward!
## ```
navigateForward : Browser -> Task {} [WebDriverError Str]
navigateForward = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Navigating froward"

    Effect.browserNavigateForward sessionId |> Task.mapErr WebDriverError

## Reload the current page.
##
## ```
## browser |> Browser.reloadPage!
## ```
reloadPage : Browser -> Task {} [WebDriverError Str]
reloadPage = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Reloading page"

    Effect.browserReload sessionId |> Task.mapErr WebDriverError

## Maximize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.maximizeWindow!
## ```
maximizeWindow : Browser -> Task WindowRect [WebDriverError Str]
maximizeWindow = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Maximizing browser window"

    Effect.browserMaximize sessionId
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError

## Minimize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.minimizeWindow!
## ```
minimizeWindow : Browser -> Task WindowRect [WebDriverError Str]
minimizeWindow = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Minimizing browser window"

    Effect.browserMinimize sessionId
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError

## Make the `Browser` window full screen.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.fullScreenWindow!
## ```
fullScreenWindow : Browser -> Task WindowRect [WebDriverError Str]
fullScreenWindow = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Making browser window full screen"

    Effect.browserFullScreen sessionId
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError

## Execute JavaScript in the `Browser`.
##
## ```
## browser |> Browser.executeJs! "console.log('wow')"
## ```
executeJs : Browser, Str -> Task {} [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJs = \browser, script ->
    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    _output : Str
    _output = ExecuteJs.executeJs! browser script
    Task.ok {}

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
##  response = browser |> Browser.executeJsWithOutput! "return 50 + 5;"
##  response |> Assert.shouldBe! 55
##
##  response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;"
##  response |> Assert.shouldBe! 55.5
##
##  response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;"
##  response |> Assert.shouldBe! "55.5"
##
##  response = browser |> Browser.executeJsWithOutput! "return true"
##  response |> Assert.shouldBe! "true"
##
##  response = browser |> Browser.executeJsWithOutput! "return true"
##  response |> Assert.shouldBe! Bool.true
## ```
##
## The function can return a `Promise`.
executeJsWithOutput : Browser, Str -> Task a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJsWithOutput = \browser, script ->
    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    ExecuteJs.executeJs browser script

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
##  response = browser |> Browser.executeJsWithArgs! "return 50 + 5;" []
##  response |> Assert.shouldBe! 55
##
##  response = browser |> Browser.executeJsWithArgs! "return 50.5 + 5;" [Number 55.5, String "5"]
##  response |> Assert.shouldBe! 55.5
## ```
##
## The function can return a `Promise`.
executeJsWithArgs : Browser, Str, List JsValue -> Task a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJsWithArgs = \browser, script, arguments ->
    DebugMode.runIfDebugMode! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    ExecuteJs.executeJsWithArgs browser script arguments
