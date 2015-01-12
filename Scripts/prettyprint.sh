#!/bin/bash

function print_usage_and_exit()
{
    echo "Usage: $0 output_dir [input_files]"
    exit 1
}

# Set up directories
SCRIPTS_DIR=$(cd "$(dirname "$0")" && pwd)
TESTS_DIR="$SCRIPTS_DIR/../Tests"
SUITE_TEST_DIR="$TESTS_DIR/JSONSchemaTestSuite/tests/draft4"
CUSTOM_TEST_DIR="$TESTS_DIR/JSONSchemaCustom"

if [ -z "$PRETTYPRINTER_PATH" ]; then
    PRETTYPRINTER_PATH="/Users/jillcohen/Library/Developer/Xcode/DerivedData/TWTValidation-hhdpirveagehwtciiqnlfjuvcrrx/Build/Products/Debug/JSONSchemaPrettyPrinter"
fi    

# Get command-line parameters
OUTPUT_DIR="$1"
shift
INPUT_FILES=$@

if [ -z "$OUTPUT_DIR" ]; then
    print_usage_and_exit
elif [ -z "$INPUT_FILES" ]; then
    # If no input files were specified, get all the test files in the 
    # suite and custom directories
    SUITE_FILES=$(find "$SUITE_TEST_DIR" -name "*.json" -not -path "*/optional/*.json" | sed -e "s|^$SUITE_TEST_DIR/|suite/|")
    CUSTOM_FILES=$(find "$CUSTOM_TEST_DIR" -name "*.json" | sed -e "s|^$CUSTOM_TEST_DIR/|custom/|")
    INPUT_FILES="$SUITE_FILES $CUSTOM_FILES"
fi

# Create the output directory if necessary
mkdir -p "$OUTPUT_DIR"

# Run the pretty printer on each input file and output its results to the 
# appropriate file
for INPUT_FILE in $INPUT_FILES; do
  RENAMED_INPUT_FILE=$(echo "$INPUT_FILE" | sed -e "s|^suite/|$SUITE_TEST_DIR/|" -e "s|^custom/|$CUSTOM_TEST_DIR/|")
  mkdir -p $(dirname "$OUTPUT_DIR/$INPUT_FILE")
  "$PRETTYPRINTER_PATH" "$RENAMED_INPUT_FILE" > "$OUTPUT_DIR/$INPUT_FILE"
done
