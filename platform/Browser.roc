## `Browser` module contains function to interact with the `Browser`.
module [
    navigateTo,
    findElement,
    tryFindElement,
    findSingleElement,
    findElements,
    getScreenshotBase64,
    Locator,
]

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
## `LinkText Str` - e.g. LinkText "Examples" in <a href="/examples-page">Examples</a>
##
## `PartialLinkText Str` - e.g. PartialLinkText "Exam" in <a href="/examples-page">Examples</a>
##
Locator : [
    Css Str,
    TestId Str,
    XPath Str,
    LinkText Str,
    PartialLinkText Str,
]

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

## Find a `Element` in the `Browser`.
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

## Find a `Element` in the `Browser`.
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

    when result is
        Ok elementIds ->
            elementIds
            |> List.map \elementId ->
                Internal.packElementData { sessionId, elementId }
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
## base64PngStr = browser |> Browser.getScreenshotBase64!
## ```
getScreenshotBase64 : Browser -> Task Str [WebDriverError Str]
getScreenshotBase64 = \browser ->
    { sessionId } = Internal.unpackBrowserData browser

    Effect.getScreenshot sessionId |> Task.mapErr WebDriverError
