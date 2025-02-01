module [create_dir_if_not_exist!, write_utf8!]

import Effect

create_dir_if_not_exist! : Str => Result {} [FileSystemError Str]
create_dir_if_not_exist! = |path|
    Effect.create_dir_if_not_exist!(path) |> Result.map_err(FileSystemError)

write_utf8! : Str, Str => Result {} [FileSystemError Str]
write_utf8! = |path, content|
    Effect.file_write_utf8!(path, content) |> Result.map_err(FileSystemError)
