#!/usr/bin/env python3

import sys

from PIL import Image, ImageOps

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <INPUT FILE> <OUTPUT FILE>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # open RGB image
    image = Image.open(input_file)

    # convert to grayscale image
    gray_image = ImageOps.grayscale(image)

    # write luminance values to file
    with open(output_file, "wb") as f:
        data = bytearray(gray_image.width * gray_image.height)

        for y in range(gray_image.height):
            for x in range(gray_image.width):
                data[x + y * gray_image.width] = gray_image.getpixel((x, y))

        f.write(data)
