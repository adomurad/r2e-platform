module [
    packBrowserData,
    unpackBrowserData,
    packElementData,
    unpackElementData,
    Browser,
    Element,
]

import Common.Locator exposing [Locator]

# ----------------------------------------------------------------

Browser := {
    sessionId : Str,
}

Element := {
    sessionId : Str,
    elementId : Str,
    # used to provide better context in Asserts
    selectorText : Str,
    locator : Locator,
}

packBrowserData = \data ->
    @Browser data

unpackBrowserData = \@Browser data ->
    data

packElementData = \data ->
    @Element data

unpackElementData = \@Element data ->
    data
