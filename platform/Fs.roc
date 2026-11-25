import Host

Fs := [].{

	create_dir_if_not_exist! : Str => Try({}, [FileSystemError(Str)])
	create_dir_if_not_exist! = |path|
		Host.create_dir_if_not_exist!(path).map_err(fs_error)

	write_utf8! : Str, Str => Try({}, [FileSystemError(Str)])
	write_utf8! = |path, content|
		Host.file_write_utf8!(path, content).map_err(fs_error)
	fs_error = |HostError(msg)| FileSystemError(msg)
}