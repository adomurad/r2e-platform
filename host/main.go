package main

import (
	"flag"
	"os"

	// these modules are generated by glue when we run `roc build.roc` - not using roc glue - don't know how :(
	"host/roc"
)

func entry() {
	setupOnly := flag.Bool("setup", false, "run only browser and driver setup (useful in CI)")
	printBrowserVersionOnly := flag.Bool("print-browser-version-only", false, "print the version of used broweser (useful in CI)")
	verbose := flag.Bool("verbose", false, "run with pauses between actions and visualize actions in browser")
	debugMode := flag.Bool("debug", false, "run with pauses between actions and visualize actions in browser")
	headless := flag.Bool("headless", false, "run headless")
	testFilterName := flag.String("name", "", "run only tests containing specified string")

	flag.Parse()

	options := roc.Options{
		SetupOnly:               *setupOnly,
		PrintBrowserVersionOnly: *printBrowserVersionOnly,
		Verbose:                 *verbose,
		DebugMode:               *debugMode,
		Headless:                *headless,
		TestNameFilter:          *testFilterName,
	}

	exitCode := roc.Main(options)

	os.Exit(exitCode)
}
