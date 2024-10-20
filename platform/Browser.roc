## `Browser` module contains functions to interact with the `Browser`.
module [
    openNewWindow,
    openNewWindowWithCleanup,
    closeWindow,
    navigateTo,
    setWindowRect,
    getWindowRect,
    getTitle,
    getUrl,
    findElement,
    tryFindElement,
    findSingleElement,
    findElements,
    takeScreenshotBase64,
    # printPdfBase64,
    Locator,
    navigateBack,
    navigateForward,
    reloadPage,
    maximizeWindow,
    minimizeWindow,
    fullScreenWindow,
]

import Effect
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
    Effect.browserNavigateTo sessionId url |> Task.mapErr WebDriverError

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
Locator : [
    # !WARNING this code is duplicated in `Element` module
    Css Str,
    TestId Str,
    XPath Str,
    LinkText Str,
    PartialLinkText Str,
]

# !WARNING this code is duplicated in `Element` module
getLocator : Locator -> (Str, Str)
getLocator = \locator ->
    when locator is
        Css cssSelector -> ("css selector", cssSelector)
        # TODO - script injection
        TestId id -> ("css selector", "[data-testid=\"$(id)\"]")
        LinkText text -> ("link text", text)
        PartialLinkText text -> ("partial link text", text)
        # Tag tag -> ("tag name", tag)
        XPath path -> ("xpath", path)

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
    (using, value) = getLocator locator

    elementId = Effect.browserFindElement sessionId using value |> Task.mapErr! handleFindElementError

    selectorText = "$(locator |> Inspect.toStr)"

    Internal.packElementData { sessionId, elementId, selectorText } |> Task.ok

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
            (_, value) = getLocator locator
            Task.err (ElementNotFound "element with selector $(value) was not found")

        1 ->
            elements
            |> List.first
            |> Result.onErr \_ -> crash "just check - there is 1 element in the list"
            |> Task.fromResult

        n ->
            (_, value) = getLocator locator
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
    (using, value) = getLocator locator

    result = Effect.browserFindElements sessionId using value |> Task.mapErr handleFindElementError |> Task.result!

    selectorText = "$(locator |> Inspect.toStr)"

    when result is
        Ok elementIds ->
            elementIds
            |> List.map \elementId ->
                Internal.packElementData { sessionId, elementId, selectorText }
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

    Effect.browserNavigateBack sessionId |> Task.mapErr WebDriverError

## Navigate forward in the browser history.
##
## ```
## browser |> Browser.navigateForward!
## ```
navigateForward : Browser -> Task {} [WebDriverError Str]
navigateForward = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.browserNavigateForward sessionId |> Task.mapErr WebDriverError

## Reload the current page.
##
## ```
## browser |> Browser.reloadPage!
## ```
reloadPage : Browser -> Task {} [WebDriverError Str]
reloadPage = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

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
fullScreenWindow : Browser -> Task.Task WindowRect [WebDriverError Str]
fullScreenWindow = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.browserFullScreen sessionId
    |> Task.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Task.mapErr WebDriverError
