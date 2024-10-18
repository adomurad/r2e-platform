## `Element` module contains function to interact with `Elements`
## found in the `Browser`.
module [click]

import Internal exposing [Element]
import Effect

## Click on a `Element`.
##
## ```
## # find button element
## button = browser |> Browser.findElement! (Css "#submit-button")
## # click the button
## button |> Element.click!
## ```
click : Element -> Task {} [WebDriverError Str, ElementNotFound Str]
click = \element ->
    { sessionId, elementId } = Internal.unpackElementData element

    Effect.elementClick sessionId elementId |> Task.mapErr! handleElementError

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e
