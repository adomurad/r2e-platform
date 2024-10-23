module [handleElementError]

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverElementNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverElementNotFoundError::")
        e -> WebDriverError e
