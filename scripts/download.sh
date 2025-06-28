#!/bin/bash

# Usage: ./download.sh <csv_file>

CSV_FILE="$1"
OUTPUT_DIR=images
USER_AGENT="PharaoxImageDownloader/1.0 (https://github.com/pharaox/hels; pharaox@tutanota.com)"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Read CSV and process each line
while IFS=';' read -r converted_filename original_filename url rest; do
	# Skip empty lines and comments
	[ -z "$converted_filename" ] && continue
	[[ "$converted_filename" =~ ^[[:space:]]*# ]] && continue

	# Determine original filename and output file
	if [ -z "$original_filename" ]; then
		original_filename=$(echo "$url" | sed 's|.*File:||' | sed 's|%20| |g')
	fi
	output_file="$OUTPUT_DIR/$original_filename"

	# Skip if the output file exists
	[ -f "$output_file" ] && continue

	# Get page content and extract download URL
	page_content=$(wget -q -U "$USER_AGENT" -O - "$url")
	download_url=$(echo "$page_content" | grep 'class="fullMedia"' | grep -o 'href="[^"]*"' | head -1 | sed 's/href="//;s/"//')

	# Skip if download URL not found
	[ -z "$download_url" ] && echo "✗ No download URL found in $url" && continue

	# Download the file
	if wget -q -t 3 -w 1 -U "$USER_AGENT" -O "$output_file" "$download_url"; then
		echo "✓ $output_file"
	else
		echo "✗ Failed to download $output_file from $download_url"
	fi
done < "$CSV_FILE"