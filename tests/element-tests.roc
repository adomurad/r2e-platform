app [testCases] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Assert

testCases = [
    test1,
    test2,
    test3,
    test4,
]

test1 = test "findElement and getText" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    h1 = browser |> Browser.findElement! (Css "h1")

    text = h1 |> Element.getText!

    text |> Assert.shouldBe "Example"

test2 = test "clickElement and check if selected" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    isSelected = checkbox |> Element.isSelected!
    isSelected |> Assert.shouldBe! NotSelected

    checkbox |> Element.click!

    isSelected2 = checkbox |> Element.isSelected!
    isSelected2 |> Assert.shouldBe! Selected

test3 = test "getAttribute empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getAttribute! "fake-attr"
    when checkboxType is
        Ok _ -> Assert.failWith "should not have a value"
        Err Empty -> Task.ok {}

test4 = test "getAttribute Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getAttribute! "type"
    when checkboxType is
        Ok type -> type |> Assert.shouldBe "checkbox"
        Err Empty -> Assert.failWith "should not be empty"

test5 = test "getAttribute " \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getAttribute! "type"
    when checkboxType is
        Ok type -> type |> Assert.shouldBe "checkbox"
        Err Empty -> Assert.failWith "should not be empty"
