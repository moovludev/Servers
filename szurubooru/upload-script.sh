#!/bin/bash
export LANG=C.UTF-8
export PYTHONIOENCODING=utf-8

UPLOAD_DIR="./upload_src"
TEMP_DIR="./temp_upload"

mkdir -p "$TEMP_DIR"

for artist_dir in "$UPLOAD_DIR"/*/; do
    orig_name=$(basename "$artist_dir")

    # Extract everything before the first left bracket
    artist_name=$(echo "$orig_name" | sed 's/[（(].*//')
    # Remove all whitespace
    artist_name=$(echo "$artist_name" | tr -d '[:space:]')

    echo "Uploading from $artist_dir with base tag artist:$artist_name"

    for file in "$artist_dir"/*; do
        filename=$(basename "$file")

        # Extract tags from filename
        tags_part=$(echo "$filename" | awk -F' - ' '{print $3}')
        tags_part="${tags_part%.*}"  # remove extension

        # Replace spaces in tags with underscores
        tags=$(echo "$tags_part" | tr ',' '\n' | sed 's/ /_/g' | tr '\n' ',' | sed 's/,$//')

        # Prepare temp directory for this file
        temp_file_dir="$TEMP_DIR/tmp_$(date +%s)_$RANDOM"
        mkdir -p "$temp_file_dir"
        cp "$file" "$temp_file_dir/"

        echo "Uploading '$filename' with tags: artist:$artist_name,$tags"
        /usr/local/bin/uv run szuru-toolkit upload-media \
            --tags "artist:$artist_name,$tags:" \
            "$temp_file_dir"

        # If upload successful, remove file and temp folder
        if [ $? -eq 0 ]; then
            rm -f "$file"
            rm -rf "$temp_file_dir"
        fi
    done

    # Remove artist folder if empty
    if [ -z "$(ls -A "$artist_dir")" ]; then
        rmdir "$artist_dir"
    fi
done
