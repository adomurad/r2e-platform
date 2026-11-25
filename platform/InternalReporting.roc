import Fs
import Error

## `InternalReporting` contains the reporter contract and the code which runs
## reporters and writes their files to disk.
InternalReporting :: [].{

	TestRunResult : {
		name : Str,
		duration : U64,
		result : Try({}, Error.PlatformError),
		screenshot : [NoScreenshot, Screenshot(Str)],
		logs : List(Str),
		type : [FinalResult, Attempt],
	}

	TestRunMetadata := {
		duration : U64,
	}

	ReporterCallback : List(TestRunResult), TestRunMetadata -> List({ file_path : Str, content : Str })

	ReporterDefinition : {
		name : Str,
		callback : ReporterCallback,
	}

	run_reporters! : List(ReporterDefinition), List(TestRunResult), Str, U64 => Try({}, Error.PlatformError)
	run_reporters! = |reporters, results, out_dir, duration|
		reporters.fold_try!(
			{},
			|{}, reporter| run_reporter!(reporter, results, out_dir, duration),
		)

	run_reporter! : ReporterDefinition, List(TestRunResult), Str, U64 => Try({}, Error.PlatformError)
	run_reporter! = |reporter, results, out_dir, duration| {
		Fs.create_dir_if_not_exist!(out_dir)?

		ready_files = (reporter.callback)(results, TestRunMetadata.{ duration })

		ready_files.fold_try!(
			{},
			|{}, file| {
				reporter_dir_name = reporter.name.replace_each("/", "_")
				reporter_dir = join_path(out_dir, reporter_dir_name)
				final_path = join_path(reporter_dir, file.file_path)
				create_dir_for_file_path!(final_path)?
				Fs.write_utf8!(final_path, file.content)
			},
		)
	}

	join_path : Str, Str -> Str
	join_path = |path, filename| {
		sanitized_path = remove_trailing(path, "/")

		"${sanitized_path}/${filename}"
	}

	create_dir_for_file_path! : Str => Try({}, Error.PlatformError)
	create_dir_for_file_path! = |path| {
		match Str.split_last(path, "/") {
			Ok({ before, .. }) => Fs.create_dir_if_not_exist!("${before}/")
			Err(NotFound) => Err(FileSystemError("could not create a directory for path: ${path}"))
		}
	}

	remove_trailing : Str, Str -> Str
	remove_trailing = |out_dir, tail|
		if out_dir.ends_with(tail) {
			out_dir.replace_last(tail, "")
		} else {
			out_dir
		}
}
