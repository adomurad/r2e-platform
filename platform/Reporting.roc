## `Report` module contains test reporters.
module [create_reporter, rename, html_encode]

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
create_reporter : Str, ReporterCallback err -> ReporterDefinition err
create_reporter = |name, callback|
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
rename = |reporter, new_name|
    { reporter & name: new_name }

## Encode `Str` so it can be used in HTML.
##
## Useful util when writing a custom reporter.
html_encode : Str -> Str
html_encode = |str|
    str_result =
        str
        |> Str.walk_utf8(
            [],
            |state, current|
                when current is
                    34 -> List.concat(state, Str.to_utf8("&quot;"))
                    38 -> List.concat(state, Str.to_utf8("&amp;"))
                    39 -> List.concat(state, Str.to_utf8("&#39;"))
                    60 -> List.concat(state, Str.to_utf8("&lt;"))
                    62 -> List.concat(state, Str.to_utf8("&gt;"))
                    _ -> List.append(state, current),
        )
        |> Str.from_utf8

    when str_result is
        Ok(s) -> s
        Err(_) -> crash("EscapeHtml: this error should not be possible.")

expect html_encode("test") == "test"
expect html_encode("<h1>abc</h1>") == "&lt;h1&gt;abc&lt;/h1&gt;"
expect html_encode("test&test") == "test&amp;test"
expect html_encode("test\"test") == "test&quot;test"
expect html_encode("test'test") == "test&#39;test"
