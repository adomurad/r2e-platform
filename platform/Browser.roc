## `Browser` module contains function to interact with the `Browser`.
module [navigateTo, findElement, getScreenshotBase64, Locator]

import Effect
import Internal exposing [Browser, Element]

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

## Supported locator strategies
##
## `Css Str` - e.g. Css ".my-button-class"
##
## `TestId Str` - e.g. TestId "button" => Css "[data-testid=\"button\"]"
##
## `XPath Str` - e.g. XPath "/bookstore/book[price>35]/price"
##
Locator : [
    Css Str,
    TestId Str,
    XPath Str,
]

getLocator : Locator -> (Str, Str)
getLocator = \locator ->
    when locator is
        Css cssSelector -> ("css selector", cssSelector)
        # TODO - script injection
        TestId id -> ("css selector", "[data-testid=\"$(id)\"]")
        # LinkTextSelector text -> ("link text", text)
        # PartialLinkTextSelector text -> ("partial link text", text)
        # Tag tag -> ("tag name", tag)
        XPath path -> ("xpath", path)

## Find a `Element` in the `Browser`.
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

    Internal.packElementData { sessionId, elementId } |> Task.ok

handleFindElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e

## Take a screenshot of the whole document.
##
## The result will be a **base64** encoded `Str` representation of a PNG file.
##
## ```
## base64PngStr = browser |> Browser.getScreenshotBase64!
## ```
getScreenshotBase64 : Browser -> Task Str [WebDriverError Str]
getScreenshotBase64 = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.getScreenshot sessionId |> Task.mapErr WebDriverError
