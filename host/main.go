package main

/*
#include "roc/app.h"
*/
import "C"
import (
	"flag"
	"host/roc"
)

func main() {}

//export roc_host_main
func roc_host_main(argc C.int, argv **C.char) C.int {
	_ = argc
	_ = argv

	setupOnly := flag.Bool("setup", false, "run only browser and driver setup (useful in CI)")
	printBrowserVersionOnly := flag.Bool("print-browser-version-only", false, "print the version of used browser (useful in CI)")
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

	return C.int(exitCode)
}
