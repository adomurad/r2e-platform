import Debug
import Browser
import TestCase

TestRunner :: [].{

	run_tests! : List(TestCase) => Try({}, _)
	run_tests! = |test_cases| {
		_ = Browser.open_new_window!({})

		Debug.print_line!("tests count: ${test_cases.len() |> Str.inspect}")
		Ok({})
	}

}
