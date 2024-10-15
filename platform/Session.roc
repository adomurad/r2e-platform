module [createSession, deleteSession]

import Effect

createSession : Task Str [WebDrvierError Str]
createSession =
    Effect.startsession {} |> Task.mapErr WebDrvierError

deleteSession : Str -> Task {} [WebDrvierError Str]
deleteSession = \sessionId ->
    Effect.deletesession sessionId |> Task.mapErr WebDrvierError
