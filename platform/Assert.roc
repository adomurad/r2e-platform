## `Assert` module contains assertion functions to check properties of `Elements`
## and data extracted from the browser.
##
## All assert functions return a `Try` with the `[AssertionError(Str)]` error.
import Browser
import Element
import Debug
import DebugMode
import Utils

Assert :: [].{

	## Checks if the value of __actual__ is equal to the __expected__.
	should_be : a, a -> Try({}, [AssertionError(Str)]) where [a.is_eq : a, a -> Bool]
	should_be = |actual, expected| {
		if expected == actual {
			Ok({})
		} else {
			actual_str = Str.inspect(actual)
			expected_str = Str.inspect(expected)
			Err(AssertionError("Expected ${expected_str}, but got ${actual_str}"))
		}
	}

	## Checks if the value of __actual__ contains the `Str` __expected__.
	should_contain_text : Str, Str -> Try({}, [AssertionError(Str)])
	should_contain_text = |actual, expected|
		if actual.contains(expected) {
			Ok({})
		} else {
			Err(AssertionError("Expected \"${actual}\" to contain text \"${expected}\""))
		}

	## Checks if the value of __actual__ is equal to the __expected__.
	##
	## Used to compare `F64` numbers.
	should_be_equal_to : F64, F64 -> Try({}, [AssertionError(Str)])
	should_be_equal_to = |actual, expected| {
		if F64.is_approx_eq(actual, expected, { rel: 0.000001, abs: 0.000001 }) {
			Ok({})
		} else {
			actual_str = actual.to_str()
			expected_str = expected.to_str()
			Err(AssertionError("Expected ${expected_str}, but got ${actual_str}"))
		}
	}

	## Checks if the __actual__ `Num` is greater than the __expected__.
	should_be_greater_than : a, a -> Try({}, [AssertionError(Str)]) where [a.is_gt : a, a -> Bool, a.to_str : a -> Str]
	should_be_greater_than = |actual, expected|
		if actual > expected {
			Ok({})
		} else {
			actual_str = actual.to_str()
			expected_str = expected.to_str()
			Err(AssertionError("Expected (value > ${expected_str}), but got ${actual_str}"))
		}

	## Checks if the __actual__ `Num` is greater or equal than the __expected__.
	should_be_greater_or_equal_to : a, a -> Try({}, [AssertionError(Str)]) where [a.is_gte : a, a -> Bool, a.to_str : a -> Str]
	should_be_greater_or_equal_to = |actual, expected|
		if actual >= expected {
			Ok({})
		} else {
			actual_str = actual.to_str()
			expected_str = expected.to_str()
			Err(AssertionError("Expected (value >= ${expected_str}), but got ${actual_str}"))
		}

	## Checks if the __actual__ `Num` is lesser than the __expected__.
	should_be_lesser_than : a, a -> Try({}, [AssertionError(Str)]) where [a.is_lt : a, a -> Bool, a.to_str : a -> Str]
	should_be_lesser_than = |actual, expected|
		if actual < expected {
			Ok({})
		} else {
			actual_str = actual.to_str()
			expected_str = expected.to_str()
			Err(AssertionError("Expected (value < ${expected_str}), but got ${actual_str}"))
		}

	## Checks if the __actual__ `Num` is lesser or equal than the __expected__.
	should_be_lesser_or_equal_to : a, a -> Try({}, [AssertionError(Str)]) where [a.is_lte : a, a -> Bool, a.to_str : a -> Str]
	should_be_lesser_or_equal_to = |actual, expected|
		if actual <= expected {
			Ok({})
		} else {
			actual_str = actual.to_str()
			expected_str = expected.to_str()
			Err(AssertionError("Expected (value <= ${expected_str}), but got ${actual_str}"))
		}

	## Checks if the URL is equal to the __expected__.
	##
	## This function will wait for the expectation to be met,
	## for the **assert_timeout** specified in test options - default: 3s.
	url_should_be! : Browser, Str => Try({}, [AssertionError(Str), WebDriverError(Str)])
	url_should_be! = |browser, expected| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Assert: Waiting for the URL to be \"${expected}\""),
		)

		assert_timeout = Utils.get_assert_timeout!({})

		try_for!(
			assert_timeout,
			|{}| {
				match browser.get_url!() {
					Ok(actual) =>
						if expected == actual {
							Ok({})
						} else {
							Err(AssertionError("Expected the URL to be \"${expected}\", but got \"${actual}\" (waited for ${assert_timeout.to_str()}ms)"))
						}

					Err(err) => Err(err),
				}
			},
		)
	}

	## Checks if the page title is equal to the __expected__.
	##
	## This function will wait for the expectation to be met,
	## for the **assert_timeout** specified in test options - default: 3s.
	title_should_be! : Browser, Str => Try({}, [AssertionError(Str), WebDriverError(Str)])
	title_should_be! = |browser, expected| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Assert: Waiting for the page title to be \"${expected}\""),
		)

		assert_timeout = Utils.get_assert_timeout!({})

		try_for!(
			assert_timeout,
			|{}| {
				actual = browser.get_title!()?

				if expected == actual {
					Ok({})
				} else {
					Err(AssertionError("Expected the page title to be \"${expected}\", but got \"${actual}\" (waited for ${assert_timeout.to_str()}ms)"))
				}
			},
		)
	}

	## Fails with given error message.
	fail_with : Str -> Try({}, [AssertionError(Str)])
	fail_with = |msg|
		Err(AssertionError(msg))

	## Checks if the length of __list__ is equal to the __expected__ length.
	should_have_length : List(a), U64 -> Try({}, [AssertionError(Str)])
	should_have_length = |list, expected| {
		actual_len = list.len()

		if actual_len == expected {
			Ok({})
		} else {
			actual_len_str = actual_len.to_str()
			expected_len_str = expected.to_str()
			actual_elements_word = pluralize(actual_len, "element", "elements")
			expected_elements_word = pluralize(actual_len, "element", "elements")

			Err(AssertionError("Expected a list with ${actual_len_str} ${actual_elements_word}, but got ${expected_len_str} ${expected_elements_word}"))
		}
	}

	pluralize : U64, a, a -> a
	pluralize = |count, singular, plural|
		if count == 1 {
			singular
		} else {
			plural
		}

	## Checks if the `Element` has __expected__ text.
	##
	## This function will wait for the `Element` to meet the expectation,
	## for the **assert_timeout** specified in test options - default: 3s.
	element_should_have_text! : Element, Str => Try({}, [AssertionError(Str), ElementNotFound(Str), WebDriverError(Str)])
	element_should_have_text! = |element, expected_text| {
		selector_text = element.selector_text

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Assert: Waiting for element ${selector_text} to have text: \"${expected_text}\""),
		)

		assert_timeout = Utils.get_assert_timeout!({})

		try_for!(
			assert_timeout,
			|{}| {
				element_text = element.get_text!()?

				if expected_text == element_text {
					Ok({})
				} else {
					Err(AssertionError("Expected element ${selector_text} to have text \"${expected_text}\", but got \"${element_text}\" (waited for ${assert_timeout.to_str()}ms)"))
				}
			},
		)
	}

	## Checks if the `Element` has __expected__ value.
	##
	## This function will wait for the `Element` to meet the expectation,
	## for the **assert_timeout** specified in test options - default: 3s.
	element_should_have_value! : Element, Str => Try({}, [AssertionError(Str), ElementNotFound(Str), WebDriverError(Str), PropertyTypeError(Str)])
	element_should_have_value! = |element, expected_value| {
		selector_text = element.selector_text

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Assert: Waiting for element ${selector_text} to have value: \"${expected_value}\""),
		)

		assert_timeout = Utils.get_assert_timeout!({})

		try_for!(
			assert_timeout,
			|{}| {
				element_value = element.get_property!("value")?

				if expected_value == element_value {
					Ok({})
				} else {
					Err(AssertionError("Expected element ${selector_text} to have value \"${expected_value}\", but got \"${element_value}\" (waited for ${assert_timeout.to_str()}ms)"))
				}
			},
		)
	}

	## Checks if the `Element` is visible in the `Browser`.
	##
	## This function will wait for the `Element` to meet the expectation,
	## for the **assert_timeout** specified in test options - default: 3s.
	element_should_be_visible! : Element => Try({}, [AssertionError(Str), ElementNotFound(Str), WebDriverError(Str)])
	element_should_be_visible! = |element| {
		selector_text = element.selector_text

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Assert: Waiting for element ${selector_text} to visible"),
		)

		assert_timeout = Utils.get_assert_timeout!({})

		try_for!(
			assert_timeout,
			|{}| {
				is_visible = element.is_visible!()?

				match is_visible {
					Visible => Ok({})
					NotVisible => Err(AssertionError("Expected element ${selector_text} to be visible (waited for ${assert_timeout.to_str()}ms)")),
				}
			},
		)
	}

	try_for! : U64, ({} => Try(ok, err)) => Try({}, err)
	try_for! = |timeout, task!| {
		start_time = Utils.get_time_milis!({})

		loop!(
			|{}| {
				result = task!({})
				match result {
					Ok(_) => Done(Ok({}))
					Err(err) => {
						now = Utils.get_time_milis!({})
						if now - start_time >= timeout {
							Done(Err(err))
						} else {
							Debug.wait!(100)
							Step
						}
					}
				}
			},
		)
	}

	loop! : ({} => [Done(a), Step]) => a
	loop! = |callback!|
		match callback!({}) {
			Done(res) => res
			Step => loop!(callback!)
		}
}
