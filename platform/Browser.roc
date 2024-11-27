# `Browser` module contains functions to interact with the `Browser`.
module [
    openNewWindow!,
    openNewWindowWithCleanup!,
    closeWindow!,
    navigateTo!,
    navigateBack!,
    navigateForward!,
    reloadPage!,
    getTitle!,
    getUrl!,
    Locator,
    findElement!,
    tryFindElement!,
    findSingleElement!,
    findElements!,
    takeScreenshotBase64!,
    # printPdfBase64,
    maximizeWindow!,
    minimizeWindow!,
    fullScreenWindow!,
    setWindowRect!,
    getWindowRect!,
    executeJs!,
    executeJsWithOutput!,
    executeJsWithArgs!,
    Cookie,
    CookieExpiry,
    SameSiteOption,
    addCookie!,
    getCookie!,
    getAllCookies!,
    deleteCookie!,
    deleteAllCookies!,
    acceptAlert!,
    dismissAlert!,
    sendTextToAlert!,
    getAlertText!,
    getPageHtml!,
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
## newBrowser = Browser.openNewWindow! {} |> try
## ...
## newBrowser |> Browser.closeWindow! |> try
## ```
openNewWindow! : {} => Result Browser [WebDriverError Str]
openNewWindow! = \{} ->
    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Opening new browser window"

    Effect.startSession! {}
    |> Result.mapErr WebDriverError
    |> Result.map \sessionId ->
        Internal.packBrowserData { sessionId }

## Opens a new `Browser` window and runs a callback.
## Will close the browser after the callback is finished.
##
## ```
## try Browser.openNewWindowWithCleanup! \browser2 ->
##     browser2 |> Browser.navigateTo! "https://www.roc-lang.org/"
## ```
openNewWindowWithCleanup! : (Browser => Result val [WebDriverError Str]err) => Result val [WebDriverError Str]err
openNewWindowWithCleanup! = \callback! ->
    browser = openNewWindow! {} |> try
    result = callback! browser
    browser |> closeWindow! |> try
    result

## Close a `Browser` window.
##
## Do not close the browser provided by the test,
## the automatic cleanup will fail trying to close this browser.
##
## ```
## newBrowser = Browser.openNewWindow! {}
## ...
## newBrowser |> Browser.closeWindow!
## ```
closeWindow! : Browser => Result {} [WebDriverError Str]
closeWindow! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Closing browser window"

    Effect.deleteSession! sessionId |> Result.mapErr WebDriverError

## Navigate the browser to the given URL.
##
## ```
## # open google.com
## browser |> Browser.navigateTo! "http://google.com" |> try
## ```
navigateTo! : Browser, Str => Result {} [WebDriverError Str]
navigateTo! = \browser, url ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Navigating to: $(url)"

    Effect.browserNavigateTo! sessionId url |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Get browser title.
##
## ```
## browser |> Browser.navigateTo! "http://google.com" |> try
## # get title
## title = browser |> Browser.getTitle! |> try
## # title = "Google"
## ```
getTitle! : Browser => Result Str [WebDriverError Str]
getTitle! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting title of the current page"

    Effect.browserGetTitle! sessionId |> Result.mapErr WebDriverError

## Get current URL.
##
## ```
## browser |> Browser.navigateTo! "http://google.com" |> try
## # get url
## url = browser |> Browser.getUrl! |> try
## # url = "https://google.com/"
## ```
getUrl! : Browser => Result Str [WebDriverError Str]
getUrl! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting url of the current page"

    Effect.browserGetUrl! sessionId
    |> Result.mapErr WebDriverError

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
## button = browser |> Browser.findElement! (Css "#my-id") |> try
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = browser |> Browser.findElement! (Css ".my-class") |> try
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = browser |> Browser.findElement! (TestId "my-element") |> try
## ```
findElement! : Browser, Locator => Result Element [WebDriverError Str, ElementNotFound Str]
findElement! = \browser, locator ->
    { sessionId } = Internal.unpackBrowserData browser
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for element: $(selectorText)"

    elementId = Effect.browserFindElement! sessionId using value |> Result.mapErr InternalError.handleElementError |> try

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Found element: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Find Element $(selectorText)" |> try
        DebugMode.flashElements! sessionId locator Single |> try
        DebugMode.wait! {}
        Ok {}

    Internal.packElementData { sessionId, elementId, selectorText, locator } |> Ok

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
## maybeButton = browser |> Browser.tryFindElement! (Css "#submit-button") |> try
##
## when maybeButton is
##     NotFound -> Stdout.line! "Button not found"
##     Found el ->
##         buttonText = el |> Element.getText!
##         Stdout.line! "Button found with text: $(buttonText)"
## ```
tryFindElement! : Browser, Locator => Result [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
tryFindElement! = \browser, locator ->
    findElement! browser locator
    |> Result.map Found
    |> Result.onErr \err ->
        when err is
            ElementNotFound _ -> Ok NotFound
            other -> Err other

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
## button = browser |> Browser.findSingleElement! (Css "#submit-button") |> try
## ```
findSingleElement! : Browser, Locator => Result Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
findSingleElement! = \browser, locator ->
    elements = findElements! browser locator |> try
    when elements |> List.len is
        0 ->
            (_, value) = Locator.getLocator locator
            Err (ElementNotFound "element with selector $(value) was not found")

        1 ->
            elements
            |> List.first
            |> Result.onErr \_ -> crash "just check - there is 1 element in the list"

        n ->
            (_, value) = Locator.getLocator locator
            Err (AssertionError "expected to find only 1 element with selector \"$(value)\", but found $(n |> Num.toStr)")

## Find all `Elements` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list
## listItems = browser |> Browser.findElements! (Css "#my-list li") |> try
## ```
##
findElements! : Browser, Locator => Result (List Element) [WebDriverError Str, ElementNotFound Str]
findElements! = \browser, locator ->
    { sessionId } = Internal.unpackBrowserData browser
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for elements: $(selectorText)"

    result = Effect.browserFindElements! sessionId using value |> Result.mapErr InternalError.handleElementError

    when result is
        Ok elementIds ->
            DebugMode.runIfVerbose! \{} ->
                Debug.printLine! "Found $(elementIds |> List.len |> Num.toStr) elements: $(selectorText)"

            DebugMode.runIfDebugMode! \{} ->
                if elementIds |> List.isEmpty then
                    Ok {}
                else
                    DebugMode.showDebugMessageInBrowser! sessionId "Find Elements $(selectorText)" |> try
                    DebugMode.flashElements! sessionId locator All |> try
                    DebugMode.wait! {}
                    Ok {}

            elementIds
            |> List.map \elementId ->
                Internal.packElementData { sessionId, elementId, selectorText, locator }
            |> Ok

        Err (ElementNotFound _) -> Ok []
        Err err -> Err err

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = browser |> Browser.takeScreenshotBase64! |> try
## ```
takeScreenshotBase64! : Browser => Result Str [WebDriverError Str]
takeScreenshotBase64! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Taking screenshot of the whole page"

    Effect.browserGetScreenshot! sessionId |> Result.mapErr WebDriverError

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
## newRect = browser |> Browser.setWindowRect! (Move { x: 400, y: 600 }) |> try
## # newRect is { x: 406, y: 627, width: 400, height: 600 }
## ```
## ```
## newRect = browser |> Browser.setWindowRect! (Resize { width: 800, height: 750 }) |> try
## # newRect is { x: 300, y: 500, width: 800, height: 750 }
## ```
## ```
## newRect = browser |> Browser.setWindowRect! (MoveAndResize { x: 400, y: 600, width: 800, height: 750 }) |> try
## # newRect is { x: 406, y: 627, width: 800, height: 750 }
## ```
setWindowRect! : Browser, SetWindowRectOptions => Result WindowRect [WebDriverError Str]
setWindowRect! = \browser, setRectOptions ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        when setRectOptions is
            Move { x, y } -> Debug.printLine! "Moving browser window to: ($(x |> Num.toStr), $(y |> Num.toStr))"
            Resize { width, height } -> Debug.printLine! "Resizing browser window to: ($(width |> Num.toStr), $(height |> Num.toStr))"
            MoveAndResize { x, y, width, height } -> Debug.printLine! "Moving browser window to: ($(x |> Num.toStr), $(y |> Num.toStr)), and resizing to: ($(width |> Num.toStr), $(height |> Num.toStr))"

    { disciminant, newX, newY, newWidth, newHeight } =
        when setRectOptions is
            Move { x, y } -> { disciminant: 1, newX: x, newY: y, newWidth: 0, newHeight: 0 }
            Resize { width, height } -> { disciminant: 2, newX: 0, newY: 0, newWidth: width |> Num.toI64, newHeight: height |> Num.toI64 }
            MoveAndResize { x, y, width, height } -> { disciminant: 3, newX: x, newY: y, newWidth: width |> Num.toI64, newHeight: height |> Num.toI64 }

    Effect.browserSetWindowRect! sessionId disciminant newX newY newWidth newHeight
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr WebDriverError

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
## rect = browser |> Browser.getWindowRect! |> try
## # rect is { x: 406, y: 627, width: 400, height: 600 }
## ```
getWindowRect! : Browser => Result WindowRect [WebDriverError Str]
getWindowRect! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting browser position and size"

    Effect.browserGetWindowRect! sessionId
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr WebDriverError

## Navigate back in the browser history.
##
## ```
## browser |> Browser.navigateBack! |> try
## ```
navigateBack! : Browser => Result {} [WebDriverError Str]
navigateBack! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Navigating back"

    Effect.browserNavigateBack! sessionId |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Navigate forward in the browser history.
##
## ```
## browser |> Browser.navigateForward! |> try
## ```
navigateForward! : Browser => Result {} [WebDriverError Str]
navigateForward! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Navigating froward"

    Effect.browserNavigateForward! sessionId |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Reload the current page.
##
## ```
## browser |> Browser.reloadPage! |> try
## ```
reloadPage! : Browser => Result {} [WebDriverError Str]
reloadPage! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Reloading page"

    Effect.browserReload! sessionId |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Maximize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.maximizeWindow! |> try
## ```
maximizeWindow! : Browser => Result WindowRect [WebDriverError Str]
maximizeWindow! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Maximizing browser window"

    Effect.browserMaximize! sessionId
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr WebDriverError

## Minimize the `Browser` window.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.minimizeWindow! |> try
## ```
minimizeWindow! : Browser => Result WindowRect [WebDriverError Str]
minimizeWindow! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Minimizing browser window"

    Effect.browserMinimize! sessionId
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr WebDriverError

## Make the `Browser` window full screen.
##
## Can fail when the system does not support this operation.
##
## ```
## newRect = browser |> Browser.fullScreenWindow! |> try
## ```
fullScreenWindow! : Browser => Result WindowRect [WebDriverError Str]
fullScreenWindow! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Making browser window full screen"

    Effect.browserFullScreen! sessionId
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.toU32, height: heightVal |> Num.toU32 }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr WebDriverError

## Execute JavaScript in the `Browser`.
##
## ```
## browser |> Browser.executeJs! "console.log('wow')" |> try
## ```
executeJs! : Browser, Str => Result {} [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJs! = \browser, script ->
    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    _output : Str
    _output = ExecuteJs.executeJs! browser script |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

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
##  response = browser |> Browser.executeJsWithOutput! "return 50 + 5;" |> try
##  response |> Assert.shouldBe 55
##
##  response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;" |> try
##  response |> Assert.shouldBe 55.5
##
##  response = browser |> Browser.executeJsWithOutput! "return 50.5 + 5;" |> try
##  response |> Assert.shouldBe "55.5"
##
##  response = browser |> Browser.executeJsWithOutput! "return true" |> try
##  response |> Assert.shouldBe "true"
##
##  response = browser |> Browser.executeJsWithOutput! "return true" |> try
##  response |> Assert.shouldBe Bool.true
## ```
##
## The function can return a `Promise`.
executeJsWithOutput! : Browser, Str => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJsWithOutput! = \browser, script ->
    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    result = ExecuteJs.executeJs! browser script |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok result

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
##  response = browser |> Browser.executeJsWithArgs! "return 50 + 5;" [] |> try
##  response |> Assert.shouldBe 55
##
##  response = browser |> Browser.executeJsWithArgs! "return 50.5 + 5;" [Number 55.5, String "5"] |> try
##  response |> Assert.shouldBe 55.5
## ```
##
## The function can return a `Promise`.
executeJsWithArgs! : Browser, Str, List JsValue => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJsWithArgs! = \browser, script, arguments ->
    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Executing JavaScript in the browser"

    result = ExecuteJs.executeJsWithArgs! browser script arguments |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok result

# COOKIES
NewCookie : {
    name : Str,
    value : Str,
    domain ? Str,
    path ? Str,
    sameSite ? SameSiteOption,
    secure ? Bool,
    httpOnly ? Bool,
    expiry ? CookieExpiry,
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
## CookieExpiry : [Session, MaxAge U32]
##
## SameSiteOption : [None, Lax, Strict]
## ```
Cookie : {
    name : Str,
    value : Str,
    domain : Str,
    path : Str,
    sameSite : SameSiteOption,
    secure : Bool,
    httpOnly : Bool,
    expiry : CookieExpiry,
}

CookieExpiry : [Session, MaxAge U32]

SameSiteOption : [None, Lax, Strict]

sameSiteOptionToStr : SameSiteOption -> Str
sameSiteOptionToStr = \option ->
    when option is
        None -> "None"
        Lax -> "Lax"
        Strict -> "Strict"

sameSiteStrToOption = \str ->
    when str is
        "None" -> None
        "Lax" -> Lax
        "Strict" -> Strict
        # TODO - hmm
        _ -> None

boolToInt = \bool ->
    if bool then 1 else 0

## Add a cookie in the `Browser`.
##
## ```
## browser |> Browser.addCookie! { name: "myCookie", value: "value1" } |> try
## ```
## ```
## browser |> Browser.addCookie! {
##     name: "myCookie",
##     value: "value1",
##     domain: "my-top-level-domain.com",
##     path: "/path",
##     sameSite: Lax,
##     secure: Bool.true,
##     httpOnly: Bool.true,
##     expiry: MaxAge 2865848396, # unix epoch
## } |> try
## ```
addCookie! : Browser, NewCookie => Result {} [WebDriverError Str]
addCookie! = \browser, { name, value, domain ? "", path ? "", sameSite ? None, secure ? Bool.false, httpOnly ? Bool.false, expiry ? Session } ->
    { sessionId } = Internal.unpackBrowserData browser

    sameSiteStr = sameSite |> sameSiteOptionToStr
    secureInt = secure |> boolToInt
    httpOnlyInt = httpOnly |> boolToInt
    expiryI64 =
        when expiry is
            Session -> -1
            MaxAge n -> n |> Num.toI64

    Effect.addCookie! sessionId name value domain path sameSiteStr httpOnlyInt secureInt expiryI64
    |> Result.mapErr WebDriverError

## Delete a cookie in the `Browser` by name.
##
## ```
## browser |> Browser.deleteCookie! "myCookieName" |> try
## ```
deleteCookie! : Browser, Str => Result {} [WebDriverError Str, CookieNotFound Str]
deleteCookie! = \browser, name ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.deleteCookie! sessionId name |> Result.mapErr InternalError.handleCookieError

## Delete all cookies in the `Browser`.
##
## ```
## browser |> Browser.deleteAllCookies! |> try
## ```
deleteAllCookies! : Browser => Result {} [WebDriverError Str]
deleteAllCookies! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.deleteAllCookies! sessionId |> Result.mapErr WebDriverError

## Get a cookie from the `Browser` by name.
##
## ```
## cookie1 = browser |> Browser.getCookie! "myCookie" |> try
## cookie1 |> Assert.shouldBe {
##     name: "myCookie",
##     value: "value1",
##     domain: ".my-domain.io",
##     path: "/",
##     sameSite: Lax,
##     expiry: Session,
##     secure: Bool.true,
##     httpOnly: Bool.false,
## }
## ```
getCookie! : Browser, Str => Result Cookie [WebDriverError Str, CookieNotFound Str]
getCookie! = \browser, cookieName ->
    { sessionId } = Internal.unpackBrowserData browser

    cookieArray = Effect.getCookie! sessionId cookieName |> Result.mapErr InternalError.handleCookieError |> try
    cookieArray |> cookieArrayToRocCookie

## Get all cookies from the `Browser`.
##
## ```
## cookies = browser |> Browser.getAllCookies! |> try
## cookies |> List.len |> Assert.shouldBe 3
## ```
getAllCookies! : Browser => Result (List Cookie) [WebDriverError Str, CookieNotFound Str]
getAllCookies! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    cookies = Effect.getAllCookies! sessionId |> Result.mapErr InternalError.handleCookieError |> try
    rocCookies =
        cookies
        |> List.map cookieArrayToRocCookie # TODO - right now I'm ignoring errors
        |> List.keepOks \e -> e

    rocCookies |> Ok

cookieArrayToRocCookie : List Str -> Result Cookie [WebDriverError Str]
cookieArrayToRocCookie = \cookieArray ->
    when cookieArray is
        [name, value, domain, path, httpOnlyStr, secureStr, sameSiteStr, expiryStr] ->
            httpOnly = if httpOnlyStr == "true" then Bool.true else Bool.false
            secure = if secureStr == "true" then Bool.true else Bool.false
            sameSite = sameSiteStr |> sameSiteStrToOption
            expiry =
                expiryStr
                |> expiryStrToRoc
                |> Result.mapErr \_ -> WebDriverError "could not parse cookie: probabably a bug in R2E"
                |> try
            Ok { name, value, domain, path, expiry, httpOnly, sameSite, secure }

        _ -> Err (WebDriverError "could not parse cookie: probably a bug in R2E")

expiryStrToRoc = \expStr ->
    if expStr |> Str.isEmpty then
        Session |> Ok
    else
        u32 = expStr |> Str.toU32 |> try
        u32 |> MaxAge |> Ok

## Get alert/prompt text.
##
## ```
## text = browser |> Browser.getAlertText! |> try
## text |> Assert.shouldBe "Are you sure to close tab?"
## ```
getAlertText! : Browser => Result Str [WebDriverError Str, AlertNotFound Str]
getAlertText! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting alert text"

    Effect.alertGetText! sessionId |> Result.mapErr InternalError.handleAlertError

## Input text in prompt.
##
## ```
## browser |> Browser.sendTextToAlert! "my reply" |> try
## browser |> Browser.acceptAlert! |> try
## ```
sendTextToAlert! : Browser, Str => Result {} [WebDriverError Str, AlertNotFound Str]
sendTextToAlert! = \browser, text ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Sending text to an alert: \"$(text)\""

    Effect.alertSendText! sessionId text |> Result.mapErr InternalError.handleAlertError

## Accept alert/prompt.
##
## ```
## browser |> Browser.acceptAlert! |> try
## ```
acceptAlert! : Browser => Result {} [WebDriverError Str, AlertNotFound Str]
acceptAlert! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Accepting an alert"

    Effect.alertAccept! sessionId |> Result.mapErr InternalError.handleAlertError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Dismiss alert/prompt.
##
## ```
## browser |> Browser.dismissAlert! |> try
## ```
dismissAlert! : Browser => Result {} [WebDriverError Str, AlertNotFound Str]
dismissAlert! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Dismissing an alert"

    Effect.alertDismiss! sessionId |> Result.mapErr InternalError.handleAlertError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.wait! {}

    Ok {}

## Get the serialized DOM as HTML `Str`.
##
## ```
## html = browser |> Browser.getPageHtml! |> try
## html |> Assert.shouldContainText "<h1>Header</h1>"
## ```
getPageHtml! : Browser => Result Str [WebDriverError Str]
getPageHtml! = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting page HTML"

    Effect.getPageSource! sessionId |> Result.mapErr WebDriverError
