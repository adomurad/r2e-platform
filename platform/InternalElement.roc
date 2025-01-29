module [get_text!, get_property!, is_visible!]

import Internal exposing [Element]
import InternalError
import Effect
import PropertyDecoder

get_text! : Element => Result Str [WebDriverError Str, ElementNotFound Str]
get_text! = |element|
    { session_id, element_id } = Internal.unpack_element_data(element)

    Effect.element_get_text!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)

get_property! : Internal.Element, Str => Result a [ElementNotFound Str, PropertyTypeError Str, WebDriverError Str] where a implements Decoding
get_property! = |element, property_name|
    { session_id, element_id } = Internal.unpack_element_data(element)

    result_str = Effect.element_get_property!(session_id, element_id, property_name) |> Result.map_err(InternalError.handle_element_error)?
    result_utf8 = result_str |> Str.to_utf8

    decoded : Result a _
    decoded = Decode.from_bytes(result_utf8, PropertyDecoder.utf8)

    when decoded is
        Ok(val) -> Ok(val)
        Err(_) -> Err(PropertyTypeError("could not cast property \"${property_name}\" with value \"${result_str}\" to expected type"))

is_visible! : Element => Result [Visible, NotVisible] [WebDriverError Str, ElementNotFound Str]
is_visible! = |element|
    { session_id, element_id } = Internal.unpack_element_data(element)

    result = Effect.element_is_displayed!(session_id, element_id) |> Result.map_err(InternalError.handle_element_error)?

    if result == "true" then
        Ok(Visible)
    else
        Ok(NotVisible)
