#!/bin/bash

echo "Welcome to Undercity Broken Lanyard Upload Script"

# Clean up previous files silently
rm -f img.png img_resized.png newbadge.bmp 2>/dev/null

# Ask for name of the user
read -p "Please enter your name: " name
echo "Hello, $name!"

# Ask for slack handle
read -p "Please enter your Slack handle: @" slack_handle
echo "Thank you, $slack_handle! Let's proceed with the upload."

# Optional pronouns
read -p "Any text you want to add, like pronouns?: " pronouns

read -p "Any image you want to add? Leave blank for none (PNG only, full path please): " image_url

# Download the image if provided
if [ -n "$image_url" ]; then
    cp "$image_url" img.png 2>/dev/null
else
    echo "No image provided."
fi

# If img exists, resize it to 64x64
if [ -f img.png ]; then
    echo "Resizing image to 64x64..."
    magick img.png -resize 64x64 img_resized.png
else
    echo "Image not found, skipping resize."
fi

# Calculate the width of the name text to position pronouns correctly
name_width=$(magick -font ./font.ttf -pointsize 25 -size 1000x100 xc:transparent -annotate +0+0 "$name" -trim info: | cut -d' ' -f3 | cut -d'x' -f1)
pronoun_x=$((20 + name_width + 20))  # Add 20 pixels spacing between name and pronouns

magick badge.bmp \
  -font ./font.ttf -pointsize 25 -fill black \
  -annotate +20+30 "$name" \
  -annotate +20+60 "@$slack_handle" \
  -pointsize 15 -font ./bankfont.ttf -annotate +${pronoun_x}+30 "$pronouns" \
  newbadge.bmp

# If the img exists, overlay it on the badge
if [ -f img_resized.png ]; then
    echo "Overlaying image on the badge..."
    magick newbadge.bmp img_resized.png -geometry +220+5 -composite newbadge.bmp
fi

# Install pillow silently
echo "Installing required dependencies..."
/usr/bin/env python3 -m pip install pillow -q 2>/dev/null

# Convert it to a format suitable for the device
/usr/bin/env python3 bmp_to_array.py newbadge.bmp f.h gImage_img

echo "Compiling code..."
arduino-cli compile --fqbn rp2040:rp2040:generic_rp2350 --output-dir ./build
if [ $? -ne 0 ]; then
    echo "Compilation failed. Please check the code."
    exit 1
fi

# Wait for the user to press enter
read -p "Plug in the device and press Enter to continue..."

# Upload the compiled binary to the device
echo "Uploading to device..."
cp build/undercity-lanyard.ino.uf2 /Volumes/RP2350/ 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Couldn't find the device! Try step 4 in the README (https://github.com/gusruben/undercity-lanyard) more carefully, or get help if it's not working!"
    exit 1
fi

echo "Upload successful! The device should now be running the new code."
