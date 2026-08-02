Assert :: [].{

## Checks if the value of __actual__ is equal to the __expected__.
##
## ```
## # find button element
## button = browser |> Browser.find_element!(Css "#submit-button")?
## # get button text
## buttonText = button |> Element.get_text!()?
## # assert text
## buttonText |> Assert.should_be("Roc")
## ```
should_be : a, a -> Try({} ,[AssertionError( Str )] where a implements Eq & Inspect)
should_be = |actual, expected|
    if expected == actual {
        Ok({})
    }else {
        actual_str = Inspect.to_str(actual)
        expected_str = Inspect.to_str(expected)
        Err(AssertionError("Expected ${expected_str}, but got ${actual_str}"))
    }

## Checks if the value of __actual__ contains the `Str` __expected__.
##
## ```
## "github" |> Assert.should_contain_text("git")
## ```
should_contain_text : Str, Str -> Try({} ,[AssertionError( Str )])
should_contain_text = |actual, expected| 
    if actual |> Str.contains(expected) {
        Ok({})
    }else{
        Err(AssertionError("Expected \"${actual}\" to contain text \"${expected}\""))
}

## Checks if the value of __actual__ is equal to the __expected__.
##
## Used to compare `Frac` numbers.
##
## ```
## # find button element
## button = browser |> Browser.find_element!(Css "#submit-button")?
## # get button text
## buttonSize = button |> Element.get_property!("size")?
## # assert value
## buttonSize |> Assert.should_be_equal_to(20f64)
## ```
should_be_equal_to : Frac a, Frac a -> Try({} ,[AssertionError( Str )])
should_be_equal_to = |actual, expected|
    if expected |> Num.is_approx_eq(actual, {}) {
        Ok({})
}else{
        actual_str = Num.to_str(actual)
        expected_str = Num.to_str(expected)
        Err(AssertionError("Expected ${expected_str}, but got ${actual_str}"))
}

## Checks if the __actual__ `Num` is grater than the __expected__.
##
## ```
## 3 |> Assert.should_be_greater_than(2)
## ```
should_be_greater_than : Num a, Num a -> Try({} ,[AssertionError( Str )] where a implements Bool.Eq)
should_be_greater_than = |actual, expected|
    if actual > expected {
        Ok({})
}else{
        actual_str = actual |> Num.to_str
        expected_str = expected |> Num.to_str
        Err(AssertionError("Expected (value > ${expected_str}), but got ${actual_str}"))
}

## Checks if the __actual__ `Num` is grater or equal than the __expected__.
##
## ```
## 3 |> Assert.should_be_greater_or_equal_to(2)
## ```
should_be_greater_or_equal_to : Num a, Num a -> Try({} ,[AssertionError( Str )] where a implements Bool.Eq)
should_be_greater_or_equal_to = |actual, expected|
    if actual >= expected {
        Ok({})
    }else{
        actual_str = actual |> Num.to_str
        expected_str = expected |> Num.to_str
        Err(AssertionError("Expected (value >= ${expected_str}), but got ${actual_str}"))
    }

## Checks if the __actual__ `Num` is grater than the __expected__.
##
## ```
## 3 |> Assert.should_be_lesser_than(2)
## ```
should_be_lesser_than : Num a, Num a -> Try({} ,[AssertionError( Str )] where a implements Bool.Eq)
should_be_lesser_than = |actual, expected|
    if actual < expected {
        Ok({})
    }else{
        actual_str = actual |> Num.to_str
        expected_str = expected |> Num.to_str
        Err(AssertionError("Expected (value < ${expected_str}), but got ${actual_str}"))
    }

## Checks if the __actual__ `Num` is grater or equal than the __expected__.
##
## ```
## 3 |> Assert.should_be_lesser_or_equal_to(2)
## ```
should_be_lesser_or_equal_to : Num a, Num a -> Try({} ,[AssertionError( Str )] where a implements Bool.Eq)
should_be_lesser_or_equal_to = |actual, expected|
    if actual <= expected {
        Ok({})
    }else{
        actual_str = actual |> Num.to_str
        expected_str = expected |> Num.to_str
        Err(AssertionError("Expected (value <= ${expected_str}), but got ${actual_str}"))
    }

## Checks if the __URL__ is equal to the __expected__.
##
## This function will wait for the expectation to be met,
## for the **assert_timeout** specified in test options - default: 3s.
## ```
## # assert text
## browser |> Assert.url_should_be!("https://roc-lang.org/")
## ```
url_should_be! : Browser, Str => Try({} ,[AssertionError( Str ), WebDriverError( Str )])
url_should_be! = |browser, expected|{
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Assert: Waiting for the URL to be \"${expected}\""),
    )

    assert_timeout = Utils.get_assert_timeout!({})

    try_for!(
        assert_timeout,
        |{}|
            match browser |> Browser.get_url! {
                Ok(actual) =>
                    if expected == actual {
                        Ok({})
}else{
                        Err(AssertionError("Expected the URL to be \"${expected}\", but got \"${actual}\" (waited for ${assert_timeout |> Num.to_str}ms)"))
  }

                Err(err) => Err(err),
  }
    )
}

## Checks if the __title__ of the page is equal to the __expected__.
##
## This function will wait for the expectation to be met,
## for the **assert_timeout** specified in test options - default: 3s.
## ```
## # assert text
## browser |> Assert.title_should_be!("The Roc Programming Language")
## ```
title_should_be! : Browser, Str => Try({} ,[AssertionError( Str ), WebDriverError( Str )])
title_should_be! = |browser, expected| {
    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Assert: Waiting for the page title to be \"${expected}\""),
    )

    assert_timeout = Utils.get_assert_timeout!({})

    try_for!(
        assert_timeout,
        |{}|
            actual = browser |> Browser.get_title!?

            if expected == actual then
                Ok({})
            else
                Err(AssertionError("Expected the page title to be \"${expected}\", but got \"${actual}\" (waited for ${assert_timeout |> Num.to_str}ms)")),
    )
  }

## Fails with given error message.
##
## ```
## # fail the test
## Assert.fail_with!("this should not happen")
## ```
fail_with : Str -> Try(_ ,[AssertionError( Str )])
fail_with = |msg|
    Err(AssertionError(msg))

## Checks if the length of __list__ is equal to the __expected__ length.
##
## ```
## # find all buttons element
## buttons = browser |> Browser.find_elements!(Css("button"))?
## # assert that there are 3 buttons
## buttons |> Assert.should_have_length 3
## ```
should_have_length : List a, U64 -> Try({} ,[AssertionError( Str )])
should_have_length = |list, expected| {
    actual_len = list |> List.len

    if actual_len == expected {

        Ok({})
  }else{
        actual_len_str = actual_len |> Num.to_str
        expected_len_str = expected |> Num.to_str
        actual_elements_word = pluralize(actual_len, "element", "elements")
        expected_elements_word = pluralize(actual_len, "element", "elements")

        Err(AssertionError("Expected a list with ${actual_len_str} ${actual_elements_word}, but got ${expected_len_str} ${expected_elements_word}"))
  }
  }


## Checks if the `Element` has __expected__ text.
##
## This function will wait for the `Element` to meet the expectation,
## for the **assert_timeout** specified in test options - default: 3s.
##
## ```
## # find button element
## button = browser |> Browser.find_element!(Css("#submit-button"))?
## # check if button has text "Submit"
## button |> Assert.element_should_have_text!("Submit")
## ```
element_should_have_text! : Element, Str => Try({} ,[AssertionError( Str ), ElementNotFound( Str ), WebDriverError( Str )])
element_should_have_text! = |element, expected_text| {
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Assert: Waiting for element ${selector_text} to have text: \"${expected_text}\""),
    )

    assert_timeout = Utils.get_assert_timeout!({})

    try_for!(
        assert_timeout,
        |{}|
            element_text = InternalElement.get_text!(element)?

            if expected_text == element_text {
                Ok({})
      }else{
                Err(AssertionError("Expected element ${selector_text} to have text \"${expected_text}\", but got \"${element_text}\" (waited for ${assert_timeout |> Num.to_str}ms)")),
      }
    )
  }


## Checks if the `Element` has __expected__ value.
##
## This function will wait for the `Element` to meet the expectation,
## for the **assert_timeout** specified in test options - default: 3s.
##
## ```
## # find input element
## input = browser |> Browser.find_element!(Css("#username-input"))?
## # check if input has value "fake-username"
## input |> Assert.element_should_have_value!("fake-username")
## ```
element_should_have_value! : Element, Str => Try({} ,[AssertionError( Str ), ElementNotFound( Str ), WebDriverError( Str ), PropertyTypeError( Str )])
element_should_have_value! = |element, expected_value| {
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Assert: Waiting for element ${selector_text} to have value: \"${expected_value}\""),
    )

    assert_timeout = Utils.get_assert_timeout!({})

    try_for!(
        assert_timeout,
        |{}|
            element_value = element |> InternalElement.get_property!("value")?

            if expected_value == element_value {
                Ok({})
      }else{
                Err(AssertionError("Expected element ${selector_text} to have value \"${expected_value}\", but got \"${element_value}\" (waited for ${assert_timeout |> Num.to_str}ms)")),
      }
    )
  }

## Checks if the `Element` is visible in the `Browser`.
##
## This function will wait for the `Element` to meet the expectation,
## for the **assert_timeout** specified in test options - default: 3s.
##
## ```
## # find error message element
## errorMsg = browser |> Browser.find_element!(Css(".error-msg"))?
## # check if the error message element is visible
## errorMsg |> Assert.element_should_be_visible!()
## ```
element_should_be_visible! : Element => Try({} ,[AssertionError( Str ), ElementNotFound( Str ), WebDriverError( Str )])
element_should_be_visible! = |element| {
    { selector_text } = Internal.unpack_element_data(element)

    DebugMode.run_if_verbose!(
        |{}|
            Debug.print_line!("Assert: Waiting for element ${selector_text} to visible"),
    )

    assert_timeout = Utils.get_assert_timeout!({})

    try_for!(
        assert_timeout,
        |{}|
            is_visible = element |> InternalElement.is_visible!?

            when is_visible is
                Visible -> Ok({})
                NotVisible ->
                    Err(AssertionError("Expected element ${selector_text} to be visible (waited for ${assert_timeout |> Num.to_str}ms)")),
    )
  }
}

pluralize : U64, a, a -> a
pluralize = |count, singular, plural|
    if count == 1 {

        singular
    } else {

        plural
      }

try_for! : U64, ({} => Try( ok, a)) => Try( {}, a)
try_for! = |timeout, task!| {
    start_time = Utils.get_time_milis!({})

    loop!(
        |{}|
            result = task!({})
            match result {
                Ok(_) => Done(Ok({}))
                Err(err) =>{
                    now = Utils.get_time_milis!({})
                    if now - start_time >= timeout {
                        Done(Err(err))
    } else{
                        Debug.wait!(100) # wait for 100 ms
                        Step
  }
        }
      }
    )
  }

loop! = |callback!|
    match callback!({}) {
        Done(res) => res
        Step => loop!(callback!)
    }
