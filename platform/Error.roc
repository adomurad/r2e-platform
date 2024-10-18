module [webDriverErrorToStr]

# webDriverErrorToStr : [WebDriverError Str, ElementNotFound Str, AssertionError Str]a -> [StringError Str]a
## Takes in any error Tag and return the same Tag or `[StringError Str]` if the input was any of R2E errors
webDriverErrorToStr = \errorTag ->
    when errorTag is
        WebDriverError msg -> StringError "WebDriverError: $(msg)"
        ElementNotFound msg -> StringError "ElementNotFound: $(msg)"
        AssertionError msg -> StringError "AssertionError: $(msg)"
        err -> err
