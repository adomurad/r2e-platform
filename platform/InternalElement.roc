module [getText, getProperty, isVisible]

import Internal exposing [Element]
import InternalError
import Effect
import PropertyDecoder

getText : Element -> Task Str [WebDriverError Str, ElementNotFound Str]
getText = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementGetText sessionId elementId |> Task.mapErr InternalError.handleElementError

getProperty : Internal.Element, Str -> Task a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getProperty = \element, propertyName ->
    { sessionId, elementId } = Internal.unpackElementData element

    resultStr = Effect.elementGetProperty sessionId elementId propertyName |> Task.mapErr! InternalError.handleElementError
    resultUtf8 = resultStr |> Str.toUtf8

    decoded : Result a _
    decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

    when decoded is
        Ok val -> Task.ok val
        Err _ -> Task.err (PropertyTypeError "could not cast property \"$(propertyName)\" with value \"$(resultStr)\" to expected type")

isVisible : Element -> Task [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
isVisible = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    result = Effect.elementIsDisplayed sessionId elementId |> Task.mapErr! InternalError.handleElementError

    if result == "true" then
        Task.ok Visible
    else
        Task.ok NotVisible
