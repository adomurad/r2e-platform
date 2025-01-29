#!/bin/bash

TEST_DIR="$(dirname "$(realpath "$0")")"

echo "Prebuilding platform..."

roc $TEST_DIR/../build.roc || exit 1;

echo "Running roc tests"
roc test ./platform/main.roc || exit 1;

echo "Running debug-tests.roc"
roc --linker=legacy $TEST_DIR/debug-tests.roc --debug || exit 1;

echo "Running browser-tests.roc"
roc --linker=legacy $TEST_DIR/browser-tests.roc --headless || exit 1;

echo "Running element-tests.roc"
roc --linker=legacy $TEST_DIR/element-tests.roc --headless || exit 1;

echo "removing the test dir" # should auto remove?
rm -rf testTestDir78

echo "Running configuration-tests.roc"
roc --linker=legacy $TEST_DIR/configuration-tests.roc --headless || exit 1;

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
roc --linker=legacy $TEST_DIR/element-assertion-tests.roc --headless || exit 1;

echo "Running env-tests.roc"
THIS_ENV_SHOULD_NOT_BE_EMPTY=secret_value roc --linker=legacy $TEST_DIR/env-tests.roc --headless || exit 1;

