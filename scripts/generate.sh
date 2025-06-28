#!/bin/bash

# Usage: ./generate.sh <csv_file> <priority>

CSV_FILE="$1"
PRIORITY="${2:-50}"
LS_DIR=gfx/interface/illustrations/loading_screens
SETTINGS_FILE="$LS_DIR/hels_loadscreen_settings.txt"
MD_FILE="images.md"
TN_FILE="thumbnail.png"
TN_INPUT_FILE="images/Jean_Leon_Gerome_Selling_Slaves_in_Rome.jpg"
TN_SIZE=1024x1024
TN_GRAVITY=south

# Clear output files
> "$SETTINGS_FILE"
> "$MD_FILE"
rm -f $TN_FILE

# Process all files in the LS directory
for ls_file in "$LS_DIR"/*.dds; do
	[ ! -f "$ls_file" ] && continue
	filename=$(basename "$ls_file" .dds)
	echo "$filename = { priority = $PRIORITY }" >> "$SETTINGS_FILE"
done

# Add BOM
sed -i '1s/^/\xef\xbb\xbf/' "$SETTINGS_FILE"

# Add MD file header
cat << 'EOF' > "$MD_FILE"
# Images

| DDS File | Wikimedia Image |
|---|---|
EOF

# Read CSV and process each line
sort "$CSV_FILE" | while IFS=';' read -r converted_filename original_filename url rest; do
	# Skip empty lines and comments
	[ -z "$converted_filename" ] && continue
	[[ "$converted_filename" =~ ^[[:space:]]*# ]] && continue

	# Determine original filename
	if [ -z "$original_filename" ]; then
		original_filename=$(echo "$url" | sed 's|.*File:||' | sed 's|%20| |g')
	fi

	# Add MD file line
	echo "| $converted_filename | [$original_filename]($url) |" >> "$MD_FILE"
done

# Generate thumbnail file
convert "$TN_INPUT_FILE" -resize $TN_SIZE^ -gravity $TN_GRAVITY -extent $TN_SIZE "$TN_FILE"