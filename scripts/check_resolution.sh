#!/bin/bash

# Usage: ./check_resolution.sh

IMAGES_DIR=images

# Process all files in the images directory
for image_file in "$IMAGES_DIR"/*.*; do
	dimensions=$(identify -format "%w %h" "$image_file")
	width=$(echo $dimensions | cut -d' ' -f1)

	# Determine resolution
	if [ "$width" -lt 960 ]; then
		resolution="low"
	elif [ "$width" -gt 1920 ]; then
		resolution="high"
	else
		resolution="medium"
	fi

	echo "$image_file: $dimensions $resolution"
done