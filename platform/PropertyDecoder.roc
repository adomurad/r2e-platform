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
            u8: decode_u8,
            u16: decode_u16,
            u32: decode_u32,
            u64: decode_u64,
            u128: decode_u128,
            i8: decode_i8,
            i16: decode_i16,
            i32: decode_i32,
            i64: decode_i64,
            i128: decode_i128,
            f32: decode_f32,
            f64: decode_f64,
            dec: decode_dec,
            bool: decode_bool,
            string: decode_string,
            list: decode_list,
            record: decode_record,
            tuple: decode_tuple,
        },
    ]

utf8 = @ElementProperty({})

decode_u8 = Decode.custom(
    |bytes, @ElementProperty({})|
        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_u8)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of U8
expect
    actual = Str.to_utf8("255") |> Decode.from_bytes(utf8)
    actual == Ok(255u8)

# Test decode of U8 for empty string
expect
    actual = Str.to_utf8("") |> Decode.from_bytes(utf8)
    actual == Ok(0u8)

decode_u16 = Decode.custom(
    |bytes, @ElementProperty({})|
        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_u16)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of U16
expect
    actual = Str.to_utf8("65535") |> Decode.from_bytes(utf8)
    actual == Ok(65_535u16)

# Test decode of U16 for empty string
expect
    actual = Str.to_utf8("") |> Decode.from_bytes(utf8)
    actual == Ok(0u16)

decode_u32 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_u32)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of U32
expect
    actual = Str.to_utf8("4000000000") |> Decode.from_bytes(utf8)
    actual == Ok(4_000_000_000u32)

decode_u64 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_u64)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of U64
expect
    actual = Str.to_utf8("18446744073709551614") |> Decode.from_bytes(utf8)
    actual == Ok(18_446_744_073_709_551_614u64)

decode_u128 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_u128)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of U128
expect
    actual = Str.to_utf8("1234567") |> Decode.from_bytes_partial(utf8)
    actual.result == Ok(1234567u128)

decode_i8 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_i8)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of I8
expect
    actual = Str.to_utf8("-125") |> Decode.from_bytes_partial(utf8)
    actual.result == Ok(-125i8)

decode_i16 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_i16)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of I16
expect
    actual = Str.to_utf8("-32768") |> Decode.from_bytes_partial(utf8)
    actual.result == Ok(-32_768i16)

decode_i32 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_i32)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of I32
expect
    actual = Str.to_utf8("-2147483648") |> Decode.from_bytes_partial(utf8)
    actual.result == Ok(-2_147_483_648i32)

decode_i64 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_i64)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of I64
expect
    actual = Str.to_utf8("-9223372036854775808") |> Decode.from_bytes_partial(utf8)
    actual.result == Ok(-9_223_372_036_854_775_808i64)

decode_i128 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_i128)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

decode_f32 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_f32)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of F32
expect
    actual : DecodeResult F32
    actual = Str.to_utf8("12.34e-5") |> Decode.from_bytes_partial(utf8)
    num_str = actual.result |> Result.map_ok(Num.to_str)

    Result.with_default(num_str, "") == "0.0001234"

decode_f64 = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_f64)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of F64
expect
    actual : DecodeResult F64
    actual = Str.to_utf8("12.34e-5") |> Decode.from_bytes_partial(utf8)
    num_str = actual.result |> Result.map_ok(Num.to_str)

    Result.with_default(num_str, "") == "0.0001234"

decode_dec = Decode.custom(
    |bytes, @ElementProperty({})|

        if bytes |> List.is_empty then
            { result: Ok(0), rest: [] }
        else
            result =
                bytes
                |> Str.from_utf8
                |> Result.try(Str.to_dec)
                |> Result.map_err(|_| TooShort)

            { result, rest: [] },
)

# Test decode of Dec
expect
    actual : DecodeResult Dec
    actual = Str.to_utf8("12.0034") |> Decode.from_bytes_partial(utf8)

    actual.result == Ok(12.0034dec)

decode_bool = Decode.custom(
    |bytes, @ElementProperty({})|
        when bytes is
            [] -> { result: Ok(Bool.false), rest: [] }
            ['f', 'a', 'l', 's', 'e'] -> { result: Ok(Bool.false), rest: [] }
            ['t', 'r', 'u', 'e'] -> { result: Ok(Bool.true), rest: [] }
            _ -> { result: Err(TooShort), rest: bytes },
)

# Test decode of Bool
expect
    actual = "true" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(Bool.true)
    actual.result == expected

# Test decode of Bool
expect
    actual = "false" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(Bool.false)
    actual.result == expected

# Test decode of Bool when empty string
expect
    actual = "" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(Bool.false)
    actual.result == expected

decode_tuple : state, (state, U64 -> [Next (Decoder state ElementProperty), TooLong]), (state -> [Err DecodeError, Ok val]) -> Decoder val ElementProperty
decode_tuple = |_initialState, _stepElem, _finalizer|
    Decode.custom(
        |initial_bytes, _jsonFmt|
            { result: Err(TooShort), rest: initial_bytes },
    )

expect
    actual = "0.0" |> Str.to_utf8 |> Decode.from_bytes(utf8)
    expected = Ok(0.0dec)
    actual == expected

expect
    actual = "0" |> Str.to_utf8 |> Decode.from_bytes(utf8)
    expected = Ok(0u8)
    actual == expected

expect
    actual : DecodeResult U64
    actual = "-.1" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    actual.result == Err(TooShort)

expect
    actual : DecodeResult Dec
    actual = "72" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(72dec)
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-0" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(0dec)
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-7" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(-7dec)
    actual.result == expected

expect
    actual : DecodeResult Dec
    actual = "-0" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = { result: Ok(0dec), rest: [] }
    actual == expected

expect
    actual : DecodeResult Dec
    actual = "123456789000" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = { result: Ok(123456789000dec), rest: [] }
    actual == expected

expect
    actual : DecodeResult Dec
    actual = "-12.03" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Ok(-12.03)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-12." |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "01.1" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = ".0" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "1.e1" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-1.2E" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "0.1e+" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

expect
    actual : DecodeResult U64
    actual = "-03" |> Str.to_utf8 |> Decode.from_bytes_partial(utf8)
    expected = Err(TooShort)
    actual.result == expected

decode_string = Decode.custom(
    |bytes, @ElementProperty({})|

        # { taken: strBytes, rest } = takeJsonString bytes
        str_bytes = bytes

        # if List.isEmpty strBytes then
        #     { result: Err TooShort, rest: bytes }
        # else
        result = str_bytes |> Str.from_utf8

        when result is
            Ok(str) ->
                { result: Ok(str), rest: [] }

            Err(_) ->
                { result: Err(TooShort), rest: bytes },
)

# Test decode simple string
expect
    input = "hello" |> Str.to_utf8
    actual = Decode.from_bytes_partial(input, utf8)
    expected = Ok("hello")

    actual.result == expected

# Test decode simple empty string
expect
    input = "" |> Str.to_utf8
    actual = Decode.from_bytes_partial(input, utf8)
    expected = Ok("")

    actual.result == expected

# Test decode simple string with quotes
expect
    input = "\"hello\", " |> Str.to_utf8
    actual = Decode.from_bytes_partial(input, utf8)
    expected = Ok("\"hello\", ")

    actual.result == expected

# JSON ARRAYS ------------------------------------------------------------------

decode_list : Decoder elem ElementProperty -> Decoder (List elem) ElementProperty
decode_list = |_elemDecoder|
    Decode.custom(
        |bytes, _jsonFmt|
            { result: Err(TooShort), rest: bytes },
    )

# JSON OBJECTS -----------------------------------------------------------------
decode_record : state, (state, Str -> [Keep (Decoder state ElementProperty), Skip]), (state, ElementProperty -> [Err DecodeError, Ok val]) -> Decoder val ElementProperty
decode_record = |_initialState, _stepField, _finalizer|
    Decode.custom(
        |bytes, @ElementProperty({})|

            { result: Err(TooShort), rest: bytes },
    )
