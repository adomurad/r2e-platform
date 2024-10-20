module [
    # packDriverData,
    # unpackDriverData,
    packBrowserData,
    unpackBrowserData,
    packElementData,
    unpackElementData,
    # Driver,
    Browser,
    Element,
]

# ----------------------------------------------------------------

Browser := {
    sessionId : Str,
}

Element := {
    sessionId : Str,
    elementId : Str,
    # used to provide better context in Asserts
    selectorText : Str,
}

packBrowserData = \data ->
    @Browser data

unpackBrowserData = \@Browser data ->
    data

packElementData = \data ->
    @Element data

unpackElementData = \@Element data ->
    data
