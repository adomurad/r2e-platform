module [click]

import Internal exposing [Element]
import Effect

click : Element -> Task {} [WebDriverError Str, ElementNotFound Str]
click = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementClick sessionId elementId |> Task.mapErr! handleElementError

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e
