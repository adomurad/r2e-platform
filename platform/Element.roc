## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [click, getText, isSelected, getProperty, getAttribute]

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
## ```
## # find input element
## input = browser |> Browser.findElement! (Css "#email-input")
## # get input type
## inputType = input |> Element.getAttribute! "type"
## ```
getAttribute : Element, Str -> Task (Result Str [Empty]) [WebDriverError Str, ElementNotFound Str]
getAttribute = \element, attributeName ->
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
## This function can be used with types like: `Bool`, `I64`, `Str`, and `F64`.
## Depending of what property is being used.
##
## ```
## # get input value
## inputValue = input |> Element.getAttribute! "value"
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
getProperty : Element, Str -> Task (Result a [Empty]) [WebDriverError Str, ElementNotFound Str, PropertyTypeError Str] where a implements Decoding
getProperty = \element, propertyName ->
    { sessionId, elementId } = Internal.unpackElementData element

    resultStr = Effect.elementGetProperty sessionId elementId propertyName |> Task.mapErr! handleElementError

    resTypeTask =
        when resultStr |> Str.toUtf8 is
            [] -> Task.ok Empty
            ['b', 'o', 'o', 'l', ':', .. as rest] -> Task.ok (BoolType rest)
            ['s', 't', 'r', 'i', 'n', 'g', ':', .. as rest] -> Task.ok (StringType rest)
            ['f', 'l', 'o', 'a', 't', '6', '4', ':', .. as rest] -> Task.ok (FloatType rest)
            ['i', 'n', 't', '6', '4', ':', .. as rest] -> Task.ok (IntType rest)
            _ -> Task.err (WebDriverError "received unsupported type for property \"$(propertyName)\" with value: $(resultStr)")

    resType = resTypeTask!

    when resType is
        Empty -> Task.ok (Err Empty)
        BoolType bytes ->
            decodeJsonProp bytes propertyName "Bool"

        StringType bytes ->
            decodeJsonProp bytes propertyName "Str"

        FloatType bytes ->
            decodeJsonProp bytes propertyName "F64"

        IntType bytes ->
            decodeJsonProp bytes propertyName "I64"

decodeJsonProp : List U8, Str, Str -> Task (Result a []) [PropertyTypeError Str] where a implements Decoding
decodeJsonProp = \bytes, propName, typeStr ->

    # decoder = Json.utf8With {}
    decoder = PropertyDecoder.utf8

    decoded : Decode.DecodeResult a
    decoded = Decode.fromBytesPartial bytes decoder
    # decoded = Decode.fromBytesPartial bytes PropertyDecoder.utf8With {}

    when decoded.result is
        Ok val -> Task.ok (Ok val)
        Err _ ->
            # cannot fail
            valueStr = bytes |> Str.fromUtf8 |> Result.withDefault ""
            Task.err (PropertyTypeError "property \"$(propName)\" returned \"$(valueStr)\" of type $(typeStr) instead of expected type")

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e
