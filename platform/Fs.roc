module [createDirIfNotExist!, writeUtf8!]

import Effect

createDirIfNotExist! : Str => Result {} [FileSystemError Str]
createDirIfNotExist! = \path ->
    Effect.createDirIfNotExist! path |> Result.mapErr FileSystemError

writeUtf8! : Str, Str => Result {} [FileSystemError Str]
writeUtf8! = \path, content ->
    Effect.fileWriteUtf8! path content |> Result.mapErr FileSystemError
