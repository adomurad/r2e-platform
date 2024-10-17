## `Report` module contains test reporters.
module [createReporter, rename]

import InternalReporting exposing [ReporterCallback, ReporterDefinition]

# createReporter : Str, ReporterCallback err -> ReporterDefinition
# createReporter : Str, (List { name : Str, duration : U64, result : Result {} []err, screenshot : [NoScreenshot, Screenshot Str] }, TestRunMetadata -> List { filePath : Str, content : Str }) -> { name : Str, callback : List { name : Str, duration : U64, result : Result {} []err, screenshot : [NoScreenshot, Screenshot Str] }, TestRunMetadata -> List { filePath : Str, content : Str } }
createReporter : Str, ReporterCallback err -> ReporterDefinition err
createReporter = \name, callback ->
    { name, callback }

rename : ReporterDefinition err, Str -> ReporterDefinition err
rename = \reporter, newName ->
    { reporter & name: newName }
