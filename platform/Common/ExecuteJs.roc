module [execute_js!, execute_js_with_args!, JsValue]

import Internal exposing [Browser]
import Effect
import PropertyDecoder
import EncodeDecode

JsValue : [String Str, Number F64, Boolean Bool, Null]

execute_js! : Browser, Str => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
execute_js! = |browser, script|
    { session_id } = Internal.unpack_browser_data(browser)

    result_str = Effect.execute_js!(session_id, script, "[]") |> Result.map_err(|err| WebDriverError(err))?
    result_utf8 = result_str |> Str.to_utf8

    decoded : Result a _
    decoded = Decode.from_bytes(result_utf8, PropertyDecoder.utf8)

    when decoded is
        Ok(val) -> Ok(val)
        Err(_) -> Err(JsReturnTypeError("unsupported return type from js: \"${result_str}\""))

execute_js_with_args! : Browser, Str, List JsValue => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
execute_js_with_args! = |browser, script, arguments|
    { session_id } = Internal.unpack_browser_data(browser)

    arguments_str = arguments |> js_arguments_to_str

    result_str = Effect.execute_js!(session_id, script, arguments_str) |> Result.map_err(WebDriverError)?
    result_utf8 = result_str |> Str.to_utf8

    decoded : Result a _
    decoded = Decode.from_bytes(result_utf8, PropertyDecoder.utf8)

    when decoded is
        Ok(val) -> Ok(val)
        Err(_) -> Err(JsReturnTypeError("unsupported return type from js: \"${result_str}\""))

js_arguments_to_str : List JsValue -> Str
js_arguments_to_str = |args|
    args_str =
        args
        |> List.walk(
            "",
            |state, arg|
                when arg is
                    String(str) ->
                        escaped_str = EncodeDecode.encode_json_string(str)
                        state |> Str.concat(",${escaped_str}")

                    Number(num) -> state |> Str.concat(",${num |> Num.to_str}")
                    Null -> state |> Str.concat(",null")
                    Boolean(bool) ->
                        if bool then
                            state |> Str.concat(",true")
                        else
                            state |> Str.concat(",false"),
        )

    "[${args_str |> Str.drop_prefix(",")}]"

expect
    input = []
    expected = "[]"
    output = js_arguments_to_str(input)
    output == expected

expect
    input = [String("wow"), Number(78.2), Number(0), Boolean(Bool.true), Boolean(Bool.false), Null]
    expected = "[\"wow\",78.2,0,true,false,null]"
    output = js_arguments_to_str(input)
    output == expected
