module [encodeJsonString]

encodeJsonString : Str -> Str
encodeJsonString = \str ->
    bytes = str |> Str.toUtf8

    initial = List.withCapacity (List.len bytes)

    bytes
    |> List.walk initial \ecodedBytes, byte ->
        ecodedBytes |> List.concat (escapeByteToJson byte)
    |> List.prepend '"'
    |> List.append '"'
    |> Str.fromUtf8
    |> Result.withDefault "" # should not fail

expect encodeJsonString "hmm\"test\"hmm" == "\"hmm\\\"test\\\"hmm\""

# Prepend an "\" escape byte
escapeByteToJson : U8 -> List U8
escapeByteToJson = \b ->
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

expect escapeByteToJson '\n' == ['\\', 'n']
expect escapeByteToJson '\\' == ['\\', '\\']
expect escapeByteToJson '"' == ['\\', '"']
