module [webDriverErrorToStr]

# webDriverErrorToStr : [WebDriverError Str, ElementNotFound Str, AssertionError Str]a -> [StringError Str]a
webDriverErrorToStr = \errorTag ->
    when errorTag is
        WebDriverError msg -> StringError "WebDriverError: $(msg)"
        ElementNotFound msg -> StringError "ElementNotFound: $(msg)"
        AssertionError msg -> StringError "AssertionError: $(msg)"
        err -> err
