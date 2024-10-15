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

# Driver := {
#     serverUrl : Str,
#     # headless : Bool,
#     # acceptInsecureCerts : Bool,
# }

Browser := {
    sessionId : Str,
    # serverUrl : Str,
}

Element := {
    sessionId : Str,
    # serverUrl : Str,
    elementId : Str,
}

# packDriverData = \data ->
#     @Driver data
#
# unpackDriverData = \@Driver data ->
#     data

packBrowserData = \data ->
    @Browser data

unpackBrowserData = \@Browser data ->
    data

packElementData = \data ->
    @Element data

unpackElementData = \@Element data ->
    data
