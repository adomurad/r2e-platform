module [getText!, getProperty!, isVisible!]

import Internal exposing [Element]
import InternalError
import Effect
import PropertyDecoder

getText! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
getText! = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementGetText! sessionId elementId |> Result.mapErr InternalError.handleElementError

getProperty! : Internal.Element, Str => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
getProperty! = \element, propertyName ->
    { sessionId, elementId } = Internal.unpackElementData element

    resultStr = Effect.elementGetProperty! sessionId elementId propertyName |> Result.mapErr? InternalError.handleElementError
    resultUtf8 = resultStr |> Str.toUtf8

    decoded : Result a _
    decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

    when decoded is
        Ok val -> Ok val
        Err _ -> Err (PropertyTypeError "could not cast property \"$(propertyName)\" with value \"$(resultStr)\" to expected type")

isVisible! : Element => Result [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
isVisible! = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    result = Effect.elementIsDisplayed! sessionId elementId |> Result.mapErr? InternalError.handleElementError

    if result == "true" then
        Ok Visible
    else
        Ok NotVisible
