import argparse

def convert_raw_to_hex(input_path, output_path):
    with open(input_path, "rb") as raw_file:
        # Read the entire file into a byte array
        raw_data = raw_file.read()

    # Open the output file to write the hex data
    with open(output_path, "w") as hex_file:
        # Process the raw data in chunks of 2 bytes (16 bits)
        for i in range(0, len(raw_data), 2):
            # Read 2 bytes
            two_bytes = raw_data[i:i+2]
            
            # Convert the two bytes to a 16-bit integer (little-endian)
            pixel_value = int.from_bytes(two_bytes, byteorder='little')
            
            # Mask the lower 10 bits to get the 10-bit pixel value
            pixel_10bit = pixel_value & 0x03FF
            
            # Write the 10-bit pixel value in hexadecimal format to the file
            hex_file.write(f"{pixel_10bit:03x}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Convert raw 16-bit image data to 10-bit pixel hex values.')
    parser.add_argument('input_path', type=str, help='Path to the input raw file')
    parser.add_argument('output_path', type=str, help='Path to the output hex file')

    args = parser.parse_args()
    
    convert_raw_to_hex(args.input_path, args.output_path)
