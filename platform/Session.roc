module [createSession, deleteSession]

import Effect

createSession : Task Str [WebDriverError Str]
createSession =
    Effect.startSession {} |> Task.mapErr WebDriverError

deleteSession : Str -> Task {} [WebDriverError Str]
deleteSession = \sessionId ->
    Effect.deleteSession sessionId |> Task.mapErr WebDriverError
