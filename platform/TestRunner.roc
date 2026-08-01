import Debug
import TestCase

TestRunner :: [].{

	run_tests! : List(TestCase) => Try({}, _)
	run_tests! = |test_cases| {
		Debug.print_line!("tests count: ${test_cases.len() |> Str.inspect}")
    Ok({})
	}

}
