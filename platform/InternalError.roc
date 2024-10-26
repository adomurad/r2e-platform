module [handleElementError, handleCookieError, handleAlertError]

handleElementError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverNotFoundError" -> ElementNotFound (e |> Str.dropPrefix "WebDriverNotFoundError::")
        e -> WebDriverError e

handleAlertError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverNotFoundError" -> AlertNotFound (e |> Str.dropPrefix "WebDriverNotFoundError::")
        e -> WebDriverError e

handleCookieError = \err ->
    when err is
        e if e |> Str.startsWith "WebDriverNotFoundError" -> CookieNotFound (e |> Str.dropPrefix "WebDriverNotFoundError::")
        e -> WebDriverError e
