## `Report` module contains test reporters.
module [createReporter, rename, htmlEncode]

import InternalReporting exposing [ReporterCallback, ReporterDefinition]

## Creates a custom reporter.
##
## ```
## customReporter = Reporting.createReporter "myCustomReporter" \results, _meta ->
##     lenStr = results |> List.len |> Num.toStr
##     indexFile = { filePath: "index.html", content: "<h3>Test count: $(lenStr)</h3>" }
##     testFile = { filePath: "test.txt", content: "this is just a test" }
##     [indexFile, testFile]
## ```
createReporter : Str, ReporterCallback err -> ReporterDefinition err
createReporter = \name, callback ->
    { name, callback }

## Rename an existing reporter.
## The name of a reporter is also used to create the report dir in outDir.
##
## ```
## customReporter =
##     Reporting.BasicHtmlReporter.reporter
##     |> Reporting.rename "myCustomReporter"
## ```
rename : ReporterDefinition err, Str -> ReporterDefinition err
rename = \reporter, newName ->
    { reporter & name: newName }

## Encode `Str` so it can be used in HTML.
##
## Useful util when writing a custom reporter.
htmlEncode : Str -> Str
htmlEncode = \str ->
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

expect htmlEncode "test" == "test"
expect htmlEncode "<h1>abc</h1>" == "&lt;h1&gt;abc&lt;/h1&gt;"
expect htmlEncode "test&test" == "test&amp;test"
expect htmlEncode "test\"test" == "test&quot;test"
expect htmlEncode "test'test" == "test&#39;test"
