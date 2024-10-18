# Go Roc

Just wondering what I can do different when implementing my
[R2E](https://github.com/adomurad/r2e) lib as a platform.

Docs: https://adomurad.github.io/r2e-platform/

Tutorial: https://adomurad.github.io/r2e-platform/Tutorial

Releases: https://github.com/adomurad/r2e-platform/releases

## Warning

This platform downloads ~150MB at the first start - "chrome for testing" and
chromedriver.

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
app [testCases] { r2e: platform "https://github.com/adomurad/r2e-platform/releases/download/0.1.0/ihQprp7tDiZz3UtkzHaHXcHu51F307uQlIcoA9PZAts.tar.br" }

import r2e.Test exposing [test]
import r2e.Browser
import r2e.Element
import r2e.Console

testCases = [
    test1,
]

test1 = test "test1" \browser ->
    browser |> Browser.navigateTo! "https://devexpress.github.io/testcafe/example/"
    input = browser |> Browser.findElement! (Css "#developer-name")
    input |> Element.click!

    Console.printLine "I have clicked on a Element..."
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
