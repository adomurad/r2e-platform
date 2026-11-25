import Host
import PropertyDecoder
import Locator
import InternalError
import DebugMode
import Error

## `Element` module contains functions to interact with `Elements`
## found in the `Browser`.
Element := {
	session_id : Str,
	element_id : Str,
	# used to provide better context in Asserts
	selector_text : Str,
	locator : Locator,
}.{

	## Click on a `Element`.
	##
	## ```
	## button = browser.find_element!(Css("#submit-button"))?
	## button.click!()?
	## ```
	click! : Element => Try({}, [WebDriverError(Str), ElementNotFound(Str)])
	click! = |element| {
		{ session_id, element_id, locator, selector_text } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Trying to click element: ${selector_text}"),
		)

		Host.element_click!(session_id, element_id).map_err(InternalError.handle_element_error)?

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Element clicked: ${selector_text}"),
		)

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Click Element ${selector_text}")?
				DebugMode.flash_elements!(session_id, locator, Single)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		Ok({})
	}

	## Get text of the `Element`.
	##
	## This function will return the displayed text in the `Browser` for this `Element` and it's children.
	##
	## When the `Element` is not visible, then the text will be an empty `Str`.
	get_text! : Element => Try(Str, [WebDriverError(Str), ElementNotFound(Str)])
	get_text! = |element| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting element text: ${selector_text}"),
		)

		Host.element_get_text!(session_id, element_id).map_err(InternalError.handle_element_error)
	}

	## Get **value** of the `Element`.
	##
	## When there is no **value** in this element then returns the default value for used type:
	## - `Str` - ""
	## - `Bool` - False
	## - `Num` - 0
	get_value! : Element => Try(a, [ElementNotFound(Str), PropertyTypeError(Str), WebDriverError(Str)])
		where [a.PropertyDecoder.Parseable(PropertyDecoder.PropertyError)]
	get_value! = |element| {
		get_property!(element, "value")
	}

	## Check if `Element` is selected.
	##
	## Can be used on checkbox inputs, radio inputs, and option elements.
	is_selected! : Element => Try([Selected, NotSelected], [WebDriverError(Str), ElementNotFound(Str)])
	is_selected! = |element| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Checking if element is selected: ${selector_text}"),
		)

		result = Host.element_is_selected!(session_id, element_id).map_err(InternalError.handle_element_error)?

		if result == "true" {
			Ok(Selected)
		} else {
			Ok(NotSelected)
		}
	}

	## Check if `Element` is visible in the `Browser`.
	is_visible! : Element => Try([Visible, NotVisible], [WebDriverError(Str), ElementNotFound(Str)])
	is_visible! = |element| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Checking if element is visible: ${selector_text}"),
		)

		result = Host.element_is_displayed!(session_id, element_id).map_err(InternalError.handle_element_error)?

		if result == "true" {
			Ok(Visible)
		} else {
			Ok(NotVisible)
		}
	}

	## Get **attribute** of an `Element`.
	##
	## When the **attribute** is not present on the `Element`, this function will return empty `Str`.
	get_attribute! : Element, Str => Try(Str, [WebDriverError(Str), ElementNotFound(Str)])
	get_attribute! = |element, attribute_name| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting attribute \"${attribute_name}\" for element: ${selector_text}"),
		)

		Host.element_get_attribute!(session_id, element_id, attribute_name)
			.map_err(InternalError.handle_element_error)
	}

	## Get **attribute** of an `Element`, returning `Err(Empty)` when it is not present.
	get_attribute_or_empty! : Element, Str => Try(Try(Str, [Empty]), [WebDriverError(Str), ElementNotFound(Str)])
	get_attribute_or_empty! = |element, attribute_name| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting attribute \"${attribute_name}\" for element: ${selector_text}"),
		)

		result = Host.element_get_attribute!(session_id, element_id, attribute_name)
			.map_err(InternalError.handle_element_error)?

		if result == "" {
			Ok(Err(Empty))
		} else {
			Ok(Ok(result))
		}
	}

	## Get **property** of an `Element`.
	##
	## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
	## R2E will try to cast the browser response to the choosen type.
	get_property! : Element, Str => Try(a, [ElementNotFound(Str), PropertyTypeError(Str), WebDriverError(Str)])
		where [a.PropertyDecoder.Parseable(PropertyDecoder.PropertyError)]
	get_property! = |element, property_name| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting property \"${property_name}\" for element: ${selector_text}"),
		)

		result_str = Host.element_get_property!(session_id, element_id, property_name)
			.map_err(InternalError.handle_element_error)?

		match PropertyDecoder.parse(result_str) {
			Ok(val) => Ok(val)
			Err(_) => Err(PropertyTypeError("could not cast property \"${property_name}\" with value \"${result_str}\" to expected type"))
		}
	}

	## Get **property** of an `Element`, returning `Err(Empty)` when it does not exist.
	get_property_or_empty! : Element, Str => Try(Try(a, [Empty]), [WebDriverError(Str), ElementNotFound(Str), PropertyTypeError(Str)])
		where [a.PropertyDecoder.Parseable(PropertyDecoder.PropertyError)]
	get_property_or_empty! = |element, property_name| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting property \"${property_name}\" for element: ${selector_text}"),
		)

		result_str = Host.element_get_property!(session_id, element_id, property_name)
			.map_err(InternalError.handle_element_error)?

		if result_str == "" {
			Ok(Err(Empty))
		} else {
			match PropertyDecoder.parse(result_str) {
				Ok(val) => Ok(Ok(val))
				Err(_) => Err(PropertyTypeError("could not cast property \"${property_name}\" with value \"${result_str}\" to expected type"))
			}
		}
	}

	## Send a `Str` to a `Element` (e.g. put text into an input).
	##
	## Special key sequences:
	##
	## `{enter}` - simulates an "enter" key press
	input_text! : Element, Str => Try({}, [WebDriverError(Str), ElementNotFound(Str)])
	input_text! = |element, str| {
		Element.{ session_id, element_id, selector_text, locator, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Sending text \"${str}\" to element: ${selector_text}"),
		)

		Host.element_send_keys!(session_id, element_id, str).map_err(InternalError.handle_element_error)?

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Element received text: ${selector_text}"),
		)

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Send Text ${selector_text}")?
				DebugMode.flash_elements!(session_id, locator, Single)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		Ok({})
	}

	## Clear an editable or resetable `Element`.
	clear! : Element => Try({}, [WebDriverError(Str), ElementNotFound(Str)])
	clear! = |element| {
		Element.{ session_id, element_id, selector_text, locator, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Clearing element: ${selector_text}"),
		)

		Host.element_clear!(session_id, element_id).map_err(InternalError.handle_element_error)?

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Element cleared: ${selector_text}"),
		)

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Clear Element ${selector_text}")?
				DebugMode.flash_elements!(session_id, locator, Single)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		Ok({})
	}

	## Find an `Element` inside the tree of another `Element` in the `Browser`.
	##
	## When there are more than 1 elements, then the first will be returned.
	find_element! : Element, Locator => Try(Element, [WebDriverError(Str), ElementNotFound(Str)])
	find_element! = |element, locator| {
		Element.{ session_id, element_id, .. } = element
		(using, value) = Locator.get_locator(locator)

		selector_text = "${Str.inspect(locator)}"

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Searching for element: ${selector_text}"),
		)

		new_element_id = Host.element_find_element!(session_id, element_id, using, value)
			.map_err(InternalError.handle_element_error)?

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Found element: ${selector_text}"),
		)

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Find Element ${selector_text}")?
				DebugMode.flash_elements!(session_id, locator, Single)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		Ok({ session_id, element_id: new_element_id, selector_text, locator })
	}

	## Find an `Element` inside the tree of another `Element`.
	##
	## This function returns a `[Found(Element), NotFound]` instead of an error
	## when element is not found.
	try_find_element! : Element, Locator => Try([Found(Element), NotFound], [WebDriverError(Str), ElementNotFound(Str)])
	try_find_element! = |element, locator| {
		find_element!(element, locator)
			.map_ok(|el| Found(el))
			.on_err(
				|err|
					match err {
						ElementNotFound(_) => Ok(NotFound)
						other => Err(other)
					},
			)
	}

	## Find an `Element` inside the tree of another `Element` in the `Browser`.
	##
	## This function will fail if the element is not found - `ElementNotFound Str`
	##
	## This function will fail if there are more than 1 element - `AssertionError Str`
	find_single_element! : Element, Locator => Try(Element, [AssertionError(Str), ElementNotFound(Str), WebDriverError(Str)])
	find_single_element! = |element, locator| {
		Element.{ selector_text: parent_element_selector_text, .. } = element
		elements = find_elements!(element, locator)?

		match elements.len() {
			0 => {
				(_, value) = Locator.get_locator(locator)
				Err(ElementNotFound("element with selector ${value} was not found in element ${parent_element_selector_text}"))
			}

			1 => {
				match elements {
					[only] => Ok(only)
					_ => crash "just checked - there is 1 element in the list"
				}
			}

			n => {
				(_, value) = Locator.get_locator(locator)
				Err(AssertionError("expected to find only 1 element with selector \"${value}\", but found ${n.to_str()}"))
			}
		}
	}

	## Find all `Elements` inside the tree of another `Element`.
	##
	## When there are no elements found, then the list will be empty.
	find_elements! : Element, Locator => Try(List(Element), [WebDriverError(Str), ElementNotFound(Str)])
	find_elements! = |element, locator| {
		Element.{ session_id, element_id: parent_element_id, .. } = element
		(using, value) = Locator.get_locator(locator)

		selector_text = "${Str.inspect(locator)}"

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Searching for elements: ${selector_text}"),
		)

		result = Host.element_find_elements!(session_id, parent_element_id, using, value)
			.map_err(InternalError.handle_element_error)

		match result {
			Ok(element_ids) => {
				DebugMode.run_if_verbose!(
					|{}|
						Host.stdout_line!("Found ${element_ids.len().to_str()} elements: ${selector_text}"),
				)

				DebugMode.run_if_debug_mode!(
					|{}| {
						if element_ids.is_empty() {
							Ok({})
						} else {
							DebugMode.show_debug_message_in_browser!(session_id, "Find Elements ${selector_text}")?
							DebugMode.flash_elements!(session_id, locator, All)?
							DebugMode.wait!({})
							Ok({})
						}
					},
				)

				element_ids
					.map(|element_id| { session_id, element_id, selector_text, locator })
					|> Ok
			}

			Err(ElementNotFound(_)) => Ok([])
			Err(err) => Err(err)
		}
	}

	## Get the HTML tag name of an `Element`.
	get_tag_name! : Element => Try(Str, [WebDriverError(Str), ElementNotFound(Str)])
	get_tag_name! = |element| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting tag name for element: ${selector_text}"),
		)

		Host.element_get_tag!(session_id, element_id).map_err(InternalError.handle_element_error)
	}

	## Get a **css property** of an `Element`.
	get_css_property! : Element, Str => Try(Str, [WebDriverError(Str), ElementNotFound(Str)])
	get_css_property! = |element, css_property| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting CSS property \"${css_property}\" for element: ${selector_text}"),
		)

		Host.element_get_css!(session_id, element_id, css_property)
			.map_err(InternalError.handle_element_error)
	}

	ElementRect : {
		x : F64,
		y : F64,
		width : U32,
		height : U32,
	}

	## Get the position and size of the `Element`.
	get_rect! : Element => Try(ElementRect, [WebDriverError(Str), ElementNotFound(Str)])
	get_rect! = |element| {
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Getting the rect for element: ${selector_text}"),
		)

		Host.element_get_rect!(session_id, element_id)
			.map_err(InternalError.handle_element_error)
			.map_ok(
				|list|
					match list {
						[x_val, y_val, width_val, height_val] => {
							x: x_val,
							y: y_val,
							width: width_val.round_to_u32_try() ?? 0,
							height: height_val.round_to_u32_try() ?? 0,
						}
						_ => crash "the contract with host should not fail"
					},
			)
	}

	## Switch the context to an iFrame.
	##
	## This function runs a callback in which you can interact
	## with the page inside an iFrame.
	##
	## ```
	## frame_el = browser.find_element!(Css("iframe"))?
	## frame_el.use_iframe!(|frame|
	##     span = frame.find_element!(Css("#span-inside-frame"))?
	##     span |> Assert.element_should_have_text!("This is inside an iFrame")?
	## )
	## ```
	use_iframe! : Element, (b => Try({}, Error.PlatformError)) => Try({}, Error.PlatformError)
		where [b.from_session_id : Str -> b]
	use_iframe! = |element, callback!| {
		B : b
		Element.{ session_id, element_id, selector_text, .. } = element

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Switching context to iFrame: ${selector_text}"),
		)

		Host.switch_to_frame_by_element_id!(session_id, element_id)
			.map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Switched to iFrame ${selector_text}")?
				DebugMode.flash_current_frame!(session_id)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		browser = B.from_session_id(session_id)
		result = callback!(browser)

		DebugMode.run_if_verbose!(
			|{}|
				Host.stdout_line!("Switching back to iFrame parent"),
		)

		Host.switch_to_parent_frame!(session_id)
			.map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}| {
				DebugMode.show_debug_message_in_browser!(session_id, "Switched back to iFrame parent")?
				DebugMode.flash_current_frame!(session_id)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		result
	}
}
