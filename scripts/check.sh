#!/bin/bash

# Usage: ./check.sh

IMAGES_DIR=images
INFO_FILE="images.txt"

SQUARE_THRESHOLD="1.1"
TV_THRESHOLD="1.4"

rm -f "$INFO_FILE"

# Process all files in the images directory
for image_file in "$IMAGES_DIR"/*.*; do
	# Get image dimensions and aspect ratio
	dimensions=$(identify -format "%w %h" "$image_file")
	width=$(echo $dimensions | cut -d' ' -f1)
	height=$(echo $dimensions | cut -d' ' -f2)
	if [ -n "$crop_width" ] && [ -n "$crop_height" ]; then
		width=$crop_width
		height=$crop_height
	fi
	aspect_ratio=$(echo "scale=3; $width / $height" | bc -l)

	# Determine resolution
	if [ "$width" -lt 960 ]; then
		resolution="low"
	elif [ "$width" -gt 1920 ]; then
		resolution="high"
	else
		resolution="medium"
	fi

	# Determine target ratio
	if (( $(echo "$aspect_ratio <= $SQUARE_THRESHOLD" | bc -l) )); then
		ratio="square"
	elif (( $(echo "$aspect_ratio <= $TV_THRESHOLD" | bc -l) )); then
		ratio="tv"
	else
		ratio="wide"
	fi

	echo "$image_file: ${width}x${height} $resolution $ratio" >> "$INFO_FILE"
done

echo "high: $(cat $INFO_FILE | grep high | wc -l), medium: $(cat $INFO_FILE | grep medium | wc -l), low: $(cat $INFO_FILE | grep low | wc -l)"
echo "wide: $(cat $INFO_FILE | grep wide | wc -l), tv: $(cat $INFO_FILE | grep tv | wc -l), square: $(cat $INFO_FILE | grep square | wc -l)"