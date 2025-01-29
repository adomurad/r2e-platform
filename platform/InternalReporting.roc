## `Report` module contains test reporters.
module [run_reporters!, ReporterCallback, ReporterDefinition, TestRunResult, TestRunMetadata]

import Fs

TestRunResult err : {
    name : Str,
    duration : U64,
    result : Result {} []err,
    screenshot : [NoScreenshot, Screenshot Str],
    logs : List Str,
    type : [FinalResult, Attempt],
} where err implements Inspect

TestRunMetadata : {
    duration : U64,
}

ReporterCallback err : List (TestRunResult err), TestRunMetadata -> List { file_path : Str, content : Str } where err implements Inspect

ReporterDefinition err : {
    name : Str,
    callback : ReporterCallback err,
} where err implements Inspect

run_reporters! : List (ReporterDefinition err), List (TestRunResult err), Str, U64 => Result {} _
run_reporters! = |reporters, results, out_dir, duration|
    reporters
    |> for_each!(
        |reporter|
            reporter |> run_reporter!(results, out_dir, duration),
    )

for_each! = |list, callback!|
    when list is
        [] -> Ok({})
        [el, .. as rest] ->
            callback!(el) |> try
            for_each!(rest, callback!)

run_reporter! : ReporterDefinition err, List (TestRunResult err), Str, U64 => Result {} _
run_reporter! = |reporter, results, out_dir, duration|
    Fs.create_dir_if_not_exist!(out_dir) |> try

    cb = reporter.callback
    ready_files = cb(results, { duration })
    ready_files
    |> for_each!(
        |{ file_path, content }|
            reporter_dir_name = reporter.name |> Str.replace_each("/", "_")
            reporter_dir = join_path(out_dir, reporter_dir_name)
            final_path = join_path(reporter_dir, file_path)
            create_dir_for_file_path!(final_path) |> try
            Fs.write_utf8!(final_path, content),
    )

join_path = |path, filename|
    sanitized_path = path |> remove_trailing("/")

    "${sanitized_path}/${filename}"

create_dir_for_file_path! = |path|
    # TODO gracefully handle this error
    { before } = path |> Str.split_last("/") |> try

    Fs.create_dir_if_not_exist!("${before}/")

remove_trailing = |out_dir, tail|
    should_remove = out_dir |> Str.ends_with(tail)
    if should_remove then
        out_dir |> Str.replace_last(tail, "")
    else
        out_dir
