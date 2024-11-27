## `Report` module contains test reporters.
module [runReporters!, ReporterCallback, ReporterDefinition, TestRunResult, TestRunMetadata]

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

ReporterCallback err : List (TestRunResult err), TestRunMetadata -> List { filePath : Str, content : Str } where err implements Inspect

ReporterDefinition err : {
    name : Str,
    callback : ReporterCallback err,
} where err implements Inspect

runReporters! : List (ReporterDefinition err), List (TestRunResult err), Str, U64 => Result {} _
runReporters! = \reporters, results, outDir, duration ->
    reporters
    |> forEach! \reporter ->
        reporter |> runReporter! results outDir duration

forEach! = \list, callback! ->
    when list is
        [] -> Ok {}
        [el, .. as rest] ->
            callback! el |> try
            forEach! rest callback!

runReporter! : ReporterDefinition err, List (TestRunResult err), Str, U64 => Result {} _
runReporter! = \reporter, results, outDir, duration ->
    Fs.createDirIfNotExist! outDir |> try

    cb = reporter.callback
    readyFiles = cb results { duration }
    readyFiles
    |> forEach! \{ filePath, content } ->
        reporterDirName = reporter.name |> Str.replaceEach "/" "_"
        reporterDir = joinPath outDir reporterDirName
        finalPath = joinPath reporterDir filePath
        createDirForFilePath! finalPath |> try
        Fs.writeUtf8! finalPath content

joinPath = \path, filename ->
    sanitizedPath = path |> removeTrailing "/"

    "$(sanitizedPath)/$(filename)"

createDirForFilePath! = \path ->
    # TODO gracefully handle this error
    { before } = path |> Str.splitLast "/" |> try

    Fs.createDirIfNotExist! "$(before)/"

removeTrailing = \outDir, tail ->
    shouldRemove = outDir |> Str.endsWith tail
    if shouldRemove then
        outDir |> Str.replaceLast tail ""
    else
        outDir
