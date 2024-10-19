#!/bin/bash

TEST_DIR="$(dirname "$(realpath "$0")")"

echo "Prebuilding platform..."

roc $TEST_DIR/../build.roc || exit 1;

echo "Running browser-tests.roc"
roc --prebuilt-platform $TEST_DIR/browser-tests.roc || exit 1;

echo "Running element-tests.roc"
roc --prebuilt-platform $TEST_DIR/element-tests.roc || exit 1;
