module [handleElementError, handleCookieError]

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverNotFoundError::")
        e -> WebDriverError e

handleCookieError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverNotFoundError" -> CookieNotFound (e |> Str.dropPrefix "WebDriverNotFoundError::")
        e -> WebDriverError e
