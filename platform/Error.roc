module [web_driver_error_to_str]

# webDriverErrorToStr : [WebDriverError Str, ElementNotFound Str, AssertionError Str]a -> [StringError Str]a
## Takes in any error Tag and return the same Tag or `[StringError Str]` if the input was any of R2E errors
web_driver_error_to_str = |error_tag|
    when error_tag is
        WebDriverError(msg) -> StringError("WebDriverError: ${msg}")
        ElementNotFound(msg) -> StringError("ElementNotFound: ${msg}")
        AssertionError(msg) -> StringError("AssertionError: ${msg}")
        PropertyTypeError(msg) -> StringError("PropertyTypeError: ${msg}")
        err -> err
