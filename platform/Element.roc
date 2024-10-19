## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [
    click,
    getText,
    getValue,
    inputText,
    isSelected,
    getProperty,
    getAttribute,
    getAttributeOrEmpty,
    getPropertyOrEmpty,
]

import Internal exposing [Element]
import PropertyDecoder
import Console
import Effect
# import json.Json

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
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementClick sessionId elementId |> Task.mapErr! handleElementError

## Get text of the `Element`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # get button text
## buttonText = button |> Element.getText!
## ```
getText : Element -> Task Str [WebDriverError Str, ElementNotFound Str]
getText = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementGetText sessionId elementId |> Task.mapErr handleElementError

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
    { sessionId, elementId } = Internal.unpackElementData element

    result = Effect.elementIsSelected sessionId elementId |> Task.mapErr! handleElementError

    if result == "true" then
        Task.ok Selected
    else
        Task.ok NotSelected

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
    { sessionId, elementId } = Internal.unpackElementData element

    result = Effect.elementGetAttribute sessionId elementId attributeName |> Task.mapErr! handleElementError
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
    { sessionId, elementId } = Internal.unpackElementData element

    result = Effect.elementGetAttribute sessionId elementId attributeName |> Task.mapErr! handleElementError

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
    { sessionId, elementId } = Internal.unpackElementData element

    resultStr = Effect.elementGetProperty sessionId elementId propertyName |> Task.mapErr! handleElementError
    resultUtf8 = resultStr |> Str.toUtf8

    decoded : Result a _
    decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

    when decoded is
        Ok val -> Task.ok val
        Err _ -> Task.err (PropertyTypeError "could not cast property \"$(propertyName)\" with value \"$(resultStr)\" to expected type")

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
    { sessionId, elementId } = Internal.unpackElementData element

    resultStr = Effect.elementGetProperty sessionId elementId propertyName |> Task.mapErr! handleElementError

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
    { sessionId, elementId } = Internal.unpackElementData element
    Effect.elementSendKeys sessionId elementId str
    |> Task.mapErr handleElementError

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e
