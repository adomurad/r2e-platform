module [printLine, wait]

import Effect

## Write `Str` to Stdout
## followed by a newline.
##
## ```
## Debug.printLine "Hello World"
## ```
printLine : Str -> Task {} []
printLine = \str ->
    Effect.stdoutLine str
    |> Task.mapErr \_ -> crash "stdout should not fail"

# readLine : Task Str []
# readLine =
#     Effect.stdinLine {} |> Task.mapErr \_ -> crash "stdin should not fail"

## Stops the test execution for specified amount of time.
##
## `timeout` - time in [ms]
##
## ```
## # wait for 3s
## Debug.wait 3000
## ```
wait : U64 -> Task {} []
wait = \timeout ->
    Effect.wait timeout |> Task.mapErr \_ -> crash "sleep should not fail"
