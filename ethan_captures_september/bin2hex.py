import struct

def binary_to_hex(binary_file, hex_file):
    try:
        with open(binary_file, 'rb') as bin_file, open(hex_file, 'w') as hex_out:
            while True:
                # Read 2 bytes (16 bits)
                data = bin_file.read(2)
                
                if not data:
                    break  # End of file
                
                # Unpack the 16-bit unsigned integer
                number = struct.unpack('>H', data)[0]  # 'H' represents unsigned 16-bit integer
                
                # Convert the number to hex and write it to the text file
                hex_out.write(f'{number:04X}\n')
                
        print(f"Conversion completed! Hex data saved in {hex_file}")
    
    except FileNotFoundError:
        print(f"File {binary_file} not found!")

if __name__ == "__main__":
    binary_file = "gradient_bar.raw"  # Replace with your binary file name
    hex_file = "gradient_bar.mem"    # Replace with the desired output file name
    binary_to_hex(binary_file, hex_file)
