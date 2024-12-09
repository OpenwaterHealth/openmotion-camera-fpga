
def convert_3byte_hex_to_10bit_hex(hex_value):
    # Ensure the hex value is properly formatted (remove any leading '0x' if present)

    # Convert hex string to an integer
    int_value = int(hex_value, 16)

    # Keep only the lower 10 bits
    ten_bit_value = int_value & 0x3FF  # 0x3FF is the bitmask for 10 bits (1111111111 in binary)

    # Convert the result back to a 4-character hexadecimal string (padded if necessary)
    return f'{ten_bit_value:03X}'


def binary_to_hex_text(input_file, output_file):
    with open(input_file, 'rb') as f_in:
        binary_data = f_in.read()
    
    hex_lines = []
    for i in range(0, len(binary_data), 3):  # Read 4 bytes at a time
        chunk = binary_data[i:i+3]
        hex_value = ''.join(f'{byte:02X}' for byte in chunk)
        hex_value = convert_3byte_hex_to_10bit_hex(hex_value)
        hex_lines.append(hex_value)

    with open(output_file, 'w') as f_out:
        f_out.write('\n'.join(hex_lines))

if __name__ == '__main__':
    input_file = 'Flower_jtca001.raw'  # Replace with your binary file path
    output_file = 'output.mem'  # Replace with desired output text file path
    binary_to_hex_text(input_file, output_file)
