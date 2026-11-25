app [config, test_cases] { r2e: platform "../platform/main.roc" }

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
	test41,
	test42,
	test43,
	test44,
	test45,
	test46,
]

test1 = test(
	"findElement and getText",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		h1 = browser.find_element!(Css("h1"))?

		text = h1.get_text!()?

		text |> Assert.should_be("Example fake")
	},
)

test2 = test(
	"clickElement and check if selected",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		is_selected = checkbox.is_selected!()?
		is_selected |> Assert.should_be(NotSelected)?

		checkbox.click!()?

		is_selected2 = checkbox.is_selected!()?
		is_selected2 |> Assert.should_be(Selected)
	},
)

test3 = test(
	"getAttribute empty",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value = checkbox.get_attribute!("fake-attr")?
		empty_value |> Assert.should_be("")
	},
)

test4 = test(
	"getAttribute Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		checkbox_type = checkbox.get_attribute!("type")?
		checkbox_type |> Assert.should_be("checkbox")
	},
)

test5 = test(
	"getAttributeOrEmpty empty",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value = checkbox.get_attribute_or_empty!("fake-attr")?
		match empty_value {
			Ok(_) => {
				Assert.fail_with("should not have a value")
			}
			Err(Empty) => {
				Ok({})
			}
		}
	},
)

test6 = test(
	"getAttributeOrEmpty Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		checkbox_type = checkbox.get_attribute_or_empty!("type")?
		match checkbox_type {
			Ok(type) => {
				type |> Assert.should_be("checkbox")
			}
			Err(Empty) => {
				Assert.fail_with("should not be empty")
			}
		}
	},
)

test7 = test(
	"getProperty empty to Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value = checkbox.get_property!("fake-prop")?
		empty_value |> Assert.should_be("")
	},
)

test8 = test(
	"getProperty empty to Bool",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value : Bool
		empty_value = checkbox.get_property!("fake-prop")?
		empty_value |> Assert.should_be(False)
	},
)

test9 = test(
	"getProperty empty to I64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value : I64
		empty_value = checkbox.get_property!("fake-prop")?
		empty_value |> Assert.should_be(0.I64)
	},
)

test10 = test(
	"getProperty empty to U64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value : U64
		empty_value = checkbox.get_property!("fake-prop")?
		empty_value |> Assert.should_be(0.U64)
	},
)

test11 = test(
	"getProperty empty to F64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		empty_value : F64
		empty_value = checkbox.get_property!("fake-prop")?
		empty_value |> Assert.should_be_equal_to(0.F64)
	},
)

test12 = test(
	"getProperty Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value = checkbox.get_property!("value")?
		value |> Assert.should_be("on")
	},
)

test13 = test(
	"getProperty boolean to Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		checkbox.click!()?

		value = checkbox.get_property!("checked")?
		value |> Assert.should_be("true")
	},
)

test14 = test(
	"getProperty number to Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value = checkbox.get_property!("clientHeight")?
		value |> Assert.should_be("13")
	},
)

test15 = test(
	"getProperty number to I64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value = checkbox.get_property!("clientHeight")?
		value |> Assert.should_be(13)
	},
)

test16 = test(
	"getProperty number to F64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value = checkbox.get_property!("clientHeight")?
		value |> Assert.should_be_equal_to(13.F64)
	},
)

test17 = test(
	"getProperty Bool",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		checkbox.click!()?

		value : Bool
		value = checkbox.get_property!("checked")?
		value |> Assert.should_be(True)
	},
)

test18 = test(
	"getProperty number to Bool decoding error",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		checkbox.click!()?

		result : Try(Bool, _)
		result = checkbox.get_property!("clientHeight")

		match result {
			Ok(_) => {
				Assert.fail_with("shold not be ok")
			}
			Err(PropertyTypeError(err)) => {
				err |> Assert.should_be("could not cast property \"clientHeight\" with value \"13\" to expected type")
			}
			Err(_) => {
				Assert.fail_with("wrong error tag")
			}
		}
	},
)

test19 = test(
	"getPropertyOrEmpty Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value = checkbox.get_property_or_empty!("value")?

		match value {
			Ok(val) => {
				val |> Assert.should_be("on")
			}
			Err(_) => {
				Assert.fail_with("should be ok")
			}
		}
	},
)

test20 = test(
	"getPropertyOrEmpty empty to Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		checkbox = browser.find_element!(TestId("remote-testing-checkbox"))?

		value : Try(Str, _)
		value = checkbox.get_property_or_empty!("fake-prop")?

		match value {
			Ok(_) => {
				Assert.fail_with("should not be ok")
			}
			Err(Empty) => {
				Ok({})
			}
		}
	},
)

test21 = test(
	"inputText and getValue Str",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		input = browser.find_element!(TestId("name-input"))?

		value = input.get_value!()?
		value |> Assert.should_be("")?

		input.input_text!("roc")?

		value2 = input.get_value!()?
		value2 |> Assert.should_be("roc")
	},
)

test22 = test(
	"inputText and getValue F64",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		input = browser.find_element!(TestId("name-input"))?

		value = input.get_value!()?
		_ = value |> Assert.should_be("")?

		input.input_text!("15.18")?

		value2 = input.get_value!()?
		value2 |> Assert.should_be_equal_to(15.18.F64)
	},
)

test23 = test(
	"inputText and getValue Bool",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		input = browser.find_element!(TestId("name-input"))?

		value = input.get_value!()?
		value |> Assert.should_be("")?

		input.input_text!("true")?

		value2 : Bool
		value2 = input.get_value!()?
		value2 |> Assert.should_be(True)
	},
)

test24 = test(
	"inputText {enter}",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		input = browser.find_element!(TestId("name-input"))?

		input.input_text!("test{enter}")?

		thank_you_header = browser.find_element!(TestId("thank-you-header"))?
		text = thank_you_header.get_text!()?
		text |> Assert.should_be("Thank you, test!")
	},
)

test25 = test(
	"clearElement",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		input = browser.find_element!(TestId("name-input"))?

		value = input.get_value!()?
		value |> Assert.should_be("")?

		input.input_text!("test")?

		value2 = input.get_value!()?
		value2 |> Assert.should_be("test")?

		input.clear!()?

		value3 = input.get_value!()?
		value3 |> Assert.should_be("")
	},
)

test26 = test(
	"findElements",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		options = browser.find_elements!(Css("option"))?

		options |> Assert.should_have_length(3)?

		element1 = options |> List.get(0)?
		element1 |> Assert.element_should_have_text!("Command Line")?

		element2 = options |> List.get(1)?
		element2 |> Assert.element_should_have_text!("JavaScript API")?

		element3 = options |> List.get(2)?
		element3 |> Assert.element_should_have_text!("Both")
	},
)

test27 = test(
	"findElements empty",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		empty_list = browser.find_elements!(Css("#fake-id"))?

		empty_list |> Assert.should_have_length(0)
	},
)

test28 = test(
	"tryFindElement",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		maybe_element = browser.try_find_element!(Css("h1"))?

		match maybe_element {
			Found(el) => {
				el |> Assert.element_should_have_text!("Example")
			}
			NotFound => {
				Assert.fail_with("element should have been found")
			}
		}
	},
)

test29 = test(
	"tryFindElement empty",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?
		maybe_element = browser.try_find_element!(Css("#fake-id"))?

		match maybe_element {
			Found(_) => {
				Assert.fail_with("element should not have beed found")
			}
			NotFound => {
				Ok({})
			}
		}
	},
)

test30 = test(
	"findSingleElement empty",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		result = browser.find_single_element!(Css("#fake-id"))

		match result {
			Ok(_) => {
				Assert.fail_with("should not find any elements")
			}
			Err(ElementNotFound(err)) => {
				err |> Assert.should_be("element with selector #fake-id was not found")
			}
			Err(_) => {
				Assert.fail_with("wrong error type")
			}
		}
	},
)

test31 = test(
	"findSingleElement to many",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		result = browser.find_single_element!(Css("option"))

		match result {
			Ok(_) => {
				Assert.fail_with("should find more than 1 element")
			}
			Err(AssertionError(err)) => {
				err |> Assert.should_be("expected to find only 1 element with selector \"option\", but found 3")
			}
			Err(_) => {
				Assert.fail_with("wrong error type")
			}
		}
	},
)

test32 = test(
	"findSingleElement",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		button = browser.find_single_element!(Css("#populate"))?

		button |> Assert.element_should_have_value!("Populate")
	},
)

test33 = test(
	"findElement in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		header = browser.find_element!(Css("header"))?

		h1 = header.find_element!(Css("h1"))?

		text = h1.get_text!()?

		text |> Assert.should_be("Example")
	},
)

test34 = test(
	"findElements in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		select_element = browser.find_element!(Css("select"))?

		options = select_element.find_elements!(Css("option"))?

		options |> Assert.should_have_length(3)?

		element1 = options |> List.get(0)?
		element1 |> Assert.element_should_have_text!("Command Line")?

		element2 = options |> List.get(1)?
		element2 |> Assert.element_should_have_text!("JavaScript API")?

		element3 = options |> List.get(2)?
		element3 |> Assert.element_should_have_text!("Both")
	},
)

test35 = test(
	"findElements empty in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		header = browser.find_element!(Css("header"))?

		empty_list = header.find_elements!(Css("#fake-id"))?

		empty_list |> Assert.should_have_length(0)
	},
)

test36 = test(
	"tryFindElement in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		header = browser.find_element!(Css("header"))?

		maybe_element = header.try_find_element!(Css("h1"))?

		match maybe_element {
			Found(el) => {
				el |> Assert.element_should_have_text!("Example")
			}
			NotFound => {
				Assert.fail_with("element should have been found")
			}
		}
	},
)

test37 = test(
	"tryFindElement empty in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		header = browser.find_element!(Css("header"))?

		maybe_element = header.try_find_element!(Css("#fake-id"))?

		match maybe_element {
			Found(_) => {
				Assert.fail_with("element should not have beed found")
			}
			NotFound => {
				Ok({})
			}
		}
	},
)

test38 = test(
	"findSingleElement empty in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		header = browser.find_element!(Css("header"))?

		result = header.find_single_element!(Css("#fake-id"))

		match result {
			Ok(_) => {
				Assert.fail_with("should not find any elements")
			}
			Err(ElementNotFound(err)) => {
				err |> Assert.should_be("element with selector #fake-id was not found in element Css(\"header\")")
			}
			Err(_) => {
				Assert.fail_with("wrong error type")
			}
		}
	},
)

test39 = test(
	"findSingleElement to many in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		select_element = browser.find_element!(Css("select"))?

		result = select_element.find_single_element!(Css("option"))

		match result {
			Ok(_) => {
				Assert.fail_with("should find more than 1 element")
			}
			Err(AssertionError(err)) => {
				err |> Assert.should_be("expected to find only 1 element with selector \"option\", but found 3")
			}
			Err(_) => {
				Assert.fail_with("wrong error type")
			}
		}
	},
)

test40 = test(
	"findSingleElement in element",
	|browser| {
		browser.navigate_to!("https://devexpress.github.io/testcafe/example/")?

		roc_box = browser.find_element!(Css(".row"))?

		button = roc_box.find_single_element!(Css("#populate"))?

		button |> Assert.element_should_have_value!("Populate")
	},
)

test41 = test(
	"isVisible",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

		button = browser.find_element!(Css("#show-opacity"))?
		is_button_visible = button.is_visible!()?
		is_button_visible |> Assert.should_be(Visible)?

		opacity_hidden = browser.find_element!(Css(".hide-by-opacity"))?
		is_opacity_hidden_visible = opacity_hidden.is_visible!()?
		is_opacity_hidden_visible |> Assert.should_be(NotVisible)?

		display_hidden = browser.find_element!(Css(".hide-by-display"))?
		is_display_hidden_visible = display_hidden.is_visible!()?
		is_display_hidden_visible |> Assert.should_be(NotVisible)
	},
)

test42 = test(
	"getTagName",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

		button1 = browser.find_element!(Css("#show-opacity"))?

		button_tag = button1.get_tag_name!()?

		button_tag |> Assert.should_be("button")
	},
)

test43 = test(
	"getCss",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

		button1 = browser.find_element!(Css("#show-opacity"))?

		border = button1.get_css_property!("border")?
		border |> Assert.should_be("2px solid rgb(0, 0, 0)")?

		empty = button1.get_css_property!("jfkldsajflksadjlfk")?
		empty |> Assert.should_be("")
	},
)

test44 = test(
	"getRect",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/waiting")?

		button1 = browser.find_element!(Css("#show-opacity"))?

		button_rect = button1.get_rect!()?

		button_rect.height |> Assert.should_be(51)?
		button_rect.width |> Assert.should_be(139)?
		button_rect.x |> Assert.should_be_equal_to(226)?
		button_rect.y |> Assert.should_be_equal_to(218.3593754)
	},
)

test45 = test(
	"iframe",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/iframe")?

		frame_el = browser.find_element!(Css("iframe"))?

		browser.use_iframe!(
			frame_el,
			|frame| {
				span = frame.find_element!(Css("#span-inside-frame"))?
				span |> Assert.element_should_have_text!("This is inside an iFrame")
			},
		)?

		outside_span = browser.find_element!(Css("#span-outside-frame"))?
		outside_span |> Assert.element_should_have_text!("Outside frame")?

		browser.use_iframe!(
			frame_el,
			|frame| {
				span = frame.find_element!(Css("#span-inside-frame"))?
				span |> Assert.element_should_have_text!("This is inside an iFrame")
			},
		)
	},
)

test46 = test(
	"iframe with error",
	|browser| {
		browser.navigate_to!("https://adomurad.github.io/e2e-test-page/iframe")?

		frameEl = browser.find_element!(Css("iframe"))?
		res =
			browser.use_iframe!(
				frameEl,
				|_frame| {
					Assert.fail_with("this failed")
				},
			)

		res |> Assert.should_be(Err(AssertionError("this failed")))?

		outsideSpan = browser.find_element!(Css("#span-outside-frame"))?
		outsideSpan |> Assert.element_should_have_text!("Outside frame")?

		browser.use_iframe!(
			frameEl,
			|frame| {
				span = frame.find_element!(Css("#span-inside-frame"))?
				span |> Assert.element_should_have_text!("This is inside an iFrame")
			},
		)
	},
)
