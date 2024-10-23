#!/bin/bash

TEST_DIR="$(dirname "$(realpath "$0")")"

echo "Prebuilding platform..."

roc $TEST_DIR/../build.roc || exit 1;

echo "Running roc tests"
roc test ./platform/main.roc || exit 1;

echo "Running debug-tests.roc"
roc --prebuilt-platform $TEST_DIR/debug-tests.roc --debug || exit 1;
#  
echo "Running browser-tests.roc"
roc --prebuilt-platform $TEST_DIR/browser-tests.roc || exit 1;

echo "Running element-tests.roc"
roc --prebuilt-platform $TEST_DIR/element-tests.roc --headless || exit 1;

echo "Running element-assertion-tests.roc"
roc --prebuilt-platform $TEST_DIR/element-assertion-tests.roc --headless || exit 1;

