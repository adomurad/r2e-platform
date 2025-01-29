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
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        _h1 = browser |> Browser.find_element!(TestId("name-input")) |> try
        _h2 = browser |> Browser.find_element!(Css("h1")) |> try
        _h3 = browser |> Browser.find_element!(XPath("//div")) |> try

        _h10 = browser |> Browser.find_elements!(Css("input")) |> try
        _h12 = browser |> Browser.find_elements!(TestId("name-input")) |> try
        _h11 = browser |> Browser.find_elements!(XPath("//div")) |> try

        browser |> Browser.navigate_to!("https://www.roc-lang.org/") |> try
        _h5 = browser |> Browser.find_elements!(LinkText("examples")) |> try
        _h4 = browser |> Browser.find_element!(LinkText("examples")) |> try
        _h7 = browser |> Browser.find_elements!(PartialLinkText("xam")) |> try
        _h6 = browser |> Browser.find_element!(PartialLinkText("xam")) |> try

        Assert.should_be(1, 1),
)

test2 = test(
    "showElements",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/") |> try

        browser |> Debug.show_current_frame! |> try
        browser |> Debug.show_current_frame! |> try

        el1 = browser |> Browser.find_element!(TestId("name-input")) |> try
        el1 |> Debug.show_element! |> try
        [el1] |> Debug.show_elements! |> try

        el2 = browser |> Browser.find_element!(Css("h1")) |> try
        el2 |> Debug.show_element! |> try
        [el2] |> Debug.show_elements! |> try

        el3 = browser |> Browser.find_element!(XPath("//div")) |> try
        el3 |> Debug.show_element! |> try
        [el3] |> Debug.show_elements! |> try

        browser |> Browser.navigate_to!("https://www.roc-lang.org/") |> try

        el4 = browser |> Browser.find_element!(LinkText("examples")) |> try
        el4 |> Debug.show_element! |> try
        [el4] |> Debug.show_elements! |> try

        el5 = browser |> Browser.find_element!(PartialLinkText("xam")) |> try
        el5 |> Debug.show_element! |> try
        [el5] |> Debug.show_elements!,
)

