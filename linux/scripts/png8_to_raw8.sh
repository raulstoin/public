#!/bin/bash

INPUT_FILE="$1"
OUTPUT_FILE="${INPUT_FILE:0:-4}.raw"

BYTES=$(identify -format "%[fx:h*w]" "$INPUT_FILE")
convert "$INPUT_FILE" -depth 8 pgm:- | tail -c $BYTES > "$OUTPUT_FILE"

