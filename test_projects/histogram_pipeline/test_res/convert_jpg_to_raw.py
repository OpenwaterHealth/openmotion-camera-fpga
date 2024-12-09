import argparse
from PIL import Image
import numpy as np

def jpg_to_10bit_raw_monochrome(input_path, output_path):
    # Step 1: Read the JPG image
    img = Image.open(input_path)

    # Step 2: Convert to grayscale
    grayscale_img = img.convert("L")

    # Step 3: Scale to 10-bit depth
    # Convert to numpy array
    grayscale_array = np.array(grayscale_img)
    
    # Scale pixel values from 8-bit (0-255) to 10-bit (0-1023)
    grayscale_10bit = (grayscale_array.astype(np.uint16) * 4).clip(0, 1023)

    # Step 4: Save as raw
    # Save the data as a binary file
    grayscale_10bit.tofile(output_path)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert JPG to 10-bit raw monochrome.')
    parser.add_argument('input_path', type=str, help='Path to the input JPG image')
    parser.add_argument('output_path', type=str, help='Path to save the output raw file')

    args = parser.parse_args()
    
    jpg_to_10bit_raw_monochrome(args.input_path, args.output_path)
