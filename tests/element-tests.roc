app [testCases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.defaultConfig

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
    # test19,
    # test20,
    # test21,
    # test22,
    # test23,
    # test24,
    # test25,
    # test26,
    # test27,
    # test28,
    # test29,
    # test30,
    # test31,
    # test32,
    # test33,
    # test34,
    # test35,
    # test36,
    # test37,
    # test38,
    # test39,
    # test40,
    # test41,
    # test42,
    # test43,
    # test44,
    # test45,
    # test45_2,
]

test1 = test "findElement and getText" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    h1 = browser |> Browser.findElement! (Css "h1") |> try

    text = h1 |> Element.getText! |> try

    text |> Assert.shouldBe "Example"

test2 = test "clickElement and check if selected" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    isSelected = checkbox |> Element.isSelected! |> try
    isSelected |> Assert.shouldBe NotSelected |> try

    checkbox |> Element.click! |> try

    isSelected2 = checkbox |> Element.isSelected! |> try
    isSelected2 |> Assert.shouldBe Selected

test3 = test "getAttribute empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getAttribute! "fake-attr" |> try
    emptyValue |> Assert.shouldBe ""

test4 = test "getAttribute Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    checkboxType = checkbox |> Element.getAttribute! "type" |> try
    checkboxType |> Assert.shouldBe "checkbox"

test5 = test "getAttributeOrEmpty empty" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getAttributeOrEmpty! "fake-attr" |> try
    when emptyValue is
        Ok _ -> Assert.failWith "should not have a value"
        Err Empty -> Ok {}

test6 = test "getAttributeOrEmpty Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    checkboxType = checkbox |> Element.getAttributeOrEmpty! "type" |> try
    when checkboxType is
        Ok type -> type |> Assert.shouldBe "checkbox"
        Err Empty -> Assert.failWith "should not be empty"

test7 = test "getProperty empty to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getProperty! "fake-prop" |> try
    emptyValue |> Assert.shouldBe ""

test8 = test "getProperty empty to Bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getProperty! "fake-prop" |> try
    emptyValue |> Assert.shouldBe Bool.false

test9 = test "getProperty empty to I64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getProperty! "fake-prop" |> try
    emptyValue |> Assert.shouldBe 0i64

test10 = test "getProperty empty to U64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getProperty! "fake-prop" |> try
    emptyValue |> Assert.shouldBe 0u64

test11 = test "getProperty empty to F64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    emptyValue = checkbox |> Element.getProperty! "fake-prop" |> try
    emptyValue |> Assert.shouldBeEqualTo 0f64

test12 = test "getProperty Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    value = checkbox |> Element.getProperty! "value" |> try
    value |> Assert.shouldBe "on"

test13 = test "getProperty boolean to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    checkbox |> Element.click! |> try

    value = checkbox |> Element.getProperty! "checked" |> try
    value |> Assert.shouldBe "true"

test14 = test "getProperty number to Str" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    value = checkbox |> Element.getProperty! "clientHeight" |> try
    value |> Assert.shouldBe "13"

test15 = test "getProperty number to I64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    value = checkbox |> Element.getProperty! "clientHeight" |> try
    value |> Assert.shouldBe 13

test16 = test "getProperty number to F64" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    value = checkbox |> Element.getProperty! "clientHeight" |> try
    value |> Assert.shouldBeEqualTo 13f64

test17 = test "getProperty Bool" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    checkbox |> Element.click! |> try

    value = checkbox |> Element.getProperty! "checked" |> try
    value |> Assert.shouldBe Bool.true

test18 = test "getProperty number to Bool decoding error" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
    checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try

    checkbox |> Element.click! |> try

    result : Result Bool _
    result = checkbox |> Element.getProperty! "clientHeight"

    when result is
        Ok _ -> Assert.failWith "shold not be ok"
        Err (PropertyTypeError err) ->
            err |> Assert.shouldBe "could not cast property \"clientHeight\" with value \"13\" to expected type"

        Err _ -> Assert.failWith "wrong error tag"

# test19 = test "getPropertyOrEmpty Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try
#
#     value = checkbox |> Element.getPropertyOrEmpty! "value" |> try
#
#     when value is
#         Ok val -> val |> Assert.shouldBe "on"
#         Err _ -> Assert.failWith "should be ok"
#
# test20 = test "getPropertyOrEmpty empty to Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox") |> try
#
#     value = checkbox |> Element.getPropertyOrEmpty! "fake-prop" |> try
#
#     when value is
#         Ok _ -> Assert.failWith "should not be ok"
#         Err Empty -> Ok {}

# test21 = test "inputText and getValue Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     input = browser |> Browser.findElement! (TestId "name-input") |> try
#
#     value = input |> Element.getValue! |> try
#     value |> Assert.shouldBe! ""
#
#     input |> Element.inputText! "roc" |> try
#
#     value2 = input |> Element.getValue! |> try
#     value2 |> Assert.shouldBe "roc"
#
# test22 = test "inputText and getValue F64" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     input = browser |> Browser.findElement! (TestId "name-input") |> try
#
#     value = input |> Element.getValue! |> try
#     _ = value |> Assert.shouldBe! "" |> try
#
#     input |> Element.inputText! "15.18" |> try
#
#     value2 = input |> Element.getValue! |> try
#     value2 |> Assert.shouldBeEqualTo 15.18f64
#
# test23 = test "inputText and getValue Bool" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     input = browser |> Browser.findElement! (TestId "name-input") |> try
#
#     value = input |> Element.getValue! |> try
#     value |> Assert.shouldBe! "" |> try
#
#     input |> Element.inputText! "true" |> try
#
#     value2 = input |> Element.getValue! |> try
#     value2 |> Assert.shouldBe Bool.true
#
# test24 = test "inputText {enter}" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     input = browser |> Browser.findElement! (TestId "name-input") |> try
#
#     input |> Element.inputText! "test{enter}" |> try
#
#     thankYouHeader = browser |> Browser.findElement! (TestId "thank-you-header") |> try
#     text = thankYouHeader |> Element.getText! |> try
#     text |> Assert.shouldBe "Thank you, test!"
#
# test25 = test "clearElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     input = browser |> Browser.findElement! (TestId "name-input") |> try
#
#     value = input |> Element.getValue! |> try
#     value |> Assert.shouldBe! "" |> try
#
#     input |> Element.inputText! "test" |> try
#
#     value2 = input |> Element.getValue! |> try
#     value2 |> Assert.shouldBe! "test" |> try
#
#     input |> Element.clear! |> try
#
#     value3 = input |> Element.getValue! |> try
#     value3 |> Assert.shouldBe ""
#
# test26 = test "findElements" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     options = browser |> Browser.findElements! (Css "option") |> try
#
#     options |> Assert.shouldHaveLength! 3 |> try
#
#     element1 = options |> List.get 0 |> try
#     element1 |> Assert.elementShouldHaveText! "Command Line" |> try
#
#     element2 = options |> List.get 1 |> try
#     element2 |> Assert.elementShouldHaveText! "JavaScript API" |> try
#
#     element3 = options |> List.get 2 |> try
#     element3 |> Assert.elementShouldHaveText! "Both"
#
# test27 = test "findElements empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     emptyList = browser |> Browser.findElements! (Css "#fake-id") |> try
#
#     emptyList |> Assert.shouldHaveLength 0
#
# test28 = test "tryFindElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     maybeElement = browser |> Browser.tryFindElement! (Css "h1") |> try
#
#     when maybeElement is
#         Found el ->
#             el |> Assert.elementShouldHaveText! "Example"
#
#         NotFound ->
#             Assert.failWith "element should have been found"
#
# test29 = test "tryFindElement empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#     maybeElement = browser |> Browser.tryFindElement! (Css "#fake-id") |> try
#
#     when maybeElement is
#         Found _ -> Assert.failWith "element should not have beed found"
#         NotFound ->
#             Task.ok {}
#
# test30 = test "findSingleElement empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     result = browser |> Browser.findSingleElement! (Css "#fake-id")
#
#     when result is
#         Ok _ -> Assert.failWith "should not find any elements"
#         Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found"
#         Err _ -> Assert.failWith "wrong error type"
#
# test31 = test "findSingleElement to many" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     result = browser |> Browser.findSingleElement! (Css "option")
#
#     when result is
#         Ok _ -> Assert.failWith "should find more than 1 element"
#         Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
#         Err _ -> Assert.failWith "wrong error type"
#
# test32 = test "findSingleElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     button = browser |> Browser.findSingleElement! (Css "#populate") |> try
#
#     button |> Assert.elementShouldHaveValue! "Populate"
#
# test33 = test "findElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     header = browser |> Browser.findElement! (Css "header") |> try
#
#     h1 = header |> Element.findElement! (Css "h1") |> try
#
#     text = h1 |> Element.getText! |> try
#
#     text |> Assert.shouldBe "Example"
#
# test34 = test "findElements in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     selectElement = browser |> Browser.findElement! (Css "select") |> try
#
#     options = selectElement |> Element.findElements! (Css "option") |> try
#
#     options |> Assert.shouldHaveLength! 3 |> try
#
#     element1 = options |> List.get 0 |> try
#     element1 |> Assert.elementShouldHaveText! "Command Line" |> try
#
#     element2 = options |> List.get 1 |> try
#     element2 |> Assert.elementShouldHaveText! "JavaScript API" |> try
#
#     element3 = options |> List.get 2 |> try
#     element3 |> Assert.elementShouldHaveText! "Both"
#
# test35 = test "findElements empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     header = browser |> Browser.findElement! (Css "header") |> try
#
#     emptyList = header |> Element.findElements! (Css "#fake-id") |> try
#
#     emptyList |> Assert.shouldHaveLength! 0
#
# test36 = test "tryFindElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     header = browser |> Browser.findElement! (Css "header") |> try
#
#     maybeElement = header |> Element.tryFindElement! (Css "h1") |> try
#
#     when maybeElement is
#         Found el ->
#             el |> Assert.elementShouldHaveText! "Example"
#
#         NotFound ->
#             Assert.failWith "element should have been found"
#
# test37 = test "tryFindElement empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     header = browser |> Browser.findElement! (Css "header") |> try
#
#     maybeElement = header |> Element.tryFindElement! (Css "#fake-id") |> try
#
#     when maybeElement is
#         Found _ -> Assert.failWith "element should not have beed found"
#         NotFound ->
#             Task.ok {}
#
# test38 = test "findSingleElement empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     header = browser |> Browser.findElement! (Css "header") |> try
#
#     result = header |> Element.findSingleElement! (Css "#fake-id")
#
#     when result is
#         Ok _ -> Assert.failWith "should not find any elements"
#         Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found in element (Css \"header\")"
#         Err _ -> Assert.failWith "wrong error type"
#
# test39 = test "findSingleElement to many in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     selectElement = browser |> Browser.findElement! (Css "select") |> try
#
#     result = selectElement |> Element.findSingleElement! (Css "option")
#
#     when result is
#         Ok _ -> Assert.failWith "should find more than 1 element"
#         Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
#         Err _ -> Assert.failWith "wrong error type"
#
# test40 = test "findSingleElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/" |> try
#
#     rocBox = browser |> Browser.findElement! (Css ".row") |> try
#
#     button = rocBox |> Element.findSingleElement! (Css "#populate") |> try
#
#     button |> Assert.elementShouldHaveValue! "Populate"
#
# test41 = test "isVisible" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try
#
#     button = browser |> Browser.findElement! (Css "#show-opacity") |> try
#     isButtonVisible = button |> Element.isVisible! |> try
#     isButtonVisible |> Assert.shouldBe Visible |> try
#
#     opacityHidden = browser |> Browser.findElement! (Css ".hide-by-opacity") |> try
#     isOpacityHiddenVisible = opacityHidden |> Element.isVisible! |> try
#     isOpacityHiddenVisible |> Assert.shouldBe NotVisible |> try
#
#     displayHidden = browser |> Browser.findElement! (Css ".hide-by-display") |> try
#     isDisplayHiddenVisible = displayHidden |> Element.isVisible! |> try
#     isDisplayHiddenVisible |> Assert.shouldBe NotVisible
#
# test42 = test "getTagName" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
#
#     buttonTag = button1 |> Element.getTagName! |> try
#
#     buttonTag |> Assert.shouldBe "button"
#
# test43 = test "getCss" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
#
#     border = button1 |> Element.getCssProperty! "border" |> try
#     border |> Assert.shouldBe! "2px solid rgb(0, 0, 0)" |> try
#
#     empty = button1 |> Element.getCssProperty! "jfkldsajflksadjlfk" |> try
#     empty |> Assert.shouldBe ""
#
# test44 = test "getRect" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting" |> try
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity") |> try
#
#     buttonRect = button1 |> Element.getRect! |> try
#
#     buttonRect.height |> Assert.shouldBe 51 |> try
#     buttonRect.width |> Assert.shouldBe 139 |> try
#     buttonRect.x |> Assert.shouldBeEqualTo 226 |> try
#     buttonRect.y |> Assert.shouldBeEqualTo 218.3593754
#
# test45 = test "iframe" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/iframe" |> try
#
#     frameEl = browser |> Browser.findElement! (Css "iframe") |> try
#     try Element.useIFrame! frameEl \frame ->
#         span = frame |> Browser.findElement! (Css "#span-inside-frame") |> try
#         span |> Assert.elementShouldHaveText! "This is inside an iFrame"
#
#     outsideSpan = browser |> Browser.findElement! (Css "#span-outside-frame") |> try
#     outsideSpan |> Assert.elementShouldHaveText! "Outside frame" |> try
#
#     try Element.useIFrame! frameEl \frame ->
#         span = frame |> Browser.findElement! (Css "#span-inside-frame") |> try
#         span |> Assert.elementShouldHaveText! "This is inside an iFrame"
#
# # TODO compiler error
# # test45_2 = test "iframe with error" \browser ->
# #     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/iframe"
# #
# #     frameEl = browser |> Browser.findElement! (Css "iframe")
# #     res =
# #         frameEl
# #             |> Element.useIFrame \_frame ->
# #                 Assert.failWith "this failed"
# #             |> Task.result!
# #
# #     res |> Assert.shouldBe! (Err (AssertionError "this failed"))
# #
# #     outsideSpan = browser |> Browser.findElement! (Css "#span-outside-frame")
# #     outsideSpan |> Assert.elementShouldHaveText! "Outside frame"
# #
# #     Element.useIFrame! frameEl \frame ->
# #         span = frame |> Browser.findElement! (Css "#span-inside-frame")
# #         span |> Assert.elementShouldHaveText "This is inside an iFrame"
