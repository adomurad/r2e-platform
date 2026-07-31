app [main!] { pf: platform "../platform/main.roc" }

import pf.Stdin
import pf.Stdout

# Demonstrates: Stdin.line!, interactive I/O, effectful functions

main! : List(Str) => Try({}, [Exit(I32), StdinErr(Str), StdoutErr(Str), ..])
main! = |args| {
	Stdout.line!("Enter something and I'll echo it back:")?

	dbg "wow this is a debug"
	dbg args

	input = Stdin.line!({})?
	Stdout.line!("You entered: ${input}")?

	Ok({})
}
