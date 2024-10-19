module [
    Json,
    utf8,
]

Json := {}
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

utf8 = @Json {}

decodeU8 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toU8
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of U8
expect
    actual = Str.toUtf8 "255" |> Decode.fromBytes utf8
    actual == Ok 255u8

decodeU16 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toU16
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of U16
expect
    actual = Str.toUtf8 "65535" |> Decode.fromBytes utf8
    actual == Ok 65_535u16

decodeU32 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toU32
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of U32
expect
    actual = Str.toUtf8 "4000000000" |> Decode.fromBytes utf8
    actual == Ok 4_000_000_000u32

decodeU64 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toU64
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of U64
expect
    actual = Str.toUtf8 "18446744073709551614" |> Decode.fromBytes utf8
    actual == Ok 18_446_744_073_709_551_614u64

decodeU128 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toU128
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of U128
expect
    actual = Str.toUtf8 "1234567" |> Decode.fromBytesPartial utf8
    actual.result == Ok 1234567u128

decodeI8 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toI8
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of I8
expect
    actual = Str.toUtf8 "-125" |> Decode.fromBytesPartial utf8
    actual.result == Ok -125i8

decodeI16 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toI16
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of I16
expect
    actual = Str.toUtf8 "-32768" |> Decode.fromBytesPartial utf8
    actual.result == Ok -32_768i16

decodeI32 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toI32
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of I32
expect
    actual = Str.toUtf8 "-2147483648" |> Decode.fromBytesPartial utf8
    actual.result == Ok -2_147_483_648i32

decodeI64 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toI64
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of I64
expect
    actual = Str.toUtf8 "-9223372036854775808" |> Decode.fromBytesPartial utf8
    actual.result == Ok -9_223_372_036_854_775_808i64

decodeI128 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toI128
        |> Result.mapErr \_ -> TooShort

    { result, rest }

decodeF32 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toF32
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of F32
expect
    actual : DecodeResult F32
    actual = Str.toUtf8 "12.34e-5" |> Decode.fromBytesPartial utf8
    numStr = actual.result |> Result.map Num.toStr

    Result.withDefault numStr "" == "0.00012339999375399202"

decodeF64 = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toF64
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of F64
expect
    actual : DecodeResult F64
    actual = Str.toUtf8 "12.34e-5" |> Decode.fromBytesPartial utf8
    numStr = actual.result |> Result.map Num.toStr

    Result.withDefault numStr "" == "0.0001234"

decodeDec = Decode.custom \bytes, @Json {} ->
    { taken, rest } = takeJsonNumber bytes

    result =
        taken
        |> Str.fromUtf8
        |> Result.try Str.toDec
        |> Result.mapErr \_ -> TooShort

    { result, rest }

# Test decode of Dec
expect
    actual : DecodeResult Dec
    actual = Str.toUtf8 "12.0034" |> Decode.fromBytesPartial utf8

    actual.result == Ok 12.0034dec

decodeBool = Decode.custom \bytes, @Json {} ->
    when bytes is
        ['f', 'a', 'l', 's', 'e', ..] -> { result: Ok Bool.false, rest: List.dropFirst bytes 5 }
        ['t', 'r', 'u', 'e', ..] -> { result: Ok Bool.true, rest: List.dropFirst bytes 4 }
        _ -> { result: Err TooShort, rest: bytes }

# Test decode of Bool
expect
    actual = "true\n" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok Bool.true
    actual.result == expected

# Test decode of Bool
expect
    actual = "false ]\n" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = Ok Bool.false
    actual.result == expected

decodeTuple : state, (state, U64 -> [Next (Decoder state Json), TooLong]), (state -> [Err DecodeError, Ok val]) -> Decoder val Json
decodeTuple = \_initialState, _stepElem, _finalizer -> Decode.custom \initialBytes, _jsonFmt ->
        { result: Err TooShort, rest: initialBytes }

# Test decode of tuple
expect
    input = Str.toUtf8 "[\"The Answer is\",42]"
    actual = Decode.fromBytesPartial input utf8

    actual.result == Ok ("The Answer is", 42)

# Test decode with whitespace
expect
    input = Str.toUtf8 "[ 123,\t456\n]"
    actual = Decode.fromBytesPartial input utf8
    expected = Ok (123, 456)

    actual.result == expected

takeJsonNumber : List U8 -> { taken : List U8, rest : List U8 }
takeJsonNumber = \bytes ->
    when List.walkUntil bytes Start numberHelp is
        Finish n | Zero n | Integer n | FractionB n | ExponentC n ->
            taken =
                bytes
                |> List.sublist { start: 0, len: n }
                |> List.dropIf \b -> b == '+'
                |> List.map \b -> if b == 'E' then 'e' else b

            { taken, rest: List.dropFirst bytes n }

        _ ->
            { taken: [], rest: bytes }

numberHelp : NumberState, U8 -> [Continue NumberState, Break NumberState]
numberHelp = \state, byte ->
    when (state, byte) is
        (Start, b) if b == '0' -> Continue (Zero 1)
        (Start, b) if b == '-' -> Continue (Minus 1)
        (Start, b) if isDigit1to9 b -> Continue (Integer 1)
        (Minus n, b) if b == '0' -> Continue (Zero (n + 1))
        (Minus n, b) if isDigit1to9 b -> Continue (Integer (n + 1))
        (Zero n, b) if b == '.' -> Continue (FractionA (n + 1))
        (Zero n, b) if isValidEnd b -> Break (Finish n)
        (Integer n, b) if isDigit0to9 b && n <= maxBytes -> Continue (Integer (n + 1))
        (Integer n, b) if b == '.' && n < maxBytes -> Continue (FractionA (n + 1))
        (Integer n, b) if isValidEnd b && n <= maxBytes -> Break (Finish n)
        (FractionA n, b) if isDigit0to9 b && n <= maxBytes -> Continue (FractionB (n + 1))
        (FractionB n, b) if isDigit0to9 b && n <= maxBytes -> Continue (FractionB (n + 1))
        (FractionB n, b) if b == 'e' || b == 'E' && n <= maxBytes -> Continue (ExponentA (n + 1))
        (FractionB n, b) if isValidEnd b && n <= maxBytes -> Break (Finish n)
        (ExponentA n, b) if b == '-' || b == '+' && n <= maxBytes -> Continue (ExponentB (n + 1))
        (ExponentA n, b) if isDigit0to9 b && n <= maxBytes -> Continue (ExponentC (n + 1))
        (ExponentB n, b) if isDigit0to9 b && n <= maxBytes -> Continue (ExponentC (n + 1))
        (ExponentC n, b) if isDigit0to9 b && n <= maxBytes -> Continue (ExponentC (n + 1))
        (ExponentC n, b) if isValidEnd b && n <= maxBytes -> Break (Finish n)
        _ -> Break Invalid

NumberState : [
    Start,
    Minus U64,
    Zero U64,
    Integer U64,
    FractionA U64,
    FractionB U64,
    ExponentA U64,
    ExponentB U64,
    ExponentC U64,
    Invalid,
    Finish U64,
]

# TODO confirm if we would like to be able to decode
# "340282366920938463463374607431768211455" which is MAX U128 and 39 bytes
maxBytes : U64
maxBytes = 21 # Max bytes in a double precision float

isDigit0to9 : U8 -> Bool
isDigit0to9 = \b -> b >= '0' && b <= '9'

isDigit1to9 : U8 -> Bool
isDigit1to9 = \b -> b >= '1' && b <= '9'

isValidEnd : U8 -> Bool
isValidEnd = \b ->
    when b is
        ']' | ',' | ' ' | '\n' | '\r' | '\t' | '}' -> Bool.true
        _ -> Bool.false

expect
    actual = "0.0" |> Str.toUtf8 |> Decode.fromBytes utf8
    expected = Ok 0.0dec
    actual == expected

expect
    actual = "0" |> Str.toUtf8 |> Decode.fromBytes utf8
    expected = Ok 0u8
    actual == expected

# expect
#     actual = "1 " |> Str.toUtf8 |> Decode.fromBytesPartial utf8
#     expected = { result: Ok 1dec, rest: [' '] }
#     actual == expected
#
# expect
#     actual = "2]" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
#     expected = { result: Ok 2u64, rest: [']'] }
#     actual == expected
#
# expect
#     actual = "30,\n" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
#     expected = { result: Ok 30i64, rest: [',', '\n'] }
#     actual == expected
#
# expect
#     actual : DecodeResult U16
#     actual = "+1" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
#     expected = { result: Err TooShort, rest: ['+', '1'] }
#     actual == expected
#
# expect
#     actual : DecodeResult U16
#     actual = ".0" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
#     expected = { result: Err TooShort, rest: ['.', '0'] }
#     actual == expected

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
    actual = "-0\n" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = { result: Ok 0dec, rest: ['\n'] }
    actual == expected

expect
    actual : DecodeResult Dec
    actual = "123456789000 \n" |> Str.toUtf8 |> Decode.fromBytesPartial utf8
    expected = { result: Ok 123456789000dec, rest: [' ', '\n'] }
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

decodeString = Decode.custom \bytes, @Json {} ->

    { taken: strBytes, rest } = takeJsonString bytes

    if List.isEmpty strBytes then
        { result: Err TooShort, rest: bytes }
    else
        # Remove starting and ending quotation marks, replace unicode
        # escpapes with Roc equivalent, and try to parse RocStr from
        # bytes
        result =
            strBytes
            |> List.sublist {
                start: 1,
                len: Num.subSaturated (List.len strBytes) 2,
            }
            |> \bytesWithoutQuotationMarks ->
                replaceEscapedChars { inBytes: bytesWithoutQuotationMarks, outBytes: [] }
            |> .outBytes
            |> Str.fromUtf8

        when result is
            Ok str ->
                { result: Ok str, rest }

            Err _ ->
                { result: Err TooShort, rest: bytes }

takeJsonString : List U8 -> { taken : List U8, rest : List U8 }
takeJsonString = \bytes ->
    when List.walkUntil bytes Start stringHelp is
        Finish n ->
            {
                taken: List.sublist bytes { start: 0, len: n },
                rest: List.dropFirst bytes n,
            }

        _ ->
            { taken: [], rest: bytes }

stringHelp : StringState, U8 -> [Continue StringState, Break StringState]
stringHelp = \state, byte ->
    when (state, byte) is
        (Start, b) if b == '"' -> Continue (Chars 1)
        (Chars n, b) if b == '"' -> Break (Finish (n + 1))
        (Chars n, b) if b == '\\' -> Continue (Escaped (n + 1))
        (Chars n, _) -> Continue (Chars (n + 1))
        (Escaped n, b) if isEscapedChar b -> Continue (Chars (n + 1))
        (Escaped n, b) if b == 'u' -> Continue (UnicodeA (n + 1))
        (UnicodeA n, b) if isHex b -> Continue (UnicodeB (n + 1))
        (UnicodeB n, b) if isHex b -> Continue (UnicodeC (n + 1))
        (UnicodeC n, b) if isHex b -> Continue (UnicodeD (n + 1))
        (UnicodeD n, b) if isHex b -> Continue (Chars (n + 1))
        _ -> Break (InvalidNumber)

StringState : [
    Start,
    Chars U64,
    Escaped U64,
    UnicodeA U64,
    UnicodeB U64,
    UnicodeC U64,
    UnicodeD U64,
    Finish U64,
    InvalidNumber,
]

isEscapedChar : U8 -> Bool
isEscapedChar = \b ->
    when b is
        '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' -> Bool.true
        _ -> Bool.false

escapedCharFromJson : U8 -> U8
escapedCharFromJson = \b ->
    when b is
        '"' -> 0x22 # U+0022 Quotation mark
        '\\' -> 0x5c # U+005c Reverse solidus
        '/' -> 0x2f # U+002f Solidus
        'b' -> 0x08 # U+0008 Backspace
        'f' -> 0x0c # U+000c Form feed
        'n' -> 0x0a # U+000a Line feed
        'r' -> 0x0d # U+000d Carriage return
        't' -> 0x09 # U+0009 Tab
        _ -> b

expect escapedCharFromJson 'n' == '\n'

isHex : U8 -> Bool
isHex = \b ->
    (b >= '0' && b <= '9')
    || (b >= 'a' && b <= 'f')
    || (b >= 'A' && b <= 'F')

expect isHex '0' && isHex 'f' && isHex 'F' && isHex 'A' && isHex '9'
expect !(isHex 'g' && isHex 'x' && isHex 'u' && isHex '\\' && isHex '-')

jsonHexToDecimal : U8 -> U8
jsonHexToDecimal = \b ->
    if b >= '0' && b <= '9' then
        b - '0'
    else if b >= 'a' && b <= 'f' then
        b - 'a' + 10
    else if b >= 'A' && b <= 'F' then
        b - 'A' + 10
    else
        crash "got an invalid hex char"

expect jsonHexToDecimal '0' == 0
expect jsonHexToDecimal '9' == 9
expect jsonHexToDecimal 'a' == 10
expect jsonHexToDecimal 'A' == 10
expect jsonHexToDecimal 'f' == 15
expect jsonHexToDecimal 'F' == 15

decimalHexToByte : U8, U8 -> U8
decimalHexToByte = \upper, lower ->
    Num.bitwiseOr (Num.shiftLeftBy upper 4) lower

expect
    actual = decimalHexToByte 3 7
    expected = '7'
    actual == expected

expect
    actual = decimalHexToByte 7 4
    expected = 't'
    actual == expected

hexToUtf8 : U8, U8, U8, U8 -> List U8
hexToUtf8 = \a, b, c, d ->
    i = jsonHexToDecimal a
    j = jsonHexToDecimal b
    k = jsonHexToDecimal c
    l = jsonHexToDecimal d

    cp = (16 * 16 * 16 * Num.toU32 i) + (16 * 16 * Num.toU32 j) + (16 * Num.toU32 k) + Num.toU32 l
    codepointToUtf8 cp

# Copied from https://github.com/roc-lang/unicode/blob/e1162d49e3a2c57ed711ecdee7dc8537a19479d8/
# from package/CodePoint.roc and modified
codepointToUtf8 : U32 -> List U8
codepointToUtf8 = \u32 ->
    if u32 < 0x80 then
        [Num.toU8 u32]
    else if u32 < 0x800 then
        byte1 =
            u32
            |> Num.shiftRightBy 6
            |> Num.bitwiseOr 0b11000000
            |> Num.toU8

        byte2 =
            u32
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        [byte1, byte2]
    else if u32 < 0x10000 then
        byte1 =
            u32
            |> Num.shiftRightBy 12
            |> Num.bitwiseOr 0b11100000
            |> Num.toU8

        byte2 =
            u32
            |> Num.shiftRightBy 6
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        byte3 =
            u32
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        [byte1, byte2, byte3]
    else if u32 < 0x110000 then
        ## This was an invalid Unicode scalar value, even though it had the Roc type Scalar.
        ## This should never happen!
        # expect u32 < 0x110000
        crash "Impossible"
    else
        byte1 =
            u32
            |> Num.shiftRightBy 18
            |> Num.bitwiseOr 0b11110000
            |> Num.toU8

        byte2 =
            u32
            |> Num.shiftRightBy 12
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        byte3 =
            u32
            |> Num.shiftRightBy 6
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        byte4 =
            u32
            |> Num.bitwiseAnd 0b111111
            |> Num.bitwiseOr 0b10000000
            |> Num.toU8

        [byte1, byte2, byte3, byte4]

# Test for \u0074 == U+74 == 't' in Basic Multilingual Plane
expect
    actual = hexToUtf8 '0' '0' '7' '4'
    expected = ['t']
    actual == expected

# Test for \u0068 == U+68 == 'h' in Basic Multilingual Plane
expect
    actual = hexToUtf8 '0' '0' '6' '8'
    expected = ['h']
    actual == expected

# Test for \u2c64 == U+2C64 == 'Ɽ' in Latin Extended-C
expect
    actual = hexToUtf8 '2' 'C' '6' '4'
    expected = [0xE2, 0xB1, 0xA4]
    actual == expected

unicodeReplacement = [0xEF, 0xBF, 0xBD]

replaceEscapedChars : { inBytes : List U8, outBytes : List U8 } -> { inBytes : List U8, outBytes : List U8 }
replaceEscapedChars = \{ inBytes, outBytes } ->

    firstByte = List.get inBytes 0
    secondByte = List.get inBytes 1
    inBytesWithoutFirstTwo = List.dropFirst inBytes 2
    inBytesWithoutFirstSix = List.dropFirst inBytes 6

    when Pair firstByte secondByte is
        Pair (Ok a) (Ok b) if a == '\\' && b == 'u' ->
            # Extended json unicode escape
            when inBytesWithoutFirstTwo is
                [c, d, e, f, ..] ->
                    utf8Bytes = hexToUtf8 c d e f

                    replaceEscapedChars {
                        inBytes: inBytesWithoutFirstSix,
                        outBytes: List.concat outBytes utf8Bytes,
                    }

                _ ->
                    # Invalid Unicode Escape
                    replaceEscapedChars {
                        inBytes: inBytesWithoutFirstTwo,
                        outBytes: List.concat outBytes unicodeReplacement,
                    }

        Pair (Ok a) (Ok b) if a == '\\' && isEscapedChar b ->
            # Shorthand json unicode escape
            replaceEscapedChars {
                inBytes: inBytesWithoutFirstTwo,
                outBytes: List.append outBytes (escapedCharFromJson b),
            }

        Pair (Ok a) _ ->
            # Process next character
            replaceEscapedChars {
                inBytes: List.dropFirst inBytes 1,
                outBytes: List.append outBytes a,
            }

        _ ->
            { inBytes, outBytes }

# Test replacement of both extended and shorthand unicode escapes
expect
    inBytes = Str.toUtf8 "\\\\\\u0074\\u0068\\u0065\\t\\u0071\\u0075\\u0069\\u0063\\u006b\\n"
    actual = replaceEscapedChars { inBytes, outBytes: [] }
    expected = { inBytes: [], outBytes: ['\\', 't', 'h', 'e', '\t', 'q', 'u', 'i', 'c', 'k', '\n'] }

    actual == expected

# Test decode simple string
expect
    input = "\"hello\", " |> Str.toUtf8
    actual = Decode.fromBytesPartial input utf8
    expected = Ok "hello"

    actual.result == expected

# Test decode string with extended and shorthand json escapes
expect
    input = "\"h\\\"\\u0065llo\\n\"]\n" |> Str.toUtf8
    actual = Decode.fromBytesPartial input utf8
    expected = Ok "h\"ello\n"

    actual.result == expected

# Test json string decoding with escapes
expect
    input = Str.toUtf8 "\"a\r\nbc\\txz\"\t\n,  "
    actual = Decode.fromBytesPartial input utf8
    expected = Ok "a\r\nbc\txz"

    actual.result == expected

# Test decode of a null
expect
    input = Str.toUtf8 "null"

    actual : DecodeResult Str
    actual = Decode.fromBytesPartial input utf8

    Result.isErr actual.result

# JSON ARRAYS ------------------------------------------------------------------

decodeList : Decoder elem Json -> Decoder (List elem) Json
decodeList = \_elemDecoder -> Decode.custom \bytes, _jsonFmt ->
        { result: Err TooShort, rest: bytes }
isWhitespace = \b ->
    when b is
        ' ' | '\n' | '\r' | '\t' -> Bool.true
        _ -> Bool.false

expect
    input = ['1', 'a', ' ', '\n', 0x0d, 0x09]
    actual = List.map input isWhitespace
    expected = [Bool.false, Bool.false, Bool.true, Bool.true, Bool.true, Bool.true]

    actual == expected

# JSON OBJECTS -----------------------------------------------------------------
decodeRecord : state, (state, Str -> [Keep (Decoder state Json), Skip]), (state, Json -> [Err DecodeError, Ok val]) -> Decoder val Json
decodeRecord = \_initialState, _stepField, _finalizer -> Decode.custom \bytes, @Json {} ->

        { result: Err TooShort, rest: bytes }
