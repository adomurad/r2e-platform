module [encode]

encode : Str -> Str
encode = \str ->
    strResult =
        str
        |> Str.walkUtf8 [] \state, current ->
            when current is
                34 -> List.concat state (Str.toUtf8 "&quot;")
                38 -> List.concat state (Str.toUtf8 "&amp;")
                39 -> List.concat state (Str.toUtf8 "&#39;")
                60 -> List.concat state (Str.toUtf8 "&lt;")
                62 -> List.concat state (Str.toUtf8 "&gt;")
                _ -> List.append state current
        |> Str.fromUtf8

    when strResult is
        Ok s -> s
        Err _ -> crash "EscapeHtml: this error should not be possible."

expect encode "test" == "test"
expect encode "<h1>abc</h1>" == "&lt;h1&gt;abc&lt;/h1&gt;"
expect encode "test&test" == "test&amp;test"
expect encode "test\"test" == "test&quot;test"
expect encode "test'test" == "test&#39;test"
