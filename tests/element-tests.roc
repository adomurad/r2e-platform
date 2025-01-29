app [test_cases, config] { r2e: platform "../platform/main.roc" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.default_config

test_cases = [
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

test1 = test(
    "findElement and getText",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        h1 = browser |> Browser.find_element!(Css("h1"))?

        text = h1 |> Element.get_text!?

        text |> Assert.should_be("Example"),
)

test2 = test(
    "clickElement and check if selected",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        is_selected = checkbox |> Element.is_selected!?
        is_selected |> Assert.should_be(NotSelected)?

        checkbox |> Element.click!?

        is_selected2 = checkbox |> Element.is_selected!?
        is_selected2 |> Assert.should_be(Selected),
)

test3 = test(
    "getAttribute empty",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_attribute!("fake-attr")?
        empty_value |> Assert.should_be(""),
)

test4 = test(
    "getAttribute Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        checkbox_type = checkbox |> Element.get_attribute!("type")?
        checkbox_type |> Assert.should_be("checkbox"),
)

test5 = test(
    "getAttributeOrEmpty empty",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_attribute_or_empty!("fake-attr")?
        when empty_value is
            Ok(_) -> Assert.fail_with("should not have a value")
            Err(Empty) -> Ok({}),
)

test6 = test(
    "getAttributeOrEmpty Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        checkbox_type = checkbox |> Element.get_attribute_or_empty!("type")?
        when checkbox_type is
            Ok(type) -> type |> Assert.should_be("checkbox")
            Err(Empty) -> Assert.fail_with("should not be empty"),
)

test7 = test(
    "getProperty empty to Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_property!("fake-prop")?
        empty_value |> Assert.should_be(""),
)

test8 = test(
    "getProperty empty to Bool",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_property!("fake-prop")?
        empty_value |> Assert.should_be(Bool.false),
)

test9 = test(
    "getProperty empty to I64",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_property!("fake-prop")?
        empty_value |> Assert.should_be(0i64),
)

test10 = test(
    "getProperty empty to U64",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_property!("fake-prop")?
        empty_value |> Assert.should_be(0u64),
)

test11 = test(
    "getProperty empty to F64",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        empty_value = checkbox |> Element.get_property!("fake-prop")?
        empty_value |> Assert.should_be_equal_to(0f64),
)

test12 = test(
    "getProperty Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        value = checkbox |> Element.get_property!("value")?
        value |> Assert.should_be("on"),
)

test13 = test(
    "getProperty boolean to Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        checkbox |> Element.click!?

        value = checkbox |> Element.get_property!("checked")?
        value |> Assert.should_be("true"),
)

test14 = test(
    "getProperty number to Str",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        value = checkbox |> Element.get_property!("clientHeight")?
        value |> Assert.should_be("13"),
)

test15 = test(
    "getProperty number to I64",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        value = checkbox |> Element.get_property!("clientHeight")?
        value |> Assert.should_be(13),
)

test16 = test(
    "getProperty number to F64",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        value = checkbox |> Element.get_property!("clientHeight")?
        value |> Assert.should_be_equal_to(13f64),
)

test17 = test(
    "getProperty Bool",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        checkbox |> Element.click!?

        value = checkbox |> Element.get_property!("checked")?
        value |> Assert.should_be(Bool.true),
)

test18 = test(
    "getProperty number to Bool decoding error",
    |browser|
        browser |> Browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
        checkbox = browser |> Browser.find_element!(TestId("remote-testing-checkbox"))?

        checkbox |> Element.click!?

        result : Result Bool _
        result = checkbox |> Element.get_property!("clientHeight")

        when result is
            Ok(_) -> Assert.fail_with("shold not be ok")
            Err(PropertyTypeError(err)) ->
                err |> Assert.should_be("could not cast property \"clientHeight\" with value \"13\" to expected type")

            Err(_) -> Assert.fail_with("wrong error tag"),
)

# test19 = test "getPropertyOrEmpty Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")?
#
#     value = checkbox |> Element.getPropertyOrEmpty! "value"?
#
#     when value is
#         Ok val -> val |> Assert.shouldBe "on"
#         Err _ -> Assert.failWith "should be ok"
#
# test20 = test "getPropertyOrEmpty empty to Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     checkbox = browser |> Browser.findElement! (TestId "remote-testing-checkbox")?
#
#     value = checkbox |> Element.getPropertyOrEmpty! "fake-prop"?
#
#     when value is
#         Ok _ -> Assert.failWith "should not be ok"
#         Err Empty -> Ok {}

# test21 = test "inputText and getValue Str" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     input = browser |> Browser.findElement! (TestId "name-input")?
#
#     value = input |> Element.getValue!?
#     value |> Assert.shouldBe! ""
#
#     input |> Element.inputText! "roc"?
#
#     value2 = input |> Element.getValue!?
#     value2 |> Assert.shouldBe "roc"
#
# test22 = test "inputText and getValue F64" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     input = browser |> Browser.findElement! (TestId "name-input")?
#
#     value = input |> Element.getValue!?
#     _ = value |> Assert.shouldBe! ""?
#
#     input |> Element.inputText! "15.18"?
#
#     value2 = input |> Element.getValue!?
#     value2 |> Assert.shouldBeEqualTo 15.18f64
#
# test23 = test "inputText and getValue Bool" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     input = browser |> Browser.findElement! (TestId "name-input")?
#
#     value = input |> Element.getValue!?
#     value |> Assert.shouldBe! ""?
#
#     input |> Element.inputText! "true"?
#
#     value2 = input |> Element.getValue!?
#     value2 |> Assert.shouldBe Bool.true
#
# test24 = test "inputText {enter}" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     input = browser |> Browser.findElement! (TestId "name-input")?
#
#     input |> Element.inputText! "test{enter}"?
#
#     thankYouHeader = browser |> Browser.findElement! (TestId "thank-you-header")?
#     text = thankYouHeader |> Element.getText!?
#     text |> Assert.shouldBe "Thank you, test!"
#
# test25 = test "clearElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     input = browser |> Browser.findElement! (TestId "name-input")?
#
#     value = input |> Element.getValue!?
#     value |> Assert.shouldBe! ""?
#
#     input |> Element.inputText! "test"?
#
#     value2 = input |> Element.getValue!?
#     value2 |> Assert.shouldBe! "test"?
#
#     input |> Element.clear!?
#
#     value3 = input |> Element.getValue!?
#     value3 |> Assert.shouldBe ""
#
# test26 = test "findElements" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     options = browser |> Browser.findElements! (Css "option")?
#
#     options |> Assert.shouldHaveLength! 3?
#
#     element1 = options |> List.get 0?
#     element1 |> Assert.elementShouldHaveText! "Command Line"?
#
#     element2 = options |> List.get 1?
#     element2 |> Assert.elementShouldHaveText! "JavaScript API"?
#
#     element3 = options |> List.get 2?
#     element3 |> Assert.elementShouldHaveText! "Both"
#
# test27 = test "findElements empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     emptyList = browser |> Browser.findElements! (Css "#fake-id")?
#
#     emptyList |> Assert.shouldHaveLength 0
#
# test28 = test "tryFindElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     maybeElement = browser |> Browser.tryFindElement! (Css "h1")?
#
#     when maybeElement is
#         Found el ->
#             el |> Assert.elementShouldHaveText! "Example"
#
#         NotFound ->
#             Assert.failWith "element should have been found"
#
# test29 = test "tryFindElement empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#     maybeElement = browser |> Browser.tryFindElement! (Css "#fake-id")?
#
#     when maybeElement is
#         Found _ -> Assert.failWith "element should not have beed found"
#         NotFound ->
#             Task.ok {}
#
# test30 = test "findSingleElement empty" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     result = browser |> Browser.findSingleElement! (Css "#fake-id")
#
#     when result is
#         Ok _ -> Assert.failWith "should not find any elements"
#         Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found"
#         Err _ -> Assert.failWith "wrong error type"
#
# test31 = test "findSingleElement to many" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     result = browser |> Browser.findSingleElement! (Css "option")
#
#     when result is
#         Ok _ -> Assert.failWith "should find more than 1 element"
#         Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
#         Err _ -> Assert.failWith "wrong error type"
#
# test32 = test "findSingleElement" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     button = browser |> Browser.findSingleElement! (Css "#populate")?
#
#     button |> Assert.elementShouldHaveValue! "Populate"
#
# test33 = test "findElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     header = browser |> Browser.findElement! (Css "header")?
#
#     h1 = header |> Element.findElement! (Css "h1")?
#
#     text = h1 |> Element.getText!?
#
#     text |> Assert.shouldBe "Example"
#
# test34 = test "findElements in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     selectElement = browser |> Browser.findElement! (Css "select")?
#
#     options = selectElement |> Element.findElements! (Css "option")?
#
#     options |> Assert.shouldHaveLength! 3?
#
#     element1 = options |> List.get 0?
#     element1 |> Assert.elementShouldHaveText! "Command Line"?
#
#     element2 = options |> List.get 1?
#     element2 |> Assert.elementShouldHaveText! "JavaScript API"?
#
#     element3 = options |> List.get 2?
#     element3 |> Assert.elementShouldHaveText! "Both"
#
# test35 = test "findElements empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     header = browser |> Browser.findElement! (Css "header")?
#
#     emptyList = header |> Element.findElements! (Css "#fake-id")?
#
#     emptyList |> Assert.shouldHaveLength! 0
#
# test36 = test "tryFindElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     header = browser |> Browser.findElement! (Css "header")?
#
#     maybeElement = header |> Element.tryFindElement! (Css "h1")?
#
#     when maybeElement is
#         Found el ->
#             el |> Assert.elementShouldHaveText! "Example"
#
#         NotFound ->
#             Assert.failWith "element should have been found"
#
# test37 = test "tryFindElement empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     header = browser |> Browser.findElement! (Css "header")?
#
#     maybeElement = header |> Element.tryFindElement! (Css "#fake-id")?
#
#     when maybeElement is
#         Found _ -> Assert.failWith "element should not have beed found"
#         NotFound ->
#             Task.ok {}
#
# test38 = test "findSingleElement empty in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     header = browser |> Browser.findElement! (Css "header")?
#
#     result = header |> Element.findSingleElement! (Css "#fake-id")
#
#     when result is
#         Ok _ -> Assert.failWith "should not find any elements"
#         Err (ElementNotFound err) -> err |> Assert.shouldBe "element with selector #fake-id was not found in element (Css \"header\")"
#         Err _ -> Assert.failWith "wrong error type"
#
# test39 = test "findSingleElement to many in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     selectElement = browser |> Browser.findElement! (Css "select")?
#
#     result = selectElement |> Element.findSingleElement! (Css "option")
#
#     when result is
#         Ok _ -> Assert.failWith "should find more than 1 element"
#         Err (AssertionError err) -> err |> Assert.shouldBe "expected to find only 1 element with selector \"option\", but found 3"
#         Err _ -> Assert.failWith "wrong error type"
#
# test40 = test "findSingleElement in element" \browser ->
#     browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"?
#
#     rocBox = browser |> Browser.findElement! (Css ".row")?
#
#     button = rocBox |> Element.findSingleElement! (Css "#populate")?
#
#     button |> Assert.elementShouldHaveValue! "Populate"
#
# test41 = test "isVisible" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"?
#
#     button = browser |> Browser.findElement! (Css "#show-opacity")?
#     isButtonVisible = button |> Element.isVisible!?
#     isButtonVisible |> Assert.shouldBe Visible?
#
#     opacityHidden = browser |> Browser.findElement! (Css ".hide-by-opacity")?
#     isOpacityHiddenVisible = opacityHidden |> Element.isVisible!?
#     isOpacityHiddenVisible |> Assert.shouldBe NotVisible?
#
#     displayHidden = browser |> Browser.findElement! (Css ".hide-by-display")?
#     isDisplayHiddenVisible = displayHidden |> Element.isVisible!?
#     isDisplayHiddenVisible |> Assert.shouldBe NotVisible
#
# test42 = test "getTagName" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"?
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity")?
#
#     buttonTag = button1 |> Element.getTagName!?
#
#     buttonTag |> Assert.shouldBe "button"
#
# test43 = test "getCss" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"?
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity")?
#
#     border = button1 |> Element.getCssProperty! "border"?
#     border |> Assert.shouldBe! "2px solid rgb(0, 0, 0)"?
#
#     empty = button1 |> Element.getCssProperty! "jfkldsajflksadjlfk"?
#     empty |> Assert.shouldBe ""
#
# test44 = test "getRect" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/waiting"?
#
#     button1 = browser |> Browser.findElement! (Css "#show-opacity")?
#
#     buttonRect = button1 |> Element.getRect!?
#
#     buttonRect.height |> Assert.shouldBe 51?
#     buttonRect.width |> Assert.shouldBe 139?
#     buttonRect.x |> Assert.shouldBeEqualTo 226?
#     buttonRect.y |> Assert.shouldBeEqualTo 218.3593754
#
# test45 = test "iframe" \browser ->
#     browser |> Browser.navigateTo! "https://adomurad.github.io/e2e-test-page/iframe"?
#
#     frameEl = browser |> Browser.findElement! (Css "iframe")?
#     try Element.useIFrame! frameEl \frame ->
#         span = frame |> Browser.findElement! (Css "#span-inside-frame")?
#         span |> Assert.elementShouldHaveText! "This is inside an iFrame"
#
#     outsideSpan = browser |> Browser.findElement! (Css "#span-outside-frame")?
#     outsideSpan |> Assert.elementShouldHaveText! "Outside frame"?
#
#     try Element.useIFrame! frameEl \frame ->
#         span = frame |> Browser.findElement! (Css "#span-inside-frame")?
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
