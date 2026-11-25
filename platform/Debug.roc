import Host
import Element
import DebugMode

Debug := [].{

	## Write `Str` to Stdout followed by a newline.
	print_line! : Str => {}
	print_line! = |str|
		Host.stdout_line!(str)

	## Stops the test execution for specified amount of time.
	##
	## `timeout` - time in [ms]
	wait! : U64 => {}
	wait! = |timeout|
		Host.wait!(timeout)

	## Stops the test execution till the "enter" key is pressed in the terminal.
	wait_for_enter_key! : {} => {}
	wait_for_enter_key! = |{}| {
		print_line!("\nPress <enter> to continue the test run...")
		_ = Host.stdin_line!({})
		{}
	}

	## Blink an `Element` in the `Browser`.
	##
	## Can be useful for debugging and trouble shooting.
	show_element! : Element => Try({}, [WebDriverError(Str), JsReturnTypeError(Str)])
	show_element! = |element| {
		DebugMode.flash_elements!(element.session_id, element.locator, Single)?

		wait!(1500)

		Ok({})
	}

	## Blink a `List` of `Element`s in the `Browser`.
	##
	## Can be useful for debugging and trouble shooting.
	show_elements! : List(Element) => Try({}, [WebDriverError(Str), JsReturnTypeError(Str)])
	show_elements! = |elements|
		match elements {
			[] => Ok({})
			[element, ..] => {
				DebugMode.flash_elements!(element.session_id, element.locator, All)?

				wait!(1500)

				Ok({})
			}
		}

	## Blink the current active frame (iFrame or top level frame).
	##
	## Can be useful for debugging and trouble shooting.
	show_current_frame! : b => Try({}, [WebDriverError(Str), JsReturnTypeError(Str)])
		where [b.get_session_id : b -> Str]
	show_current_frame! = |browser| {
		session_id = browser.get_session_id()

		DebugMode.flash_current_frame!(session_id)?

		wait!(1500)

		Ok({})
	}
}
