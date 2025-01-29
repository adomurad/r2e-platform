module [Locator, get_locator]

## Supported locator strategies
##
## `Css Str` - e.g. Css ".my-button-class"
##
## `TestId Str` - e.g. TestId "button" => Css "[data-testid=\"button\"]"
##
## `XPath Str` - e.g. XPath "/bookstore/book[price>35]/price"
##
## `LinkText Str` - e.g. LinkText "Examples" in <a href="/examples-page">Examples</a>
##
## `PartialLinkText Str` - e.g. PartialLinkText "Exam" in <a href="/examples-page">Examples</a>
##
Locator : [
    Css Str,
    TestId Str,
    XPath Str,
    LinkText Str,
    PartialLinkText Str,
]

get_locator : Locator -> (Str, Str)
get_locator = |locator|
    when locator is
        Css(css_selector) -> ("css selector", css_selector)
        # TODO - script injection
        TestId(id) -> ("css selector", "[data-testid=\"${id}\"]")
        LinkText(text) -> ("link text", text)
        PartialLinkText(text) -> ("partial link text", text)
        # Tag tag -> ("tag name", tag)
        XPath(path) -> ("xpath", path)
