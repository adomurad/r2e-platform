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
    test21,
    test22,
    test23,
    test24,
    test25,
    test26,
    test27,
    test28,
    test29,
    test30,
    test31,
    test32,
    test33,
    test34,
    test35,
    test36,
    test37,
    test38,
    test39,
    test40,
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

test21 = test "inputText and getValue Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (TestId "name-input")

    value = input |> Element.getValue!
    value |> Assert.shouldBe! ""

    input |> Element.inputText! "roc"

    value2 = input |> Element.getValue!
    value2 |> Assert.shouldBe "roc"

test22 = test "inputText and getValue F64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (TestId "name-input")

    value = input |> Element.getValue!
    value |> Assert.shouldBe! ""

    input |> Element.inputText! "15.18"

    value2 = input |> Element.getValue!
    value2 |> Assert.shouldBeEqualTo 15.18f64

test23 = test "inputText and getValue Bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (TestId "name-input")

    value = input |> Element.getValue!
    value |> Assert.shouldBe! ""

    input |> Element.inputText! "true"

    value2 = input |> Element.getValue!
    value2 |> Assert.shouldBe Bool.true

test24 = test "inputText {enter}" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (TestId "name-input")

    input |> Element.inputText! "test{enter}"

    thankYouHeader = browser |> Browser.findElement! (TestId "thank-you-header")
    text = thankYouHeader |> Element.getText!
    text |> Assert.shouldBe "Thank you, test!"

test25 = test "clearElement" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (TestId "name-input")

    value = input |> Element.getValue!
    value |> Assert.shouldBe! ""

    input |> Element.inputText! "test"

    value2 = input |> Element.getValue!
    value2 |> Assert.shouldBe! "test"

    input |> Element.clear!

    value3 = input |> Element.getValue!
    value3 |> Assert.shouldBe ""

test26 = test "findElements" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    options = browser |> Browser.findElements! (Css "option")

    options |> Assert.shouldHaveLength! 3

    element1 = options |> List.get 0 |> Task.fromResult!
    element1 |> Assert.elementShouldHaveText! "Command Line"

    element2 = options |> List.get 1 |> Task.fromResult!
    element2 |> Assert.elementShouldHaveText! "JavaScript API"

    element3 = options |> List.get 2 |> Task.fromResult!
    element3 |> Assert.elementShouldHaveText! "Both"

test27 = test "findElements empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    emptyList = browser |> Browser.findElements! (Css "#fake-id")

    emptyList |> Assert.shouldHaveLength! 0

test28 = test "tryFindElement" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    maybeElement = browser |> Browser.tryFindElement! (Css "h1")

    when maybeElement is
        Found el ->
            el |> Assert.elementShouldHaveText "Example"

        NotFound ->
            Assert.failWith "element should have been found"

test29 = test "tryFindElement empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    maybeElement = browser |> Browser.tryFindElement! (Css "#fake-id")

    when maybeElement is
        Found _ -> Assert.failWith "element should not have beed found"
        NotFound ->
            Task.ok {}

test30 = test "findSingleElement empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    result = browser |> Browser.findSingleElement (Css "#fake-id") |> Task.result!

    when result is
        Ok _ -> Assert.failWith "should not find any elements"
        Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found"
        Err _ -> Assert.failWith "wrong error type"

test31 = test "findSingleElement to many" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    result = browser |> Browser.findSingleElement (Css "option") |> Task.result!

    when result is
        Ok _ -> Assert.failWith "should find more than 1 element"
        Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
        Err _ -> Assert.failWith "wrong error type"

test32 = test "findSingleElement" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    button = browser |> Browser.findSingleElement! (Css "#populate")

    button |> Assert.elementShouldHaveValue! "Populate"

test33 = test "findElement in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    header = browser |> Browser.findElement! (Css "header")

    h1 = header |> Element.findElement! (Css "h1")

    text = h1 |> Element.getText!

    text |> Assert.shouldBe "Example"

test34 = test "findElements in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    selectElement = browser |> Browser.findElement! (Css "select")

    options = selectElement |> Element.findElements! (Css "option")

    options |> Assert.shouldHaveLength! 3

    element1 = options |> List.get 0 |> Task.fromResult!
    element1 |> Assert.elementShouldHaveText! "Command Line"

    element2 = options |> List.get 1 |> Task.fromResult!
    element2 |> Assert.elementShouldHaveText! "JavaScript API"

    element3 = options |> List.get 2 |> Task.fromResult!
    element3 |> Assert.elementShouldHaveText! "Both"

test35 = test "findElements empty in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    header = browser |> Browser.findElement! (Css "header")

    emptyList = header |> Element.findElements! (Css "#fake-id")

    emptyList |> Assert.shouldHaveLength! 0

test36 = test "tryFindElement in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    header = browser |> Browser.findElement! (Css "header")

    maybeElement = header |> Element.tryFindElement! (Css "h1")

    when maybeElement is
        Found el ->
            el |> Assert.elementShouldHaveText "Example"

        NotFound ->
            Assert.failWith "element should have been found"

test37 = test "tryFindElement empty in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    header = browser |> Browser.findElement! (Css "header")

    maybeElement = header |> Element.tryFindElement! (Css "#fake-id")

    when maybeElement is
        Found _ -> Assert.failWith "element should not have beed found"
        NotFound ->
            Task.ok {}

test38 = test "findSingleElement empty in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    header = browser |> Browser.findElement! (Css "header")

    result = header |> Element.findSingleElement (Css "#fake-id") |> Task.result!

    when result is
        Ok _ -> Assert.failWith "should not find any elements"
        Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found in element (Css \"header\")"
        Err _ -> Assert.failWith "wrong error type"

test39 = test "findSingleElement to many in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    selectElement = browser |> Browser.findElement! (Css "select")

    result = selectElement |> Element.findSingleElement (Css "option") |> Task.result!

    when result is
        Ok _ -> Assert.failWith "should find more than 1 element"
        Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
        Err _ -> Assert.failWith "wrong error type"

test40 = test "findSingleElement in element" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"

    rocBox = browser |> Browser.findElement! (Css ".row")

    button = rocBox |> Element.findSingleElement! (Css "#populate")

    button |> Assert.elementShouldHaveValue! "Populate"
