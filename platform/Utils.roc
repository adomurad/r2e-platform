module [getTimeMilis, incrementTest, getLogsForTest, getTestNameFilter, setTimeouts, setWindowSize, getAssertTimeout]

import Effect

getTimeMilis : Task U64 []
getTimeMilis =
    Effect.getTimeMilis {}
    |> Task.map Num.toU64
    |> Task.mapErr \_ -> crash "getTimeMilis should never crash"

incrementTest : Task {} []
incrementTest =
    Effect.incrementTest {}
    |> Task.mapErr \_ -> crash "incrementTest should never crash"

getLogsForTest : I64 -> Task (List Str) []
getLogsForTest = \testIndex ->
    Effect.getLogsForTest testIndex
    |> Task.mapErr \_ -> crash "getLogsForTest should never crash"

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

setWindowSize : [Size U64 U64] -> Task {} _
setWindowSize = \Size x y ->
    size = "$(x |> Num.toStr),$(y |> Num.toStr)"
    Effect.setWindowSize size
    |> Task.mapErr \_ -> crash "setWindowSize should never crash"

getAssertTimeout : Task U64 []
getAssertTimeout =
    Effect.getAssertTimeout {}
    |> Task.map Num.toU64
    |> Task.mapErr \_ -> crash "getAssertTimeout should never crash"
