module [getTimeMilis, incrementTest, getLogsForTest, getTestNameFilter]

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
