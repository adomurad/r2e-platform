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
    test5,
    test6,
    test7,
    test8,
    test9,
    test10,
    test11,
    test12,
    test13,
    test14,
    test15,
    test16,
    test17,
    test18,
    test19,
    test20,
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

    emptyValue = checkbox |> Element.getAttribute! "fake-attr"
    emptyValue |> Assert.shouldBe ""

test4 = test "getAttribute Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getAttribute! "type"
    checkboxType |> Assert.shouldBe "checkbox"

test5 = test "getAttributeOrEmpty empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getAttributeOrEmpty! "fake-attr"
    when emptyValue is
        Ok _ -> Assert.failWith "should not have a value"
        Err Empty -> Task.ok {}

test6 = test "getAttributeOrEmpty Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkboxType = checkbox |> Element.getAttributeOrEmpty! "type"
    when checkboxType is
        Ok type -> type |> Assert.shouldBe "checkbox"
        Err Empty -> Assert.failWith "should not be empty"

test7 = test "getProperty empty to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getProperty! "fake-prop"
    emptyValue |> Assert.shouldBe ""

test8 = test "getProperty empty to Bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getProperty! "fake-prop"
    emptyValue |> Assert.shouldBe Bool.false

test9 = test "getProperty empty to I64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getProperty! "fake-prop"
    emptyValue |> Assert.shouldBe 0i64

test10 = test "getProperty empty to U64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getProperty! "fake-prop"
    emptyValue |> Assert.shouldBe 0u64

test11 = test "getProperty empty to F64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    emptyValue = checkbox |> Element.getProperty! "fake-prop"
    emptyValue |> Assert.shouldBeEqualTo 0f64

test12 = test "getProperty Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getProperty! "value"
    value |> Assert.shouldBe "on"

test13 = test "getProperty boolean to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkbox |> Element.click!

    value = checkbox |> Element.getProperty! "checked"
    value |> Assert.shouldBe "true"

test14 = test "getProperty number to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getProperty! "clientHeight"
    value |> Assert.shouldBe "13"

test15 = test "getProperty number to I64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getProperty! "clientHeight"
    value |> Assert.shouldBe 13

test16 = test "getProperty number to F64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getProperty! "clientHeight"
    value |> Assert.shouldBeEqualTo 13f64

test17 = test "getProperty Bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkbox |> Element.click!

    value = checkbox |> Element.getProperty! "checked"
    value |> Assert.shouldBe Bool.true

test18 = test "getProperty number to Bool decoding error" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    checkbox |> Element.click!

    task : Task Bool _
    task = checkbox |> Element.getProperty "clientHeight"

    result = task |> Task.result!

    when result is
        Ok _ -> Assert.failWith "shold not be ok"
        Err (PropertyTypeError err) ->
            err |> Assert.shouldBe "could not cast property \"clientHeight\" with value \"13\" to expected type"

        Err _ -> Assert.failWith "wrong error tag"

test19 = test "getPropertyOrEmpty Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getPropertyOrEmpty! "value"

    when value is
        Ok val -> val |> Assert.shouldBe "on"
        Err _ -> Assert.failWith "should be ok"

test20 = test "getPropertyOrEmpty empty to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")

    value = checkbox |> Element.getPropertyOrEmpty! "fake-prop"

    when value is
        Ok _ -> Assert.failWith "should not be ok"
        Err Empty -> Task.ok {}
