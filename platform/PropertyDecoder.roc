# The implementation is based on https://github.com/lukewilliamboswell/roc-json
# this decoder decodes only strings, numbers and booleans
# it should never fail to decode a string
module [
    ElementProperty,
    utf8,
]

ElementProperty := {}
    implements [
        DecoderFormatting {
            u8: decodeU8,
            u16: decodeU16,
            u32: decodeU32,
            u64: decodeU64,
            u128: decodeU128,
            i8: decodeI8,
            i16: decodeI16,
            i32: decodeI32,
            i64: decodeI64,
            i128: decodeI128,
            f32: decodeF32,
            f64: decodeF64,
            dec: decodeDec,
            bool: decodeBool,
            string: decodeString,
            list: decodeList,
            record: decodeRecord,
            tuple: decodeTuple,
        },
    ]

utf8 = @ElementProperty {}

decodeU8 = Decode.custom \bytes, @ElementProperty {} ->
    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toU8
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of U8
expect
    actual = Str.toUtf8 "255" |> Decode.fromBytes utf8
    actual == Ok 255u8

# Test decode of U8 for empty string
expect
    actual = Str.toUtf8 "" |> Decode.fromBytes utf8
    actual == Ok 0u8

decodeU16 = Decode.custom \bytes, @ElementProperty {} ->
    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toU16
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of U16
expect
    actual = Str.toUtf8 "65535" |> Decode.fromBytes utf8
    actual == Ok 65_535u16

# Test decode of U16 for empty string
expect
    actual = Str.toUtf8 "" |> Decode.fromBytes utf8
    actual == Ok 0u16

decodeU32 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toU32
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of U32
expect
    actual = Str.toUtf8 "4000000000" |> Decode.fromBytes utf8
    actual == Ok 4_000_000_000u32

decodeU64 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toU64
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of U64
expect
    actual = Str.toUtf8 "18446744073709551614" |> Decode.fromBytes utf8
    actual == Ok 18_446_744_073_709_551_614u64

decodeU128 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toU128
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of U128
expect
    actual = Str.toUtf8 "1234567" |> Decode.fromBytesPartial utf8
    actual.result == Ok 1234567u128

decodeI8 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toI8
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of I8
expect
    actual = Str.toUtf8 "-125" |> Decode.fromBytesPartial utf8
    actual.result == Ok -125i8

decodeI16 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toI16
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of I16
expect
    actual = Str.toUtf8 "-32768" |> Decode.fromBytesPartial utf8
    actual.result == Ok -32_768i16

decodeI32 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toI32
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of I32
expect
    actual = Str.toUtf8 "-2147483648" |> Decode.fromBytesPartial utf8
    actual.result == Ok -2_147_483_648i32

decodeI64 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toI64
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of I64
expect
    actual = Str.toUtf8 "-9223372036854775808" |> Decode.fromBytesPartial utf8
    actual.result == Ok -9_223_372_036_854_775_808i64

decodeI128 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toI128
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

decodeF32 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toF32
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of F32
expect
    actual : DecodeResult F32
    actual = Str.toUtf8 "12.34e-5" |> Decode.fromBytesPartial utf8
    numStr = actual.result |> Result.map Num.toStr

    Result.withDefault numStr "" == "0.00012339999375399202"

decodeF64 = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toF64
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of F64
expect
    actual : DecodeResult F64
    actual = Str.toUtf8 "12.34e-5" |> Decode.fromBytesPartial utf8
    numStr = actual.result |> Result.map Num.toStr

    Result.withDefault numStr "" == "0.0001234"

decodeDec = Decode.custom \bytes, @ElementProperty {} ->

    if bytes |> List.isEmpty then
        { result: Ok 0, rest: [] }
    else
        result =
            bytes
            |> Str.fromUtf8
            |> Result.try Str.toDec
            |> Result.mapErr \_ -> TooShort

        { result, rest: [] }

# Test decode of Dec
expect
    actual : DecodeResult Dec
    actual = Str.toUtf8 "12.0034" |> Decode.fromBytesPartial utf8

    actual.result == Ok 12.0034dec

decodeBool = Decode.custom \bytes, @ElementProperty {} ->
    when bytes is
        [] -> { result: Ok Bool.false, rest: [] }
        ['f', 'a', 'l', 's', 'e'] -> { result: Ok Bool.false, rest: [] }
        ['t', 'r', 'u', 'e'] -> { result: Ok Bool.true, rest: [] }
        _ -> { result: Err TooShort, rest: bytes }

# Test decode of Bool
expect
    actual = "true" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok Bool.true
    actual.result == expected

# Test decode of Bool
expect
    actual = "false" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok Bool.false
    actual.result == expected

# Test decode of Bool when empty string
expect
    actual = "" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok Bool.false
    actual.result == expected

decodeTuple : state, (state, U64 -> [Next (Decoder state ElementProperty), TooLong]), (state -> [Err DecodeError, Ok val]) -> Decoder val ElementProperty
decodeTuple = \_initialState, _stepElem, _finalizer -> Decode.custom \initialBytes, _jsonFmt ->
        { result: Err TooShort, rest: initialBytes }

expect
    actual = "0.0" |> Str.toUtf8 |> Decode.fromBytes utf8
    expected = Ok 0.0dec
    actual == expected

expect
    actual = "0" |> Str.toUtf8 |> Decode.fromBytes utf8
    expected = Ok 0u8
    actual == expected

expect
    actual : DecodeResult U64
    actual = "-.1" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    actual.result == Err TooShort

expect
    actual : DecodeResult Dec
    actual = "72" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok 72dec
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-0" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok 0dec
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-7" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok -7dec
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-0" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = { result: Ok 0dec, rest: [] }
    actual == expected

expect
    actual : DecodeResult Dec
    actual = "123456789000" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = { result: Ok 123456789000dec, rest: [] }
    actual == expected

expect
    actual : DecodeResult Dec
    actual = "-12.03" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok -12.03
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-12." |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "01.1" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = ".0" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "1.e1" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-1.2E" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "0.1e+" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-03" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Err TooShort
    actual.result == expected

decodeString = Decode.custom \bytes, @ElementProperty {} ->

    # { taken: strBytes, rest } = takeJsonString bytes
    strBytes = bytes

    # if List.isEmpty strBytes then
    #     { result: Err TooShort, rest: bytes }
    # else
    result = strBytes |> Str.fromUtf8

    when result is
        Ok str ->
            { result: Ok str, rest: [] }

        Err _ ->
            { result: Err TooShort, rest: bytes }

# Test decode simple string
expect
    input = "hello" |> Str.toUtf8
    actual = Decode.fromBytesPartial input utf8
    expected = Ok "hello"

    actual.result == expected

# Test decode simple empty string
expect
    input = "" |> Str.toUtf8
    actual = Decode.fromBytesPartial input utf8
    expected = Ok ""

    actual.result == expected

# Test decode simple string with quotes
expect
    input = "\"hello\", " |> Str.toUtf8
    actual = Decode.fromBytesPartial input utf8
    expected = Ok "\"hello\", "

    actual.result == expected

# JSON ARRAYS ------------------------------------------------------------------

decodeList : Decoder elem ElementProperty -> Decoder (List elem) ElementProperty
decodeList = \_elemDecoder -> Decode.custom \bytes, _jsonFmt ->
        { result: Err TooShort, rest: bytes }

# JSON OBJECTS -----------------------------------------------------------------
decodeRecord : state, (state, Str -> [Keep (Decoder state ElementProperty), Skip]), (state, ElementProperty -> [Err DecodeError, Ok val]) -> Decoder val ElementProperty
decodeRecord = \_initialState, _stepField, _finalizer -> Decode.custom \bytes, @ElementProperty {} ->

        { result: Err TooShort, rest: bytes }
