import InternalReporting

## `Reporting` module contains helpers to create and customise test reporters.
Reporting :: [].{

	## Creates a custom reporter.
	##
	## ```
	## custom_reporter = Reporting.create_reporter("myCustomReporter", |results, _meta|
	##     len_str = results.len().to_str()
	##     index_file = { file_path: "index.html", content: "<h3>Test count: ${len_str}</h3>" }
	##     test_file = { file_path: "test.txt", content: "this is just a test" }
	##     [index_file, test_file]
	## )
	## ```
	create_reporter : Str, InternalReporting.ReporterCallback -> InternalReporting.ReporterDefinition
	create_reporter = |name, callback|
		{ name, callback }

	## Rename an existing reporter.
	##
	## The name of a reporter is also used to create the report dir in outDir.
	##
	## ```
	## custom_reporter =
	##     BasicHtmlReporter.reporter
	##     |> Reporting.rename("myCustomReporter")
	## ```
	rename : InternalReporting.ReporterDefinition, Str -> InternalReporting.ReporterDefinition
	rename = |reporter, new_name|
		{ ..reporter, name: new_name }

	## Encode `Str` so it can be used in HTML.
	##
	## Useful util when writing a custom reporter.
	html_encode : Str -> Str
	html_encode = |str|
		str
			.replace_each("&", "&amp;")
			.replace_each("\"", "&quot;")
			.replace_each("'", "&#39;")
			.replace_each("<", "&lt;")
			.replace_each(">", "&gt;")
}
