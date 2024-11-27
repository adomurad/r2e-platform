module [
    getTimeMilis!,
    resetTestLogBucket!,
    getLogsFromBucket!,
    getTestNameFilter!,
    setTimeouts!,
    setWindowSize!,
    getAssertTimeout!,
    setImplicitTimeoutOverride!,
    setScriptTimeoutOverride!,
    setPageLoadTimeoutOverride!,
    setAssertTimeoutOverride!,
    resetTestOverrides!,
    setWindowSizeOverride!,
]

import Effect

getTimeMilis! : {} => U64
getTimeMilis! = \{} ->
    Effect.getTimeMilis! {} |> Num.toU64

resetTestLogBucket! : {} => {}
resetTestLogBucket! = \{} ->
    Effect.resetTestLogBucket! {}

getLogsFromBucket! : {} => List Str
getLogsFromBucket! = \{} ->
    Effect.getLogsFromBucket! {}

getTestNameFilter! : {} => [FilterTests Str, NoFilter]
getTestNameFilter! = \{} ->
    val = Effect.getTestNameFilter! {}

    if val |> Str.isEmpty then
        NoFilter
    else
        FilterTests val

setTimeouts! : { assertTimeout : U64, pageLoadTimeout : U64, scriptExecutionTimeout : U64, elementImplicitTimeout : U64 } => {}
setTimeouts! = \{ assertTimeout, pageLoadTimeout, scriptExecutionTimeout, elementImplicitTimeout } ->
    Effect.setTimeouts! assertTimeout pageLoadTimeout scriptExecutionTimeout elementImplicitTimeout

setAssertTimeoutOverride! : U64 => {}
setAssertTimeoutOverride! = \timeout ->
    Effect.setAssertTimeoutOverride! timeout

setPageLoadTimeoutOverride! : U64 => {}
setPageLoadTimeoutOverride! = \timeout ->
    Effect.setPageLoadTimeoutOverride! timeout

setScriptTimeoutOverride! : U64 => {}
setScriptTimeoutOverride! = \timeout ->
    Effect.setScriptTimeoutOverride! timeout

setImplicitTimeoutOverride! : U64 => {}
setImplicitTimeoutOverride! = \timeout ->
    Effect.setImplicitTimeoutOverride! timeout

resetTestOverrides! : {} => {}
resetTestOverrides! = \{} ->
    Effect.resetTestOverrides! {}

setWindowSize! : [Size U64 U64] => {}
setWindowSize! = \Size x y ->
    size = "$(x |> Num.toStr),$(y |> Num.toStr)"
    Effect.setWindowSize! size

setWindowSizeOverride! : [Size U64 U64] => {}
setWindowSizeOverride! = \Size x y ->
    size = "$(x |> Num.toStr),$(y |> Num.toStr)"
    Effect.setWindowSizeOverride! size

getAssertTimeout! : {} => U64
getAssertTimeout! = \{} ->
    Effect.getAssertTimeout! {}
