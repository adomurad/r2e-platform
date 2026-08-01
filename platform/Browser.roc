import Host

Browser :: { session_id : Str }.{

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
	open_new_window! : {} => Try(Browser, [WebDriverError(Str)])
	open_new_window! = |{}| {

		# DebugMode.run_if_verbose!(
		#     |{}|
		#         Debug.print_line!("Opening new browser window"),
		# )

		Host.start_session!({})
			|> Try.map_err(|err| WebDriverError(err))
			|> Try.map_ok(|session_id|
				{ session_id: session_id })
	}
}
