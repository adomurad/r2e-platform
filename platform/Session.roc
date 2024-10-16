module [createSession, deleteSession]

import Effect

createSession : Task Str [WebDrvierError Str]
createSession =
    Effect.startSession {} |> Task.mapErr WebDrvierError

deleteSession : Str -> Task {} [WebDrvierError Str]
deleteSession = \sessionId ->
    Effect.deleteSession sessionId |> Task.mapErr WebDrvierError
