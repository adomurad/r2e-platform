module [navigateTo]

import Effect
import Internal exposing [Browser]

navigateTo : Browser, Str -> Task {} [WebDriverError Str]
navigateTo = \browser, url ->
    { sessionId } = Internal.unpackBrowserData browser
    Effect.browserNavigateTo sessionId url |> Task.mapErr WebDriverError
