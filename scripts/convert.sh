#!/bin/bash

# Usage: ./convert.sh <csv_file>

CSV_FILE="$1"
INPUT_DIR=images
OUTPUT_DIR=gfx/interface/illustrations/loading_screens

SQUARE_THRESHOLD="1.1"
TV_THRESHOLD="1.4"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Read CSV and process each line
while IFS=';' read -r converted_filename original_filename url gravity crop_x crop_y crop_width crop_height; do
	# Skip empty lines and comments
	[ -z "$converted_filename" ] && continue
	[[ "$converted_filename" =~ ^[[:space:]]*# ]] && continue

	# Set default gravity if empty
	[ -z "$gravity" ] && gravity="center"

	# Determine output file
	output_file="$OUTPUT_DIR/${converted_filename%.*}.dds"

	# Skip if the output file exists
	[ -f "$output_file" ] && continue

	# Determine input file
	if [ -z "$original_filename" ]; then
		# Extract from URL after "File:" and remove extension
		base_filename=$(echo "$url" | sed 's|.*File:||' | sed 's|%20| |g' | sed 's|\.[^.]*$||')
		# Find file with this base name and any extension
		input_file=$(find "$INPUT_DIR" -maxdepth 1 -name "${base_filename}.*" -type f | head -1)
	else
		input_file="$INPUT_DIR/$original_filename"
	fi

	# Skip if input file doesn't exist
	[ ! -f "$input_file" ] && echo "✗ File $input_file not found" && continue

	# Get image dimensions and aspect ratio
	dimensions=$(identify -format "%w %h" "$input_file")
	width=$(echo $dimensions | cut -d' ' -f1)
	height=$(echo $dimensions | cut -d' ' -f2)
	if [ -n "$crop_width" ] && [ -n "$crop_height" ]; then
		width=$crop_width
		height=$crop_height
	fi
	aspect_ratio=$(echo "scale=3; $width / $height" | bc -l)

	# Determine target size
	if (( $(echo "$aspect_ratio <= $SQUARE_THRESHOLD" | bc -l) )); then
		target_size="1080x1080"
	elif (( $(echo "$aspect_ratio <= $TV_THRESHOLD" | bc -l) )); then
		target_size="1440x1080"
	else
		target_size="1920x1080"
	fi

	# Determine convert command
	defines="-define dds:mipmaps=0"
	if [ -n "$crop_x" ] && [ -n "$crop_y" ]; then
		# Crop from coordinates, then resize with the specified gravity
		convert_cmd="convert \"$input_file\" -crop ${crop_width}x${crop_height}+${crop_x}+${crop_y} +repage -resize ${target_size}^ -background black -gravity $gravity -extent 1920x1080 $defines \"$output_file\""
	else
		# Just resize with the specified gravity
		convert_cmd="convert \"$input_file\" -resize ${target_size}^ -background black -gravity $gravity -extent 1920x1080 $defines \"$output_file\""
	fi

	# Execute convert command
	if eval $convert_cmd; then
		echo "✓ $input_file → $output_file"
	else
		echo "✗ Failed to convert $input_file to $output_file"
	fi
done < "$CSV_FILE"