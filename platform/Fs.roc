module [createDirIfNotExist, writeUtf8]

import Effect

createDirIfNotExist : Str -> Task {} [FileSystemError Str]
createDirIfNotExist = \path ->
    Effect.createDirIfNotExist path |> Task.mapErr FileSystemError

writeUtf8 : Str, Str -> Task {} [FileSystemError Str]
writeUtf8 = \path, content ->
    Effect.fileWriteUtf8 path content |> Task.mapErr FileSystemError
