## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    click!,
    getText!,
    getValue!,
    inputText!,
    clear!,
    isSelected!,
    isVisible!,
    getProperty!,
    getAttribute!,
    getAttributeOrEmpty!,
    getPropertyOrEmpty!,
    getTagName!,
    getCssProperty!,
    getRect!,
    Locator,
    findElement!,
    findElements!,
    findSingleElement!,
    tryFindElement!,
    useIFrame!,
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
## button = browser |> Browser.findElement! (Css "#submit-button") |> try
## # click the button
## button |> Element.click! |> try
## ```
click! : Element => Result {} [WebDriverError Str, ElementNotFound Str]
click! = \element ->
    { sessionId, elementId, locator, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Trying to click element: $(selectorText)"

    Effect.elementClick! sessionId elementId |> Result.mapErr InternalError.handleElementError |> try

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element clicked: $(selectorText)"
    #
    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Click Element $(selectorText)" |> try
        DebugMode.flashElements! sessionId locator Single |> try
        DebugMode.wait! {}
        Ok {}

    Ok {}

## Get text of the `Element`.
##
## This function will return the displayed text in the `Browser` for this `Element` and it's children.
##
## When the `Element` is not visible, then the text will be an empty `Str`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button") |> try
## # get button text
## buttonText = button |> Element.getText! |> try
## ```
getText! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
getText! = \element ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting element text: $(selectorText)"

    InternalElement.getText! element

## Get **value** of the `Element`.
##
## When there is no **value** in this element then returns the default value for used type:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # get input value
## inputValue = input |> Element.getValue! |> try
## inputValue |> Assert.shouldBe "my-email@fake-email.com"
## ```
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#age-input") |> try
## # get input value
## inputValue = input |> Element.getValue! |> try
## inputValue |> Assert.shouldBe 18
## ```
getValue! : Element => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getValue! = \element ->
    getProperty! element "value"

## Check if `Element` is selected.
##
## Can be used on checkbox inputs, radio inputs, and option elements.
##
## ```
## # find checkbox element
## checkbox = browser |> Browser.findElement! (Css "#is-tasty-checkbox") |> try
## # get button text
## isTastyState = checkbox |> Element.isSelected! |> try
## # asert expected value
## isTastyState |> Assert.shoulBe Selected
## ```
isSelected! : Element => Result [Selected, NotSelected] [WebDriverError Str, ElementNotFound Str]
isSelected! = \element ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Checking if element is slected: $(selectorText)"

    result = Effect.elementIsSelected! sessionId elementId |> Result.mapErr InternalError.handleElementError |> try

    if result == "true" then
        Ok Selected
    else
        Ok NotSelected

## Check if `Element` is visible in the `Browser`.
##
## ```
## # find error message element
## errorMsg = browser |> Browser.findElement! (Css "#error-msg") |> try
## # get button text
## isVisible = checkbox |> Element.isVisible! |> try
## # assert expected value
## isVisible |> Assert.shoulBe Visible
## ```
isVisible! : Element => Result [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
isVisible! = \element ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Checking if element is visible: $(selectorText)"

    InternalElement.isVisible! element

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## When the **attribute** is not present on the `Element`, this function will return empty `Str`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # get input type
## inputType = input |> Element.getAttribute! "type" |> try
## ```
getAttribute! : Element, Str => Result Str [WebDriverError Str, ElementNotFound Str]
getAttribute! = \element, attributeName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting attribute \"$(attributeName)\" for element: $(selectorText)"

    Effect.elementGetAttribute! sessionId elementId attributeName |> Result.mapErr InternalError.handleElementError

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## ```
## checkboxType = checkbox |> Element.getAttributeOrEmpty! "type" |> try
## when checkboxType is
##     Ok type -> type |> Assert.shouldBe "checkbox"
##     Err Empty -> Assert.failWith "should not be empty"
## ```
getAttributeOrEmpty! : Element, Str => Result (Result Str [Empty]) [WebDriverError Str, ElementNotFound Str]
getAttributeOrEmpty! = \element, attributeName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting attribute \"$(attributeName)\" for element: $(selectorText)"

    result = Effect.elementGetAttribute! sessionId elementId attributeName |> Result.mapErr InternalError.handleElementError |> try

    if result == "" then
        Ok (Err Empty)
    else
        Ok (Ok result)

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
## inputValue = input |> Element.getProperty! "value" |> try
## # expect to have value "email@emails.com"
## inputValue |> Assert.shouldBe "email@emails.com"
## ```
##
## Bool:
## ```
## isChecked = nameInput |> Element.getProperty! "checked" |> try
## isChecked |> Assert.shouldBe Bool.false
## ```
##
## Bool as Str:
## ```
## isChecked = nameInput |> Element.getProperty! "checked" |> try
## isChecked |> Assert.shouldBe "false"
## ```
##
## Num:
## ```
## clientHeight = nameInput |> Element.getProperty! "clientHeight" |> try
## clientHeight |> Assert.shouldBe 17
## ```
getProperty! : Internal.Element, Str => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getProperty! = \element, propertyName ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting property \"$(propertyName)\" for element: $(selectorText)"

    InternalElement.getProperty! element propertyName

## Get **property** of an `Element`.
##
## **Properties** are the keys that you get when using `GetOwnProperty` on a element in the browser.
##
## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
## R2E will try to cast the browser response to the choosen type.
##
## When the response is empty e.g. property does not exist, then `Err Empty` will be returned.
##
## ```
## # get input value
## inputValue = input |> Element.getPropertyOrEmpty! "value" |> try
## # expect to have value "email@emails.com"
## inputType |> Assert.shouldBe (Ok "email@emails.com")
## ```
##
## ```
## isChecked = nameInput |> Element.getProperty! "checked" |> try
## when isChecked is
##     Ok value -> value |> Assert.shouldBe Bool.false
##     Err Empty -> Assert.failWith "input should have a checked prop"
## ```
##
## ```
## clientHeight = nameInput |> Element.getProperty! "clientHeight" |> try
## clientHeight |> Assert.shouldBe (Ok 17)
## ```
getPropertyOrEmpty! : Element, Str => Result (Result a [Empty]) [WebDriverError Str, ElementNotFound Str, PropertyTypeError Str] where a implements Decoding
getPropertyOrEmpty! = \element, propertyName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting property \"$(propertyName)\" for element: $(selectorText)"

    resultStr = Effect.elementGetProperty! sessionId elementId propertyName |> Result.mapErr InternalError.handleElementError |> try

    if resultStr == "" then
        Ok (Err Empty)
    else
        resultUtf8 = resultStr |> Str.toUtf8

        decoded : Result a _
        decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

        when decoded is
            Ok val -> Ok (Ok val)
            Err _ -> Err (PropertyTypeError "could not cast property \"$(propertyName)\" with value \"$(resultStr)\" to expected type")

## Send a `Str` to a `Element` (e.g. put text into an input).
##
## ```
## # find email input element
## emailInput = browser |> Browser.findElement! (Css "#email") |> try
## # input an email into the email input
## emailInput |> Element.sendKeys! "my.fake.email@fake-email.com" |> try
## ```
##
## Special key sequences:
##
## `{enter}` - simulates an "enter" key press
##
## ```
## # find search input element
## searchInput = browser |> Browser.findElement! (Css "#search") |> try
## # input text and submit
## searchInput |> Element.sendKeys! "roc lang{enter}" |> try
## ```
inputText! : Element, Str => Result {} [WebDriverError Str, ElementNotFound Str]
inputText! = \element, str ->
    { sessionId, elementId, selectorText, locator } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Sending text \"$(str)\" to element: $(selectorText)"

    Effect.elementSendKeys! sessionId elementId str
    |> Result.mapErr InternalError.handleElementError
    |> try

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element received text: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Send Text $(selectorText)" |> try
        DebugMode.flashElements! sessionId locator Single |> try
        DebugMode.wait! {}
        Ok {}

    Ok {}

## Clear an editable or resetable `Element`.
##
## ```
## # find button element
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # click the button
## input |> Element.clear! |> try
## ```
clear! : Internal.Element => Result {} [WebDriverError Str, ElementNotFound Str]
clear! = \element ->
    { sessionId, elementId, selectorText, locator } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Clearing element: $(selectorText)"

    Effect.elementClear! sessionId elementId |> Result.mapErr InternalError.handleElementError |> try

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element cleared: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Clear Element $(selectorText)" |> try
        DebugMode.flashElements! sessionId locator Single |> try
        DebugMode.wait! {}
        Ok {}

    Ok {}

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

## Find an `Element` inside the tree of another `Element` in the `Browser`.
##
## When there are more than 1 elements, then the first will
## be returned.
##
## See supported locators at `Locator`.
##
## ```
## # find the html element with a css selector "#my-id"
## button = element |> Element.findElement! (Css "#my-id") |> try
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = element |> Element.findElement! (Css ".my-class") |> try
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = element |> Element.findElement! (TestId "my-element") |> try
## ```
findElement! : Element, Locator => Result Element [WebDriverError Str, ElementNotFound Str]
findElement! = \element, locator ->
    { sessionId, elementId } = Internal.unpackElementData element
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for element: $(selectorText)"

    newElementId = Effect.elementFindElement! sessionId elementId using value |> Result.mapErr InternalError.handleElementError |> try

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Found element: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Find Element $(selectorText)" |> try
        DebugMode.flashElements! sessionId locator Single |> try
        DebugMode.wait! {}
        Ok {}

    Internal.packElementData { sessionId, elementId: newElementId, selectorText, locator } |> Ok

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
## maybeButton = element |> Element.tryFindElement! (Css "#submit-button") |> try
##
## when maybeButton is
##     NotFound -> Stdout.line! "Button not found"
##     Found el ->
##         buttonText = el |> Element.getText! |> try
##         Stdout.line! "Button found with text: $(buttonText)"
## ```
tryFindElement! : Element, Locator => Result [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
tryFindElement! = \element, locator ->
    findElement! element locator
    |> Result.map Found
    |> Result.onErr \err ->
        when err is
            ElementNotFound _ -> Ok NotFound
            other -> Err other

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
## button = element |> Element.findSingleElement! (Css "#submit-button") |> try
## ```
findSingleElement! : Element, Locator => Result Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
findSingleElement! = \element, locator ->
    { selectorText: parentElementSelectorText } = Internal.unpackElementData element
    elements = findElements! element locator |> try
    when elements |> List.len is
        0 ->
            (_, value) = Locator.getLocator locator
            Err (ElementNotFound "element with selector $(value) was not found in element $(parentElementSelectorText)")

        1 ->
            elements
            |> List.first
            |> Result.onErr \_ -> crash "just checked - there is 1 element in the list"

        n ->
            (_, value) = Locator.getLocator locator
            Err (AssertionError "expected to find only 1 element with selector \"$(value)\", but found $(n |> Num.toStr)")

## Find all `Elements` inside the tree of another `Element` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list in the DOM tree of **element**
## listItems = element |> Element.findElements! (Css "#my-list li") |> try
## ```
##
findElements! : Element, Locator => Result (List Element) [WebDriverError Str, ElementNotFound Str]
findElements! = \element, locator ->
    { sessionId, elementId: parentElementId } = Internal.unpackElementData element
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for elements: $(selectorText)"

    result = Effect.elementFindElements! sessionId parentElementId using value |> Result.mapErr InternalError.handleElementError

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

## Get the HTML tag name of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # get input tag name
## tagName = input |> Element.getTagName! |> try
## # tag name should be "input"
## tagName |> Assert.shouldBe "input"
## ```
getTagName! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
getTagName! = \element ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting tag name for element: $(selectorText)"

    Effect.elementGetTag! sessionId elementId |> Result.mapErr InternalError.handleElementError

## Get a **css property** of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # get input type
## inputBorder = input |> Element.getCssProperty! "border" |> try
## # assert
## inputBorder |> Assert.shouldBe "2px solid rgb(0, 0, 0)"
## ```
getCssProperty! : Element, Str => Result Str [WebDriverError Str, ElementNotFound Str]
getCssProperty! = \element, cssProperty ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting CSS property \"$(cssProperty)\" for element: $(selectorText)"

    Effect.elementGetCss! sessionId elementId cssProperty |> Result.mapErr InternalError.handleElementError

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
## input = browser |> Browser.findElement! (Css "#email-input") |> try
## # get input tag name
## rect = input |> Element.getRect! |> try
## # assert the rect
## rect.height |> Assert.shouldBe 51 |> try
## rect.width |> Assert.shouldBe 139 |> try
## rect.x |> Assert.shouldBeEqualTo 226.1243566 |> try
## rect.y |> Assert.shouldBeEqualTo 218.3593754
## ```
getRect! : Element => Result ElementRect [WebDriverError Str, ElementNotFound Str]
getRect! = \element ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting the rect for element: $(selectorText)"

    Effect.elementGetRect! sessionId elementId
    |> Result.map \list ->
        when list is
            [xVal, yVal, widthVal, heightVal] -> { x: xVal, y: yVal, width: widthVal |> Num.round, height: heightVal |> Num.round }
            _ -> crash "the contract with host should not fail"
    |> Result.mapErr InternalError.handleElementError

## Switch the context to an iFrame.
##
## This function runs a callback in which you can interact
## with the page inside an iFrame.
##
## ```
## frameEl = browser |> Browser.findElement! (Css "iframe") |> try
##
## Element.useIFrame! frameEl \frame ->
##     span = frame |> Browser.findElement! (Css "#span-inside-frame") |> try
##     span |> Assert.elementShouldHaveText! "This is inside an iFrame" |> try
## ```
useIFrame! : Element, (Internal.Browser => Result {} _) => Result {} _
useIFrame! = \element, callback! ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Switching context to iFrame: $(selectorText)"

    Effect.switchToFrameByElementId! sessionId elementId |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Switched to iFrame $(selectorText)" |> try
        DebugMode.flashCurrentFrame! sessionId |> try
        DebugMode.wait! {}
        Ok {}

    browser = Internal.packBrowserData { sessionId }
    result = callback! browser

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Switching back to iFrame parent"

    Effect.switchToParentFrame! sessionId |> Result.mapErr WebDriverError |> try

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Switched back to iFrame parent" |> try
        DebugMode.flashCurrentFrame! sessionId |> try
        DebugMode.wait! {}
        Ok {}

    result
