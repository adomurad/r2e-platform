## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    click,
    getText,
    getValue,
    inputText,
    clear,
    isSelected,
    isVisible,
    getProperty,
    getAttribute,
    getAttributeOrEmpty,
    getPropertyOrEmpty,
    getTagName,
    getCssProperty,
    Locator,
    findElement,
    findElements,
    findSingleElement,
    tryFindElement,
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
## button = browser |> Browser.findElement! (Css "#submit-button")
## # click the button
## button |> Element.click!
## ```
click : Element -> Task {} [WebDriverError Str, ElementNotFound Str]
click = \element ->
    { sessionId, elementId, locator, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Trying to click element: $(selectorText)"

    Effect.elementClick sessionId elementId |> Task.mapErr! InternalError.handleElementError

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element clicked: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Click Element $(selectorText)"
        DebugMode.flashElements! sessionId locator Single
        DebugMode.wait!

## Get text of the `Element`.
##
## This function will return the displayed text in the `Browser` for this `Element` and it's children.
##
## When the `Element` is not visible, then the text will be an empty `Str`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonText = button |> Element.getText!
## ```
getText : Element -> Task Str [WebDriverError Str, ElementNotFound Str]
getText = \element ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting element text: $(selectorText)"

    InternalElement.getText element

## Get **value** of the `Element`.
##
## When there is no **value** in this element then returns the default value for used type:
## - `Str` - ""
## - `Bool` - Bool.false
## - `Num` - 0
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input value
## inputValue = input |> Element.getValue!
## inputValue |> Assert.shouldBe "my-email@fake-email.com"
## ```
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#age-input")
## # get input value
## inputValue = input |> Element.getValue!
## inputValue |> Assert.shouldBe 18
## ```
getValue : Element -> Task.Task a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getValue = \element ->
    getProperty element "value"

## Check if `Element` is selected.
##
## Can be used on checkbox inputs, radio inputs, and option elements.
##
## ```
## # find checkbox element
## checkbox = browser |> Browser.findElement! (Css "#is-tasty-checkbox")
## # get button text
## isTastyState = checkbox |> Element.isSelected!
## # asert expected value
## isTastyState |> Assert.shoulBe! Selected
## ```
isSelected : Element -> Task [Selected, NotSelected] [WebDriverError Str, ElementNotFound Str]
isSelected = \element ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Checking if element is slected: $(selectorText)"

    result = Effect.elementIsSelected sessionId elementId |> Task.mapErr! InternalError.handleElementError

    if result == "true" then
        Task.ok Selected
    else
        Task.ok NotSelected

## Check if `Element` is visible in the `Browser`.
##
## ```
## # find error message element
## errorMsg = browser |> Browser.findElement! (Css "#error-msg")
## # get button text
## isVisible = checkbox |> Element.isVisible!
## # assert expected value
## isVisible |> Assert.shoulBe! Visible
## ```
isVisible : Element -> Task [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
isVisible = \element ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Checking if element is visible: $(selectorText)"

    InternalElement.isVisible element

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## When the **attribute** is not present on the `Element`, this function will return empty `Str`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input type
## inputType = input |> Element.getAttribute! "type"
## ```
getAttribute : Element, Str -> Task Str [WebDriverError Str, ElementNotFound Str]
getAttribute = \element, attributeName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting attribute \"$(attributeName)\" for element: $(selectorText)"

    result = Effect.elementGetAttribute sessionId elementId attributeName |> Task.mapErr! InternalError.handleElementError
    result

## Get **attribute** of an `Element`.
##
## **Attributes** are values you can see in the HTML DOM, like *<input class"test" type="password" />*
##
## ```
## checkboxType = checkbox |> Element.getAttributeOrEmpty! "type"
## when checkboxType is
##     Ok type -> type |> Assert.shouldBe "checkbox"
##     Err Empty -> Assert.failWith "should not be empty"
## ```
getAttributeOrEmpty : Element, Str -> Task (Result Str [Empty]) [WebDriverError Str, ElementNotFound Str]
getAttributeOrEmpty = \element, attributeName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting attribute \"$(attributeName)\" for element: $(selectorText)"

    result = Effect.elementGetAttribute sessionId elementId attributeName |> Task.mapErr! InternalError.handleElementError

    if result == "" then
        Task.ok (Err Empty)
    else
        Task.ok (Ok result)

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
## inputValue = input |> Element.getProperty! "value"
## # expect to have value "email@emails.com"
## inputValue |> Assert.shouldBe "email@emails.com"
## ```
##
## Bool:
## ```
## isChecked = nameInput |> Element.getProperty! "checked"
## isChecked |> Assert.shouldBe Bool.false
## ```
##
## Bool as Str:
## ```
## isChecked = nameInput |> Element.getProperty! "checked"
## isChecked |> Assert.shouldBe "false"
## ```
##
## Num:
## ```
## clientHeight = nameInput |> Element.getProperty! "clientHeight"
## clientHeight |> Assert.shouldBe 17
## ```
getProperty : Internal.Element, Str -> Task a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getProperty = \element, propertyName ->
    { selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting property \"$(propertyName)\" for element: $(selectorText)"

    InternalElement.getProperty element propertyName

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
## inputValue = input |> Element.getPropertyOrEmpty! "value"
## # expect to have value "email@emails.com"
## inputType |> Assert.shouldBe (Ok "email@emails.com")
## ```
##
## ```
## isChecked = nameInput |> Element.getProperty! "checked"
## when isChecked is
##     Ok value -> value |> Assert.shouldBe Bool.false
##     Err Empty -> Assert.failWith "input should have a checked prop"
## ```
##
## ```
## clientHeight = nameInput |> Element.getProperty! "clientHeight"
## clientHeight |> Assert.shouldBe (Ok 17)
## ```
getPropertyOrEmpty : Element, Str -> Task (Result a [Empty]) [WebDriverError Str, ElementNotFound Str, PropertyTypeError Str] where a implements Decoding
getPropertyOrEmpty = \element, propertyName ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting property \"$(propertyName)\" for element: $(selectorText)"

    resultStr = Effect.elementGetProperty sessionId elementId propertyName |> Task.mapErr! InternalError.handleElementError

    if resultStr == "" then
        Task.ok (Err Empty)
    else
        resultUtf8 = resultStr |> Str.toUtf8

        decoded : Result a _
        decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

        when decoded is
            Ok val -> Task.ok (Ok val)
            Err _ -> Task.err (PropertyTypeError "could not cast property \"$(propertyName)\" with value \"$(resultStr)\" to expected type")

## Send a `Str` to a `Element` (e.g. put text into an input).
##
## ```
## # find email input element
## emailInput = browser |> Browser.findElement! (Css "#email")
## # input an email into the email input
## emailInput |> Element.sendKeys! "my.fake.email@fake-email.com"
## ```
##
## Special key sequences:
##
## `{enter}` - simulates an "enter" key press
##
## ```
## # find search input element
## searchInput = browser |> Browser.findElement! (Css "#search")
## # input text and submit
## searchInput |> Element.sendKeys! "roc lang{enter}"
## ```
inputText : Element, Str -> Task.Task {} [WebDriverError Str, ElementNotFound Str]
inputText = \element, str ->
    { sessionId, elementId, selectorText, locator } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Sending text \"$(str)\" to element: $(selectorText)"

    Effect.elementSendKeys sessionId elementId str
        |> Task.mapErr! InternalError.handleElementError

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element received text: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Send Text $(selectorText)"
        DebugMode.flashElements! sessionId locator Single
        DebugMode.wait!

## Clear an editable or resetable `Element`.
##
## ```
## # find button element
## input = browser |> Browser.findElement! (Css "#email-input")
## # click the button
## input |> Element.clear!
## ```
clear : Internal.Element -> Task.Task {} [WebDriverError Str, ElementNotFound Str]
clear = \element ->
    { sessionId, elementId, selectorText, locator } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Clearing element: $(selectorText)"

    Effect.elementClear sessionId elementId |> Task.mapErr! InternalError.handleElementError

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Element cleared: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Clear Element $(selectorText)"
        DebugMode.flashElements! sessionId locator Single
        DebugMode.wait!

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
## button = element |> Element.findElement! (Css "#my-id")
## ```
##
## ```
## # find the html element with a css selector ".my-class"
## button = element |> Element.findElement! (Css ".my-class")
## ```
##
## ```
## # find the html element with an attribute [data-testid="my-element"]
## button = element |> Element.findElement! (TestId "my-element")
## ```
findElement : Element, Locator -> Task Element [WebDriverError Str, ElementNotFound Str]
findElement = \element, locator ->
    { sessionId, elementId } = Internal.unpackElementData element
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for element: $(selectorText)"

    newElementId = Effect.elementFindElement sessionId elementId using value |> Task.mapErr! InternalError.handleElementError

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Found element: $(selectorText)"

    DebugMode.runIfDebugMode! \{} ->
        DebugMode.showDebugMessageInBrowser! sessionId "Find Element $(selectorText)"
        DebugMode.flashElements! sessionId locator Single
        DebugMode.wait!

    Internal.packElementData { sessionId, elementId: newElementId, selectorText, locator } |> Task.ok

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
## maybeButton = element |> Element.tryFindElement! (Css "#submit-button")
##
## when maybeButton is
##     NotFound -> Stdout.line! "Button not found"
##     Found el ->
##         buttonText = el |> Element.getText!
##         Stdout.line! "Button found with text: $(buttonText)"
## ```
tryFindElement : Element, Locator -> Task [Found Element, NotFound] [WebDriverError Str, ElementNotFound Str]
tryFindElement = \element, locator ->
    findElement element locator
    |> Task.map Found
    |> Task.onErr \err ->
        when err is
            ElementNotFound _ -> Task.ok NotFound
            other -> Task.err other

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
## button = element |> Element.findSingleElement! (Css "#submit-button")
## ```
findSingleElement : Element, Locator -> Task Element [AssertionError Str, ElementNotFound Str, WebDriverError Str]
findSingleElement = \element, locator ->
    { selectorText: parentElementSelectorText } = Internal.unpackElementData element
    elements = findElements! element locator
    when elements |> List.len is
        0 ->
            (_, value) = Locator.getLocator locator
            Task.err (ElementNotFound "element with selector $(value) was not found in element $(parentElementSelectorText)")

        1 ->
            elements
            |> List.first
            |> Result.onErr \_ -> crash "just checked - there is 1 element in the list"
            |> Task.fromResult

        n ->
            (_, value) = Locator.getLocator locator
            Task.err (AssertionError "expected to find only 1 element with selector \"$(value)\", but found $(n |> Num.toStr)")

## Find all `Elements` inside the tree of another `Element` in the `Browser`.
##
## When there are no elements found, then the list will be empty.
##
## See supported locators at `Locator`.
##
## ```
## # find all <li> elements in #my-list in the DOM tree of **element**
## listItems = element |> Element.findElements! (Css "#my-list li")
## ```
##
findElements : Element, Locator -> Task (List Element) [WebDriverError Str, ElementNotFound Str]
findElements = \element, locator ->
    { sessionId, elementId: parentElementId } = Internal.unpackElementData element
    (using, value) = Locator.getLocator locator

    selectorText = "$(locator |> Inspect.toStr)"

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Searching for elements: $(selectorText)"

    result = Effect.elementFindElements sessionId parentElementId using value |> Task.mapErr InternalError.handleElementError |> Task.result!

    when result is
        Ok elementIds ->
            DebugMode.runIfVerbose! \{} ->
                Debug.printLine! "Found $(elementIds |> List.len |> Num.toStr) elements: $(selectorText)"

            DebugMode.runIfDebugMode! \{} ->
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

## Get the HTML tag name of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input tag name
## tagName = input |> Element.getTagName!
## # tag name should be "input"
## tagName |> Assert.shouldBe "input"
## ```
getTagName : Element -> Task Str [WebDriverError Str, ElementNotFound Str]
getTagName = \element ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting tag name for element: $(selectorText)"

    Effect.elementGetTag sessionId elementId |> Task.mapErr InternalError.handleElementError

## Get a **css property** of an `Element`.
##
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input type
## inputBorder = input |> Element.getCssProperty! "border"
## # assert
## inputBorder |> Assert.shouldBe "2px solid rgb(0, 0, 0)"
## ```
getCssProperty : Element, Str -> Task Str [WebDriverError Str, ElementNotFound Str]
getCssProperty = \element, cssProperty ->
    { sessionId, elementId, selectorText } = Internal.unpackElementData element

    DebugMode.runIfVerbose! \{} ->
        Debug.printLine! "Getting CSS property \"$(cssProperty)\" for element: $(selectorText)"

    Effect.elementGetCss sessionId elementId cssProperty |> Task.mapErr InternalError.handleElementError
