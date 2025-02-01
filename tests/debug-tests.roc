app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Assert
import r2e.Debug

config = Config.default_config

test_cases = [
    test1,
    test2,
]

# TODO craete a mock webpage to test better test this

test1 = test(
    "debug selectors",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        _h1 = browser |> Browser.find_element!(TestId("name-input"))?
        _h2 = browser |> Browser.find_element!(Css("h1"))?
        _h3 = browser |> Browser.find_element!(XPath("//div"))?

        _h10 = browser |> Browser.find_elements!(Css("input"))?
        _h12 = browser |> Browser.find_elements!(TestId("name-input"))?
        _h11 = browser |> Browser.find_elements!(XPath("//div"))?

        browser |> Browser.navigate_to!("https://www.roc-lang.org/")?
        _h5 = browser |> Browser.find_elements!(LinkText("examples"))?
        _h4 = browser |> Browser.find_element!(LinkText("examples"))?
        _h7 = browser |> Browser.find_elements!(PartialLinkText("xam"))?
        _h6 = browser |> Browser.find_element!(PartialLinkText("xam"))?

        Assert.should_be(1, 1),
)

test2 = test(
    "showElements",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

        browser |> Debug.show_current_frame!?
        browser |> Debug.show_current_frame!?

        el1 = browser |> Browser.find_element!(TestId("name-input"))?
        el1 |> Debug.show_element!?
        [el1] |> Debug.show_elements!?

        el2 = browser |> Browser.find_element!(Css("h1"))?
        el2 |> Debug.show_element!?
        [el2] |> Debug.show_elements!?

        el3 = browser |> Browser.find_element!(XPath("//div"))?
        el3 |> Debug.show_element!?
        [el3] |> Debug.show_elements!?

        browser |> Browser.navigate_to!("https://www.roc-lang.org/")?

        el4 = browser |> Browser.find_element!(LinkText("examples"))?
        el4 |> Debug.show_element!?
        [el4] |> Debug.show_elements!?

        el5 = browser |> Browser.find_element!(PartialLinkText("xam"))?
        el5 |> Debug.show_element!?
        [el5] |> Debug.show_elements!,
)

