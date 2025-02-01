module [encode_json_string]

encode_json_string : Str -> Str
encode_json_string = |str|
    bytes = str |> Str.to_utf8

    initial = List.with_capacity(List.len(bytes))

    bytes
    |> List.walk(
        initial,
        |ecoded_bytes, byte|
            ecoded_bytes |> List.concat(escape_byte_to_json(byte)),
    )
    |> List.prepend('"')
    |> List.append('"')
    |> Str.from_utf8
    |> Result.with_default("") # should not fail

expect encode_json_string("hmm\"test\"hmm") == "\"hmm\\\"test\\\"hmm\""

# Prepend an "\" escape byte
escape_byte_to_json : U8 -> List U8
escape_byte_to_json = |b|
    when b is
        0x22 -> [0x5c, 0x22] # U+0022 Quotation mark
        0x5c -> [0x5c, 0x5c] # U+005c Reverse solidus
        0x2f -> [0x5c, 0x2f] # U+002f Solidus
        0x08 -> [0x5c, 'b'] # U+0008 Backspace
        0x0c -> [0x5c, 'f'] # U+000c Form feed
        0x0a -> [0x5c, 'n'] # U+000a Line feed
        0x0d -> [0x5c, 'r'] # U+000d Carriage return
        0x09 -> [0x5c, 'r'] # U+0009 Tab
        _ -> [b]

expect escape_byte_to_json('\n') == ['\\', 'n']
expect escape_byte_to_json('\\') == ['\\', '\\']
expect escape_byte_to_json('"') == ['\\', '"']
