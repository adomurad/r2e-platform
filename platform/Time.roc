module [getTimeMilis]

import Effect

getTimeMilis : Task U64 []
getTimeMilis =
    Effect.getTimeMilis {}
    |> Task.map Num.toU64
    |> Task.mapErr \_ -> crash "getTimeMilis should never crash"
