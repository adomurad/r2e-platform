module [
    pack_browser_data,
    unpack_browser_data,
    pack_element_data,
    unpack_element_data,
    Browser,
    Element,
]

import Common.Locator exposing [Locator]

# ----------------------------------------------------------------

Browser := {
    session_id : Str,
}

Element := {
    session_id : Str,
    element_id : Str,
    # used to provide better context in Asserts
    selector_text : Str,
    locator : Locator,
}

pack_browser_data = |data|
    @Browser(data)

unpack_browser_data = |@Browser(data)|
    data

pack_element_data = |data|
    @Element(data)

unpack_element_data = |@Element(data)|
    data
