#!/bin/bash

echo "welcome to undercity broken lanyard upload script"

rm img.png
rm img_resized.png
rm newbadge.bmp


# Ask for name of the user
read -p "Please enter your name: " name
echo "Hello, $name!"
# Ask for slack handle
read -p "Please enter your slack handle: @" slack_handle
echo "Thank you, $slack_handle! Let's proceed with the upload."
# Change the img to add the text

# Optional pronouns
read -p "any text you want to add, like pronouns?: " pronouns

read -p "any image you want to add? leave blank for none. (res is broken u know it + .png only + path pliz) : " image_url
# Download the image if provided

if [ -n "$image_url" ]; then
    cp "$image_url" img.png
else
    echo "no img, you're not funni"
fi

# if img exists, resize it to 64x64

if [ -f img.png ]; then
    echo "Resizing image to 64x64..."
    magick img.png -resize 64x64 img_resized.png
else
    echo "Image not found, skipping resize."
fi


# Img
# Calculate the width of the name text to position pronouns correctly
name_width=$(magick -font ./font.ttf -pointsize 25 -size 1000x100 xc:transparent -annotate +0+0 "$name" -trim info: | cut -d' ' -f3 | cut -d'x' -f1)
pronoun_x=$((20 + name_width + 20))  # Add 10 pixels spacing between name and pronouns

magick badge.bmp \
  -font ./font.ttf -pointsize 25 -fill black \
  -annotate +20+30 "$name" \
  -annotate +20+60 "@$slack_handle" \
  -pointsize 15 -font ./bankfont.ttf -annotate +${pronoun_x}+30 "$pronouns" \
  newbadge.bmp

# if the img exists, overlay it on the badge

if [ -f img_resized.png ]; then
    echo "Overlaying image on the badge..."
    magick newbadge.bmp img_resized.png -geometry +220+5 -composite newbadge.bmp
fi

# Convert it to a format suitable for the device

/bin/env python3 bmp_to_array.py newbadge.bmp f.h gImage_img

arduino-cli compile --fqbn rp2040:rp2040:generic_rp2350 --output-dir ./build
if [ $? -ne 0 ]; then
    echo "Compilation failed. Please check the code."
    exit 1
fi
echo "Please hold the boot button on the device and press enter when plugged in"
# Wait for the user to press enter
read -p "Press enter to continue..."
# Upload the compiled binary to the device
cp build/undercity-lanyard.ino.uf2 /Volumes/RP2350/
if [ $? -ne 0 ]; then
    echo "Upload failed. Please check the device connection."
    exit 1
fi
echo "Upload successful! The device should now be running the new code."
