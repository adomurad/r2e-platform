platform ""
    requires {} { main : Task {} [Exit I32 Str]_ }
    exposes [Console]
    packages {}
    imports [Console]
    provides [mainForHost]

mainForHost : Task {} I32
mainForHost =
    Task.attempt main \res ->
        when res is
            Ok {} -> Task.ok {}
            Err (Exit code str) ->
                if Str.isEmpty str then
                    Task.err code
                else
                    Console.printLine str
                    |> Task.onErr \_ -> Task.err code
                    |> Task.await \{} -> Task.err code

            Err err ->
                Console.printLine "Program exited early with error: $(Inspect.toStr err)"
                |> Task.onErr \_ -> Task.err 1
                |> Task.await \_ -> Task.err 1
