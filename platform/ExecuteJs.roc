import Host
import PropertyDecoder
import InternalError

ExecuteJs :: [].{
	JsValue : [String(Str), Number(F64), Boolean(Bool), Null]

	execute_js! : Str, Str => Try(a, [WebDriverError(Str), JsReturnTypeError(Str)])
		where [a.PropertyDecoder.Parseable(PropertyDecoder.PropertyError)]
	execute_js! = |session_id, script| {
		result_str = Host.execute_js!(session_id, script, "[]")
			.map_err(InternalError.host_error_to_web_driver_error)?

		match PropertyDecoder.parse(result_str) {
			Ok(val) => Ok(val)
			Err(_) => Err(JsReturnTypeError("unsupported return type from js: \"${result_str}\""))
		}
	}

	execute_js_with_args! : Str, Str, List(JsValue) => Try(a, [WebDriverError(Str), JsReturnTypeError(Str)])
		where [a.PropertyDecoder.Parseable(PropertyDecoder.PropertyError)]
	execute_js_with_args! = |session_id, script, arguments| {
		arguments_str = js_arguments_to_str(arguments)

		result_str = Host.execute_js!(session_id, script, arguments_str)
			.map_err(InternalError.host_error_to_web_driver_error)?

		match PropertyDecoder.parse(result_str) {
			Ok(val) => Ok(val)
			Err(_) => Err(JsReturnTypeError("unsupported return type from js: \"${result_str}\""))
		}
	}

	js_arguments_to_str : List(JsValue) -> Str
	js_arguments_to_str = |args| {
		items =
			args.map(
				|arg|
					match arg {
						String(str) => Json.to_str(str)
						Number(num) => num.to_str()
						Boolean(bool) => if bool { "true" } else { "false" }
						Null => "null"
					},
			)

		"[${Str.join_with(items, ",")}]"
	}
}
