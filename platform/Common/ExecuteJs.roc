module [executeJs!, executeJsWithArgs!, JsValue]

import Internal exposing [Browser]
import Effect
import PropertyDecoder
import EncodeDecode

JsValue : [String Str, Number F64, Boolean Bool, Null]

executeJs! : Browser, Str => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJs! = \browser, script ->
    { sessionId } = Internal.unpackBrowserData browser

    resultStr = Effect.executeJs! sessionId script "[]" |> Result.mapErr? \err -> WebDriverError err
    resultUtf8 = resultStr |> Str.toUtf8

    decoded : Result a _
    decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

    when decoded is
        Ok val -> Ok val
        Err _ -> Err (JsReturnTypeError "unsupported return type from js: \"$(resultStr)\"")

executeJsWithArgs! : Browser, Str, List JsValue => Result a [WebDriverError Str, JsReturnTypeError Str] where a implements Decoding
executeJsWithArgs! = \browser, script, arguments ->
    { sessionId } = Internal.unpackBrowserData browser

    argumentsStr = arguments |> jsArgumentsToStr

    resultStr = Effect.executeJs! sessionId script argumentsStr |> Result.mapErr? WebDriverError
    resultUtf8 = resultStr |> Str.toUtf8

    decoded : Result a _
    decoded = Decode.fromBytes resultUtf8 PropertyDecoder.utf8

    when decoded is
        Ok val -> Ok val
        Err _ -> Err (JsReturnTypeError "unsupported return type from js: \"$(resultStr)\"")

jsArgumentsToStr : List JsValue -> Str
jsArgumentsToStr = \args ->
    argsStr =
        args
        |> List.walk "" \state, arg ->
            when arg is
                String str ->
                    escapedStr = EncodeDecode.encodeJsonString str
                    state |> Str.concat ",$(escapedStr)"

                Number num -> state |> Str.concat ",$(num |> Num.toStr)"
                Null -> state |> Str.concat ",null"
                Boolean bool ->
                    if bool then
                        state |> Str.concat ",true"
                    else
                        state |> Str.concat ",false"

    "[$(argsStr |> Str.dropPrefix ",")]"

expect
    input = []
    expected = "[]"
    output = jsArgumentsToStr input
    output == expected

expect
    input = [String "wow", Number 78.2, Number 0, Boolean Bool.true, Boolean Bool.false, Null]
    expected = "[\"wow\",78.2,0,true,false,null]"
    output = jsArgumentsToStr input
    output == expected
