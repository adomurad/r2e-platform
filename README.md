# R2E Platform

E2E testing in Roc!

Docs: https://adomurad.github.io/r2e-platform/

Tutorial: https://adomurad.github.io/r2e-platform/Tutorial

Releases: https://github.com/adomurad/r2e-platform/releases

Example Repo: https://github.com/adomurad/r2e-platform-example

## Warning

This platform downloads ~150MB at the first start - "chrome for testing" and
chromedriver.

## Showcase

![](./images/R2E-showcase.gif)

Present the results in one of the predefined formats, or create you own
reporters:

![](./images/R2E-results.png)

## Support

Currently only supported target is chrome.

Running R2E Platform is possible only on:

- Linux x64
- MacOS arm
- MacOS x64

Tested only on:

- Linux x64
- MacOS arm

## Example:

```roc
app [test_cases, config] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.9.0/18rG0wcljf8EmqFsLkFc8bioPpNZPyH_NJ83oCdmPrQ.tar.br" }

import r2e.Test exposing [test]
import r2e.Config
import r2e.Debug
import r2e.Browser
import r2e.Element
import r2e.Assert

config = Config.default_config

test_cases = [test1]

test1 = test(
    "use roc repl",
    |browser|
        # go to roc-lang.org
        browser |> Browser.navigate_to!("http://roc-lang.org")?
        # find repl input
        repl_input = browser |> Browser.find_element!(Css("#source-input"))?
        # wait for the repl to initialize
        Debug.wait!(200)
        # send keys to repl
        repl_input |> Element.input_text!("0.1+0.2{enter}")?
        # find repl output element
        output_el = browser |> Browser.find_element!(Css(".output"))?
        # get output text
        output_text = output_el |> Element.get_text!?
        # assert text - fail for demo purpose
        output_text |> Assert.should_be("0.3000000001 : Frac *"),
)
```

## Local Development

```sh
roc build.roc
```

```sh
roc --prebuilt-platform app.roc
```

## Compatibility

To build this, you will need:

- zig
- golang
