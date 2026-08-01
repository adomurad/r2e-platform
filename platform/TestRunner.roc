import Stdout
import TestCase

TestRunner :: [].{

	run_tests! : List(TestCase) => Try({}, _)
	run_tests! = |test_cases| {
		Stdout.line!("tests count: ${test_cases.len() |> Str.inspect}")
	}

}
