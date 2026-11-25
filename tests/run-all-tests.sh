#!/bin/bash
set -euo pipefail

TEST_DIR="$(dirname "$(realpath "$0")")"
ROOT="$(dirname "$TEST_DIR")"
cd "$ROOT"

echo "Running minimal.roc"
roc "$TEST_DIR/minimal.roc" --headless

echo "Running debug-tests.roc"
roc "$TEST_DIR/debug-tests.roc" --headless

echo "Running browser-tests.roc"
roc "$TEST_DIR/browser-tests.roc" --headless

echo "Running element-tests.roc"
roc "$TEST_DIR/element-tests.roc" --headless

rm -rf testTestDir78

echo "Running configuration-tests.roc"
roc "$TEST_DIR/configuration-tests.roc" --headless

if [ -e ./testTestDir78/basicRenamed/index.html ]; then
    echo "reports ok"
else
    echo "missing the basicRenamed index.html"
    exit 1
fi

if [ -e ./testTestDir78/myCustomReporter/test.txt ]; then
    echo "reports ok"
else
    echo "missing the myCustomReporter test.txt"
    exit 1
fi

echo "Running element-assertion-tests.roc"
roc "$TEST_DIR/element-assertion-tests.roc" --headless

echo "Running env-tests.roc"
THIS_ENV_SHOULD_NOT_BE_EMPTY=secret_value roc "$TEST_DIR/env-tests.roc" --headless

echo "All test suites passed."
