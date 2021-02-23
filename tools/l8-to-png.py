#!/usr/bin/env python3

import sys

from PIL import Image, ImageOps

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <INPUT FILE> <OUTPUT FILE>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # read input file
    f = open(input_file, "rb")
    data = f.read()
    f.close()

    width = 480
    height = 480

    # create grayscale image
    image = Image.new("L", (width, height), 0)

    # write luminance values to image
    for y in range(height):
        for x in range(width):
            image.putpixel((x, y), data[x + y * width])

    # save the image as PNG
    image.save(output_file, "png")

    # show the image
    image.show()
