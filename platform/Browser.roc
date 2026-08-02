import Host
import ExecuteJs
import Locator
import DebugMode
import Debug
import Internal
import Element
import InternalError

Browser := { session_id : Str }.{

	## Opens a new `Browser` window.
	##
	## Only the browser provided by the test will be closed automatically,
	## please remember to close the browser windows you open manually.
	##
	## ```
	## newBrowser = Browser.open_new_window!({})?
	## ...
	## newBrowser |> Browser.close_window!()?
	## ```
	open_new_window! : {} => Try(Browser, [WebDriverError(Str), ..])
	open_new_window! = |{}|
	# DebugMode.run_if_verbose!(
	#     |{}| Debug.print_line!("Opening new browser window"),
	# )

		Host.start_session!({})
			.map_err(InternalError.host_error_to_web_driver_error)
			.map_ok(
				|session_id| {
					{ session_id: session_id }
				},
			)

	## Opens a new `Browser` window and runs a callback.
	## Will close the browser after the callback is finished.
	##
	## ```
	## Browser.open_new_window_with_cleanup!(|browser2|
	##     browser2 |> Browser.navigate_to!("https://www.roc-lang.org/")
	## )
	## ```
	# open_new_window_with_cleanup! : (Browser => Try(val, [WebDriverError(Str),..err])) => Try(val, [WebDriverError(Str), ..err])
	open_new_window_with_cleanup! = |callback!| {
		browser = open_new_window!({})?
		result = callback!(browser)
		close_window!(browser)?
		result
	}

	## Close a `Browser` window.
	##
	## Do not close the browser provided by the test,
	## the automatic cleanup will fail trying to close this browser.
	##
	## ```
	## newBrowser = Browser.open_new_window!({})?
	## ...
	## newBrowser |> Browser.close_window!
	## ```
	close_window! : Browser => Try({}, [WebDriverError(Str), ..])
	close_window! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Closing browser window"),
		)

		Host.delete_session!(browser.session_id)
			.map_err(InternalError.host_error_to_web_driver_error)
	}

	## Navigate the browser to the given URL.
	##
	## ```
	## # open google.com
	## browser |> Browser.navigate_to!("http://google.com")?
	## ```
	navigate_to! : Browser, Str => Try({}, [WebDriverError(Str), ..])
	navigate_to! = |browser, url| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Navigating to: ${url}"),
		)

		Host.browser_navigate_to!(browser.session_id, url)
			.map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Get browser title.
	##
	## ```
	## browser |> Browser.navigate_to!("http://google.com")?
	## # get title
	## title = browser |> Browser.get_title!()?
	## # title = "Google"
	## ```
	get_title! : Browser => Try(Str, [WebDriverError(Str), ..])
	get_title! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Getting title of the current page"),
		)

		Host.browser_get_title!(browser.session_id)
			.map_err(InternalError.host_error_to_web_driver_error)
	}

	## Get current URL.
	##
	## ```
	## browser |> Browser.navigate_to!("http://google.com")?
	## # get url
	## url = browser |> Browser.get_url!()?
	## # url = "https://google.com/"
	## ```
	get_url! : Browser => Try(Str, [WebDriverError(Str), ..])
	get_url! = |browser| {

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Getting url of the current page"),
		)

		Host.browser_get_url!(browser.session_id)
			.map_err(InternalError.host_error_to_web_driver_error)
	}

	# ## Supported locator strategies
	# ##
	# ## `Css Str` - e.g. Css(".my-button-class")
	# ##
	# ## `TestId Str` - e.g. TestId("button") => Css("[data-testid=\"button\"]")
	# ##
	# ## `XPath Str` - e.g. XPath("/bookstore/book[price>35]/price")
	# ##
	# ## `LinkText Str` - e.g. LinkText("Examples") in <a href="/examples-page">Examples</a>
	# ##
	# ## `PartialLinkText Str` - e.g. PartialLinkText("Exam") in <a href="/examples-page">Examples</a>
	# ##
	# Locator : Locator.Locator

	## Find an `Element` in the `Browser`.
	##
	## When there are more than 1 elements, then the first will
	## be returned.
	##
	## See supported locators at `Locator`.
	##
	## ```
	## # find the html element with a css selector "#my-id"
	## button = browser |> Browser.find_element!(Css("#my-id"))?
	## ```
	##
	## ```
	## # find the html element with a css selector ".my-class"
	## button = browser |> Browser.find_element!(Css(".my-class"))?
	## ```
	##
	## ```
	## # find the html element with an attribute [data-testid="my-element"]
	## button = browser |> Browser.find_element!(TestId("my-element"))?
	## ```
	find_element! : Browser, Locator => Try(Element, [WebDriverError(Str), ElementNotFound(Str), ..])
	find_element! = |browser, locator| {
		(using, value) = Locator.get_locator(locator)

		selector_text = "${Str.inspect(locator)}"

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Searching for element: ${selector_text}"),
		)

		element_id = Host.browser_find_element!(browser.session_id, using, value)
			.map_err(InternalError.handle_element_error)?

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Found element: ${selector_text}"),
		)

		DebugMode.run_if_debug_mode!(
			|{}| {
				# 	DebugMode.show_debug_message_in_browser!(session_id, "Find Element ${selector_text}")?
				# DebugMode.flash_elements!(session_id, locator, Single)?
				DebugMode.wait!({})
				Ok({})
			},
		)

		# Internal.pack_element_data({ session_id, element_id, selector_text, locator }) |> Ok
		Ok({ session_id: browser.session_id, element_id, selector_text, locator })
	}

	## Find an `Element` in the `Browser`.
	##
	## This function returns a `[Found Element, NotFound]` instead of an error
	## when element is not found.
	##
	## When there are more than 1 elements, then the first will
	## be returned.
	##
	## See supported locators at `Locator`.
	##
	## ```
	## maybe_button = browser |> Browser.try_find_element!(Css("#submit-button"))?
	##
	## match maybe_button {
	##     NotFound => Stdout.line!("Button not found")
	##     Found el ->
	##         button_text = el |> Element.get_text!
	##         Stdout.line!("Button found with text: $(button_text)")
	## ```
	try_find_element! : Browser, Locator => Try([Found(Element), NotFound], [WebDriverError(Str), ElementNotFound(Str), ..])
	try_find_element! = |browser, locator| {
		find_element!(browser, locator)
			.map_ok(|el| Found(el))
			.on_err(
				|err|
					match err {
						ElementNotFound(_) => Ok(NotFound)
						other => Err(other)
					},
			)
	}

	## Find an `Element` in the `Browser`.
	##
	## This function will fail if the element is not found - `ElementNotFound Str`
	##
	## This function will fail if there are more than 1 element - `AssertionError Str`
	##
	##
	## See supported locators at `Locator`.
	##
	## ```
	## button = browser |> Browser.find_single_element!(Css("#submit-button"))?
	## ```
	find_single_element! : Browser, Locator => Try(Element, [AssertionError(Str), ElementNotFound(Str), WebDriverError(Str), ..])
	find_single_element! = |browser, locator| {
		elements = find_elements!(browser, locator)?
		match List.len(elements) {
			0 => {
				(_, value) = Locator.get_locator(locator)
				Err(ElementNotFound("element with selector ${value} was not found"))
			}

			1 => {
				elements
					|> List.first
					|> Try.on_err(
						|_| {
							crash "just check - there is 1 element in the list"
						},
					)
			}

			n => {
				(_, value) = Locator.get_locator(locator)
				Err(AssertionError("expected to find only 1 element with selector \"${value}\", but found ${n.to_str()}"))
			}
		}
	}

	## Find all `Elements` in the `Browser`.
	##
	## When there are no elements found, then the list will be empty.
	##
	## See supported locators at `Locator`.
	##
	## ```
	## # find all <li> elements in #my-list
	## listItems = browser |> Browser.find_elements!(Css("#my-list li"))?
	## ```
	##
	find_elements! : Browser, Locator => Try((List(Element)), [WebDriverError(Str), ElementNotFound(Str), ..])
	find_elements! = |browser, locator| {
		(using, value) = Locator.get_locator(locator)

		selector_text = "${Str.inspect(locator)}"

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Searching for elements: ${selector_text}"),
		)

		result = Host.browser_find_elements!(browser.session_id, using, value)
			.map_err(InternalError.handle_element_error)

		match result {
			Ok(element_ids) => {
				# DebugMode.run_if_verbose!(|{}|
				# 	Debug.print_line!("Found ${element_ids |> List.len |> Num.to_str} elements: ${selector_text}"))

				DebugMode.run_if_debug_mode!(
					|{}| {
						if List.is_empty(element_ids) {
							Ok({})
						} else {
							# DebugMode.show_debug_message_in_browser!(session_id, "Find Elements ${selector_text}")?
							# DebugMode.flash_elements!(session_id, locator, All)?
							DebugMode.wait!({})
							Ok({})
						}
					},

				)

				element_ids
					|> List.map(
						|element_id|
							({ session_id: browser.session_id, element_id, selector_text, locator }),
					)
					|> Ok
			}

			Err(ElementNotFound(_)) => Ok([])
			Err(err) => Err(err)
		}
	}

	## Take a screenshot of the whole document.
	##
	## The result will be a **base64** encoded `Str` representation of a PNG file.
	##
	## ```
	## base64PngStr = browser |> Browser.take_screenshot_base64!()?
	## ```
	take_screenshot_base64! : Browser => Try(Str, [WebDriverError(Str), ..])
	take_screenshot_base64! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Taking screenshot of the whole page"),
		)

		Host.browser_get_screenshot!(browser.session_id).map_err(InternalError.host_error_to_web_driver_error)
	}

	# PageOrientation : [Landscape, Portrait]
	#
	# PrintPdfPayload : {
	#     page ? PageDimensions,
	#     margin ? PageMargins,
	#     scale ? F64, # 0.1 - 2.0 - default: 1.0
	#     orientation ? PageOrientation, # default: portrait
	#     shrink_to_fit ? Bool, # default: true
	#     background ? Bool, # default: false
	#     page_ranges ? List Str, # default []
	# }
	#
	# PageDimensions : {
	#     width : F64, # default: 21.59 cm
	#     height : F64, # default: 27.94 cm
	# }
	#
	# PageMargins : {
	#     top : F64, # default: 1 cm
	#     bottom : F64, # default: 1 cm
	#     left : F64, # default: 1 cm
	#     right : F64, # default: 1 cm
	# }

	## Print current page to PDF.
	##
	## The result will be **base64** encoded `Str`.
	##
	## All options are optional, with defaults:
	## ```
	## PageOrientation : [Landscape, Portrait]
	##
	## PrintPdfPayload : {
	##     page ? PageDimensions,
	##     margin ? PageMargins,
	##     scale ? F64, # 0.1 - 2.0 - default: 1.0
	##     orientation ? PageOrientation, # default: portrait
	##     shrink_to_fit ? Bool, # default: true
	##     background ? Bool, # default: false
	##     page_ranges ? List Str, # default []
	## }
	##
	## PageDimensions : {
	##     width : F64, # default: 21.59 cm
	##     height : F64, # default: 27.94 cm
	## }
	##
	## PageMargins : {
	##     top : F64, # default: 1 cm
	##     bottom : F64, # default: 1 cm
	##     left : F64, # default: 1 cm
	##     right : F64, # default: 1 cm
	## }
	## ```
	## ```
	## base64_pdf_str = browser |> Browser.print_pdf_base64!({})?
	## ```
	# print_pdf_base64 : Browser, PrintPdfPayload -> Task.Task Str [WebDriverError Str]
	# print_pdf_base64 = \browser, { scale ? 1.0f64, orientation ? Portrait, shrinkToFit ? True, background ? False, page ? { width: 21.59f64, height: 27.94f64 }, margin ? { top: 1.0f64, bottom: 1.0f64, left: 1.0f64, right: 1.0f64 }, pageRanges ? [] } ->
	#     { sessionId } = Internal.unpackBrowserData browser
	#
	#     orientationStr = if orientation == Portrait { "portrait" } else { "landscape" }
	#     shrinkToFitI64 = if shrinkToFit { 1 } else { 0 }
	#     backgroundI64 = if background { 1 } else { 0 }
	#
	#     Host.browserGetPdf sessionId page.width page.height margin.top margin.bottom margin.left margin.right scale orientationStr shrinkToFitI64 backgroundI64 pageRanges |> Task.mapErr WebDriverError

	WindowRect : {
		x : I64,
		y : I64,
		width : U32,
		height : U32,
	}

	SetWindowRectOptions : [
		MoveAndResize(
			{
				x : I64,
				y : I64,
				width : U32,
				height : U32,
			},
		),
		Move({ x : I64, y : I64 }),
		Resize(
			{
				width : U32,
				height : U32,
			},
		),
	]

	## Set browser window position and/or size.
	##
	## `x` - x position
	## `y` - y position
	## `width` - width
	## `height` - height
	##
	## The result will contain new dimensions.
	##
	## **warning** - when running not headless,
	## the input dimensions (x, y) are the outer bound dimensions (with the frame).
	## But the result contain the dimension of the browser viewport!
	##
	## ```
	## newRect = browser |> Browser.set_window_rect!(Move({ x: 400, y: 600 }))?
	## # newRect is { x: 406, y: 627, width: 400, height: 600 }
	## ```
	## ```
	## newRect = browser |> Browser.set_window_rect!(Resize({ width: 800, height: 750 }))?
	## # newRect is { x: 300, y: 500, width: 800, height: 750 }
	## ```
	## ```
	## newRect = browser |> Browser.set_window_rect!(MoveAndResize({ x: 400, y: 600, width: 800, height: 750 }))?
	## # newRect is { x: 406, y: 627, width: 800, height: 750 }
	## ```
	# set_window_rect! : Browser, SetWindowRectOptions => Try(WindowRect, [WebDriverError(Str)])
	# set_window_rect! = |browser, set_rect_options| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			match set_rect_options {
	# 				Move({ x, y }) => Debug.print_line!("Moving browser window to: (${x.to_str()}, ${y.to_str()})")
	# 				Resize({ width, height }) => Debug.print_line!("Resizing browser window to: (${width.to_str()}, ${height.to_str()})")
	# 				MoveAndResize({ x, y, width, height }) => Debug.print_line!("Moving browser window to: (${x.to_str()}, ${y.to_str()}), and resizing to: (${width.to_str()}, ${height |> Num.to_str})")
	# 			},
	# 	)
	#
	# 	{ disciminant, new_x, new_y, new_width, new_height } = match set_rect_options {
	# 		Move({ x, y }) => {{ disciminant: 1, new_x: x, new_y: y, new_width: 0, new_height: 0 }},
	# 		Resize({ width, height }) => {{ disciminant: 2, new_x: 0, new_y: 0, new_width: width.to_i64(), new_height: height.to_i64() }},
	# 		MoveAndResize({ x, y, width, height }) => {{ disciminant: 3, new_x: x, new_y: y, new_width: width.to_i64(), new_height: height.to_i64() }},
	# 	}
	#
	# 	Host.browser_set_window_rect!(browser.session_id, disciminant, new_x, new_y, new_width, new_height)
	# 		|> Try.map_ok(
	# 			|list|
	# 				match list {
	# 					[x_val, y_val, width_val, height_val] => { x: x_val, y: y_val, width: width_val.to_u32(), height: height_val.to_u32() }
	# 					_ => {
	# 						crash "the contract with host should not fail"
	# 					}
	# 				},
	# 		)
	# }

	## Get browser window position and size.
	##
	## `x` - x position
	## `y` - y position
	## `width` - width
	## `height` - height
	##
	## **warning** - when running not headless, the result contains the x and y of the browser's viewport,
	## without the frame.
	##
	## ```
	## rect = browser |> Browser.get_window_rect!()?
	## # rect is { x: 406, y: 627, width: 400, height: 600 }
	## ```
	# get_window_rect! : Browser => Try(WindowRect, [WebDriverError(Str)])
	# get_window_rect! = |browser| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Getting browser position and size"),
	# 	)
	#
	# 	Host.browser_get_window_rect!(browser.session_id)
	# 		.map_err(InternalError.host_error_to_web_driver_error)
	# 		.map_ok(
	# 			|list|
	# 				match list {
	# 					[x_val, y_val, width_val, height_val] => { x: x_val, y: y_val, width: width_val.to_u32(), height: height_val |> Num.to_u32 }
	# 					_ => {
	# 						crash "the contract with host should not fail"
	# 					}
	# 				},
	# 		)
	# }

	## Navigate back in the browser history.
	##
	## ```
	## browser |> Browser.navigate_back!()?
	## ```
	navigate_back! : Browser => Try({}, [WebDriverError(Str), ..])
	navigate_back! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Navigating back"),
		)

		Host.browser_navigate_back!(browser.session_id).map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Navigate forward in the browser history.
	##
	## ```
	## browser |> Browser.navigate_forward!()?
	## ```
	navigate_forward! : Browser => Try({}, [WebDriverError(Str), ..])
	navigate_forward! = |browser| {

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Navigating froward"),
		)

		Host.browser_navigate_forward!(browser.session_id).map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Reload the current page.
	##
	## ```
	## browser |> Browser.reload_page!()?
	## ```
	reload_page! : Browser => Try({}, [WebDriverError(Str), ..])
	reload_page! = |browser| {

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Reloading page"),
		)

		Host.browser_reload!(browser.session_id).map_err(InternalError.host_error_to_web_driver_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Maximize the `Browser` window.
	##
	## Can fail when the system does not support this operation.
	##
	## ```
	## new_rect = browser |> Browser.maximize_window!()?
	## ```
	# maximize_window! : Browser => Try(WindowRect, [WebDriverError(Str)])
	# maximize_window! = |browser| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Maximizing browser window"),
	# 	)
	#
	# 	Host.browser_maximize!(browser.session_id)
	# 		.map_err(InternalError.host_error_to_web_driver_error)
	# 		.map_ok(
	# 			|list|
	# 				match list {
	# 					[x_val, y_val, width_val, height_val] => { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
	# 					_ => {
	# 						crash "the contract with host should not fail"
	# 					}
	# 				},
	# 		)
	# }

	## Minimize the `Browser` window.
	##
	## Can fail when the system does not support this operation.
	##
	## ```
	## new_rect = browser |> Browser.minimize_window!()?
	## ```
	# minimize_window! : Browser => Try(WindowRect, [WebDriverError(Str)])
	# minimize_window! = |browser| {
	#
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Minimizing browser window"),
	# 	)
	#
	# 	Host.browser_minimize!(session_id)
	# 		|> Try.map_ok(
	# 			|list|
	# 				match list {
	# 					[x_val, y_val, width_val, height_val] => { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
	# 					_ => {
	# 						crash ("the contract with host should not fail")
	# 					}
	# 				},
	# 		)
	# }

	## Make the `Browser` window full screen.
	##
	## Can fail when the system does not support this operation.
	##
	## ```
	## new_rect = browser |> Browser.full_screen_window!()?
	## ```
	# full_screen_window! : Browser => Try(WindowRect, [WebDriverError(Str)])
	# full_screen_window! = |browser| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Making browser window full screen"),
	# 	)
	#
	# 	Host.browser_full_screen!(browser.session_id)
	# 		|> Try.map_ok(
	# 			|list|
	# 				match list {
	# 					[x_val, y_val, width_val, height_val] => { x: x_val, y: y_val, width: width_val |> Num.to_u32, height: height_val |> Num.to_u32 }
	# 					_ => {
	# 						crash ("the contract with host should not fail")
	# 					}
	# 				},
	# 		)
	# }

	## Execute JavaScript in the `Browser`.
	##
	## ```
	## browser |> Browser.execute_js!("console.log('wow')")?
	## ```
	# execute_js! : Browser, Str => Try({}, [WebDriverError( Str ), JsReturnTypeError( Str )]) where a implements Decoding
	# execute_js! : Browser, Str => Try({}, [WebDriverError(Str), JsReturnTypeError(Str)])
	# execute_js! = |browser, script| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Executing JavaScript in the browser"),
	# 	)
	#
	# 	_output : Str
	# 	_output = ExecuteJs.execute_js!(browser, script)?
	#
	# 	DebugMode.run_if_debug_mode!(
	# 		|{}|
	# 			DebugMode.wait!({}),
	# 	)
	#
	# 	Ok({})
	# }

	## Execute JavaScript in the `Browser` and get the response.
	##
	## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
	## R2E will try to cast the browser response to the choosen type.
	##
	## When the response is empty e.g. property does not exist, then the default value of the choosen type will be used:
	## - `Str` - ""
	## - `Bool` - False
	## - `Num` - 0
	##
	## The output will be casted to expected Roc type:
	##
	## ```
	##  response = browser |> Browser.execute_js_with_output!("return 50 + 5;")?
	##  response |> Assert.should_be(55)
	##
	##  response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;")?
	##  response |> Assert.should_be(55.5)
	##
	##  response = browser |> Browser.execute_js_with_output!("return 50.5 + 5;")?
	##  response |> Assert.should_be("55.5")
	##
	##  response = browser |> Browser.execute_js_with_output!("return true")?
	##  response |> Assert.should_be("true")
	##
	##  response = browser |> Browser.execute_js_with_output!("return true")?
	##  response |> Assert.should_be(True)
	## ```
	##
	## The function can return a `Promise`.
	# execute_js_with_output! : Browser, Str => Try(a, [WebDriverError Str, JsReturnTypeError Str]) where a implements Decoding
	# execute_js_with_output! : Browser, Str => Try(a, [WebDriverError, Str, JsReturnTypeError, Str])
	# execute_js_with_output! = |browser, script| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Executing JavaScript in the browser"),
	# 	)
	#
	# 	result = ExecuteJs.execute_js!(browser, script)?
	#
	# 	DebugMode.run_if_debug_mode!(
	# 		|{}|
	# 			DebugMode.wait!({}),
	# 	)
	#
	# 	Ok(result)
	# }

	JsValue : [String, Str, Number, F64, Boolean, Bool, Null]

	## Execute JavaScript in the `Browser` with arguments and get the response.
	##
	## This function can be used with types like: `Bool`, `Str`, `I64`, `F64`, etc.
	## R2E will try to cast the browser response to the choosen type.
	##
	## The arguments is a list of:
	##
	## ```
	## JsValue : [String Str, Number F64, Boolean Bool, Null]
	## ```
	##
	## When the response is empty e.g. property does not exist, then the default value of the choosen type will be used:
	## - `Str` - ""
	## - `Bool` - False
	## - `Num` - 0
	##
	## Args can only be used using the `arguments` array in js.
	##
	## The output will be casted to expected Roc type:
	##
	## ```
	##  response = browser |> Browser.execute_js_with_args!("return 50 + 5;", [])?
	##  response |> Assert.should_Be(55)
	##
	##  response = browser |> Browser.execute_js_with_args!("return 50.5 + 5;", [Number 55.5, String "5"])?
	##  response |> Assert.should_be(55.5)
	## ```
	##
	## The function can return a `Promise`.
	# execute_js_with_args! : Browser, Str, List( JsValue ) => Try(a, [WebDriverError Str, JsReturnTypeError Str]) where a implements Decoding
	# execute_js_with_args! : Browser, Str, List(JsValue) => Try(a, [WebDriverError, Str, JsReturnTypeError, Str])
	# execute_js_with_args! = |browser, script, arguments| {
	# 	DebugMode.run_if_verbose!(
	# 		|{}|
	# 			Debug.print_line!("Executing JavaScript in the browser"),
	# 	)
	#
	# 	result = ExecuteJs.execute_js_with_args!(browser, script, arguments)?
	#
	# 	DebugMode.run_if_debug_mode!(
	# 		|{}|
	# 			DebugMode.wait!({}),
	# 	)
	#
	# 	Ok(result)
	# }

	# COOKIES
	# NewCookie : {
	#     name : Str,
	#     value : Str,
	#     domain ?? Str,
	#     path ?? Str,
	#     same_site ?? SameSiteOption,
	#     secure ?? Bool,
	#     http_only ?? Bool,
	#     expiry ?? CookieExpiry,
	# }

	## R2E cookie representation
	##
	## ```
	## Cookie : {
	##     name : Str,
	##     value : Str,
	##     domain : Str,
	##     path : Str,
	##     sameSite : SameSiteOption,
	##     secure : Bool,
	##     httpOnly : Bool,
	##     expiry : CookieExpiry,
	## }
	##
	## # MaxAge is a Epoch Timestamp (browsers accepts max 400 days in the future)
	## CookieExpiry : [Session, MaxAge U32]
	##
	## SameSiteOption : [None, Lax, Strict]
	## ```
	Cookie : {
		name : Str,
		value : Str,
		domain : Str,
		path : Str,
		same_site : SameSiteOption,
		secure : Bool,
		http_only : Bool,
		expiry : CookieExpiry,
	}

	CookieExpiry : [Session, MaxAge, U32]

	SameSiteOption : [None, Lax, Strict]

	# same_site_option_to_str : SameSiteOption -> Str
	# same_site_option_to_str = |option|
	#     match option {
	#         None => "None"
	#         Lax => "Lax"
	#         Strict => "Strict"
	#
	# same_site_str_to_option = |str| {
	#     match str {
	#         "None" => None
	#         "Lax" => Lax
	#         "Strict" => Strict
	#         # TODO - hmm
	#         _ => None
	# }
	# }
	#
	# bool_to_int = |bool|
	#     if bool { 1 } else { 0 }

	## Add a cookie in the `Browser`.
	##
	## ```
	## browser |> Browser.add_cookie!({ name: "myCookie", value: "value1" })?
	## ```
	## ```
	## browser |> Browser.add_cookie!({
	##     name: "myCookie",
	##     value: "value1",
	##     domain: "my-top-level-domain.com",
	##     path: "/path",
	##     same_site: Lax,
	##     secure: True,
	##     http_only: True,
	##     expiry: MaxAge(2865848396), # unix epoch
	## }?
	## ```
	# add_cookie! : Browser, NewCookie => Try({}, [WebDriverError Str])
	# add_cookie! = |browser, { name, value, domain ?? "", path ?? "", same_site ?? None, secure ?? False, http_only ?? False, expiry ?? Session }|
	#     { session_id } = Internal.unpack_browser_data(browser)
	#
	#     same_site_str = same_site |> same_site_option_to_str
	#     secure_int = secure |> bool_to_int
	#     http_only_int = http_only |> bool_to_int
	#     expiry_i64 =
	#         match expiry {
	#             Session => -1
	#             MaxAge(n) => n |> Num.to_i64
	#
	#     Host.add_cookie!(session_id, name, value, domain, path, same_site_str, http_only_int, secure_int, expiry_i64)
	#     |> Try.map_err(WebDriverError)
	#
	# ## Delete a cookie in the `Browser` by name.
	# ##
	# ## ```
	# ## browser |> Browser.delete_cookie!("myCookieName")?
	# ## ```
	# delete_cookie! : Browser, Str => Try({}, [WebDriverError Str, CookieNotFound Str])
	# delete_cookie! = |browser, name|
	#     { session_id } = Internal.unpack_browser_data(browser)
	#
	#     Host.delete_cookie!(session_id, name) |> Try.map_err(InternalError.handle_cookie_error)
	#
	# ## Delete all cookies in the `Browser`.
	# ##
	# ## ```
	# ## browser |> Browser.delete_all_cookies!?
	# ## ```
	# delete_all_cookies! : Browser => Try({}, [WebDriverError Str])
	# delete_all_cookies! = |browser|
	#     { session_id } = Internal.unpack_browser_data(browser)
	#
	#     Host.delete_all_cookies!(session_id) |> Try.map_err(WebDriverError)
	#
	# ## Get a cookie from the `Browser` by name.
	# ##
	# ## ```
	# ## cookie1 = browser |> Browser.get_cookie!("myCookie")?
	# ## cookie1 |> Assert.should_be({
	# ##     name: "myCookie",
	# ##     value: "value1",
	# ##     domain: ".my-domain.io",
	# ##     path: "/",
	# ##     same_site: Lax,
	# ##     expiry: Session,
	# ##     secure: True,
	# ##     http_only: False,
	# ## })
	# ## ```
	# get_cookie! : Browser, Str => Try(Cookie, [WebDriverError Str, CookieNotFound Str])
	# get_cookie! = |browser, cookie_name|
	#     { session_id } = Internal.unpack_browser_data(browser)
	#
	#     cookie_array = Host.get_cookie!(session_id, cookie_name) |> Try.map_err(InternalError.handle_cookie_error)?
	#     cookie_array |> cookie_array_to_roc_cookie
	#
	# ## Get all cookies from the `Browser`.
	# ##
	# ## ```
	# ## cookies = browser |> Browser.get_all_cookies!()?
	# ## cookies |> List.len |> Assert.should_be(3)
	# ## ```
	# get_all_cookies! : Browser => Try((List Cookie), [WebDriverError Str, CookieNotFound Str])
	# get_all_cookies! = |browser|
	#     { session_id } = Internal.unpack_browser_data(browser)
	#
	#     cookies = Host.get_all_cookies!(session_id) |> Try.map_err(InternalError.handle_cookie_error)?
	#     roc_cookies =
	#         cookies
	#         |> List.map(cookie_array_to_roc_cookie) # TODO - right now I'm ignoring errors
	#         |> List.keep_oks(|e| e)
	#
	#     roc_cookies |> Ok
	#
	# cookie_array_to_roc_cookie : List Str -> Result Cookie [WebDriverError Str]
	# cookie_array_to_roc_cookie = |cookie_array|
	#     match cookie_array {
	#         [name, value, domain, path, http_only_str, secure_str, same_site_str, expiry_str] ->
	#             http_only = if http_only_str == "true" { True } else { False }
	#             secure = if secure_str == "true" { True } else { False }
	#             same_site = same_site_str |> same_site_str_to_option
	#             expiry =
	#                 expiry_str
	#                 |> expiry_str_to_roc
	#                 |> Try.map_err(|_| WebDriverError("could not parse cookie: probabably a bug in R2E"))?
	#
	#             Ok({ name, value, domain, path, expiry, http_only, same_site, secure })
	#
	#         _ => Err(WebDriverError("could not parse cookie: probably a bug in R2E"))
	#
	# expiry_str_to_roc = |exp_str|
	#     if exp_str |> Str.is_empty {
	#         Session |> Ok
	#     } else {
	#         u32 = exp_str |> Str.to_u32?
	#         u32 |> MaxAge |> Ok

	## Get alert/prompt text.
	##
	## ```
	## text = browser |> Browser.get_alert_text!()?
	## text |> Assert.should_be("Are you sure to close tab?")
	## ```
	get_alert_text! : Browser => Try(Str, [WebDriverError(Str), AlertNotFound(Str), ..])
	get_alert_text! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Getting alert text"),
		)

		Host.alert_get_text!(browser.session_id) |> Try.map_err(InternalError.handle_alert_error)
	}

	## Input text in prompt.
	##
	## ```
	## browser |> Browser.send_text_to_alert!("my reply")?
	## browser |> Browser.accept_alert!()?
	## ```
	send_text_to_alert! : Browser, Str => Try({}, [WebDriverError(Str), AlertNotFound(Str), ..])
	send_text_to_alert! = |browser, text| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Sending text to an alert: \"${text}\""),
		)

		Host.alert_send_text!(browser.session_id, text) |> Try.map_err(InternalError.handle_alert_error)
	}

	## Accept alert/prompt.
	##
	## ```
	## browser |> Browser.accept_alert!()?
	## ```
	accept_alert! : Browser => Try({}, [WebDriverError(Str), AlertNotFound(Str), ..])
	accept_alert! = |browser| {

		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Accepting an alert"),
		)

		Host.alert_accept!(browser.session_id).map_err(InternalError.handle_alert_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Dismiss alert/prompt.
	##
	## ```
	## browser |> Browser.dismiss_alert!()?
	## ```
	dismiss_alert! : Browser => Try({}, [WebDriverError(Str), AlertNotFound(Str), ..])
	dismiss_alert! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Dismissing an alert"),
		)

		Host.alert_dismiss!(browser.session_id).map_err(InternalError.handle_alert_error)?

		DebugMode.run_if_debug_mode!(
			|{}|
				DebugMode.wait!({}),
		)

		Ok({})
	}

	## Get the serialized DOM as HTML `Str`.
	##
	## ```
	## html = browser |> Browser.get_page_html!()?
	## html |> Assert.should_contain_text("<h1>Header</h1>")
	## ```
	get_page_html! : Browser => Try(Str, [WebDriverError(Str), ..])
	get_page_html! = |browser| {
		DebugMode.run_if_verbose!(
			|{}|
				Debug.print_line!("Getting page HTML"),
		)

		Host.get_page_source!(browser.session_id).map_err(InternalError.host_error_to_web_driver_error)
	}

}
