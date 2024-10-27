module [
    getTimeMilis,
    resetTestLogBucket,
    getLogsFromBucket,
    getTestNameFilter,
    setTimeouts,
    setWindowSize,
    getAssertTimeout,
    setImplicitTimeoutOverride,
    setScriptTimeoutOverride,
    setPageLoadTimeoutOverride,
    setAssertTimeoutOverride,
    resetTestOverrides,
    setWindowSizeOverride,
]

import Effect

getTimeMilis : Task U64 []
getTimeMilis =
    Effect.getTimeMilis {}
    |> Task.map Num.toU64
    |> Task.mapErr \_ -> crash "getTimeMilis should never crash"

resetTestLogBucket : Task {} []
resetTestLogBucket =
    Effect.resetTestLogBucket {}
    |> Task.mapErr \_ -> crash "resetTestLogBucket should never crash"

getLogsFromBucket : Task (List Str) []
getLogsFromBucket =
    Effect.getLogsFromBucket {}
    |> Task.mapErr \_ -> crash "getLogsFromBucket should never crash"

getTestNameFilter : Task [FilterTests Str, NoFilter] []
getTestNameFilter =
    Effect.getTestNameFilter {}
    |> Task.map \val ->
        if val |> Str.isEmpty then
            NoFilter
        else
            FilterTests val
    |> Task.mapErr \_ -> crash "getTestNameFilter should never crash"

setTimeouts : { assertTimeout : U64, pageLoadTimeout : U64, scriptExecutionTimeout : U64, elementImplicitTimeout : U64 } -> Task {} _
setTimeouts = \{ assertTimeout, pageLoadTimeout, scriptExecutionTimeout, elementImplicitTimeout } ->
    Effect.setTimeouts assertTimeout pageLoadTimeout scriptExecutionTimeout elementImplicitTimeout
    |> Task.mapErr \_ -> crash "setTimeuts should never crash"

setAssertTimeoutOverride : U64 -> Task {} []
setAssertTimeoutOverride = \timeout ->
    Effect.setAssertTimeoutOverride timeout
    |> Task.mapErr \_ -> crash "set override should never crash"

setPageLoadTimeoutOverride : U64 -> Task {} []
setPageLoadTimeoutOverride = \timeout ->
    Effect.setPageLoadTimeoutOverride timeout
    |> Task.mapErr \_ -> crash "set override should never crash"

setScriptTimeoutOverride : U64 -> Task {} []
setScriptTimeoutOverride = \timeout ->
    Effect.setScriptTimeoutOverride timeout
    |> Task.mapErr \_ -> crash "set override should never crash"

setImplicitTimeoutOverride : U64 -> Task {} []
setImplicitTimeoutOverride = \timeout ->
    Effect.setImplicitTimeoutOverride timeout
    |> Task.mapErr \_ -> crash "set override should never crash"

resetTestOverrides : Task {} []
resetTestOverrides =
    Effect.resetTestOverrides {}
    |> Task.mapErr \_ -> crash "set override should never crash"

setWindowSize : [Size U64 U64] -> Task {} _
setWindowSize = \Size x y ->
    size = "$(x |> Num.toStr),$(y |> Num.toStr)"
    Effect.setWindowSize size
    |> Task.mapErr \_ -> crash "setWindowSize should never crash"

setWindowSizeOverride : [Size U64 U64] -> Task {} _
setWindowSizeOverride = \Size x y ->
    size = "$(x |> Num.toStr),$(y |> Num.toStr)"
    Effect.setWindowSizeOverride size
    |> Task.mapErr \_ -> crash "setWindowSize should never crash"

getAssertTimeout : Task U64 []
getAssertTimeout =
    Effect.getAssertTimeout {}
    |> Task.map Num.toU64
    |> Task.mapErr \_ -> crash "getAssertTimeout should never crash"
