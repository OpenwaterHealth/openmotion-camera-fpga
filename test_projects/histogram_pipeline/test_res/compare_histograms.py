import argparse
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image

def read_jpg(file_path):
    img = Image.open(file_path).convert('L')
    return np.array(img)

def read_raw(file_path, width, height):
    with open(file_path, "rb") as f:
        raw_data = f.read()
    pixel_data = []
    for i in range(0, len(raw_data), 2):
        two_bytes = raw_data[i:i+2]
        pixel_value = int.from_bytes(two_bytes, byteorder='little') & 0x03FF
        pixel_data.append(pixel_value)
    return np.array(pixel_data).reshape((height, width))

def read_txt(file_path):
    with open(file_path, "r") as f:
        lines = f.readlines()
    pixel_data = [int(line.strip(), 16) for line in lines]
    return np.array(pixel_data)

def generate_histogram(data, title, base_name):
    hist, bins = np.histogram(data.ravel(), bins=1024, range=(0, 1023))
    plt.hist(data.ravel(), bins=1024, range=(0, 1023), histtype='step', label=title)
    plt.title(f"Histogram of {title}")
    plt.xlabel("Pixel Value")
    plt.ylabel("Frequency")
    plt.legend()

    # Save histogram data to file
    hist_file_path = f"{base_name}.{title.lower()}.histo"
    with open(hist_file_path, "w") as f:
        for bin_edge, count in zip(range(1024), hist):  # Match each bin with the corresponding count
            f.write(f"{bin_edge}: {count}\n")

def compare_histograms(data1, data2, data3):
    fig, axs = plt.subplots(3, 1, figsize=(10, 15))

    axs[0].hist(data1.ravel(), bins=1024, range=(0, 1023), histtype='step', label='JPG')
    axs[0].set_title("Histogram of JPG")
    axs[0].set_xlabel("Pixel Value")
    axs[0].set_ylabel("Frequency")

    axs[1].hist(data2.ravel(), bins=1024, range=(0, 1023), histtype='step', label='RAW')
    axs[1].set_title("Histogram of RAW")
    axs[1].set_xlabel("Pixel Value")
    axs[1].set_ylabel("Frequency")

    axs[2].hist(data3.ravel(), bins=1024, range=(0, 1023), histtype='step', label='TXT')
    axs[2].set_title("Histogram of TXT")
    axs[2].set_xlabel("Pixel Value")
    axs[2].set_ylabel("Frequency")

    plt.tight_layout()
    plt.show()

def main(base_name, width, height):
    jpg_path = f"{base_name}.jpg"
    raw_path = f"{base_name}.raw"
    txt_path = f"{base_name}.txt"

    jpg_data = read_jpg(jpg_path)
    raw_data = read_raw(raw_path, width, height)
    txt_data = read_txt(txt_path).reshape((height, width))

    plt.figure(figsize=(15, 5))
    plt.subplot(131)
    generate_histogram(jpg_data, 'JPG', base_name)
    plt.subplot(132)
    generate_histogram(raw_data, 'RAW', base_name)
    plt.subplot(133)
    generate_histogram(txt_data, 'TXT', base_name)
    plt.tight_layout()
    plt.show()

    compare_histograms(jpg_data, raw_data, txt_data)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate and compare histograms from JPG, RAW, and TXT files.')
    parser.add_argument('base_name', type=str, help='Base name of the files without extension')
    parser.add_argument('--width', type=int, default=1920, help='Width of the image')
    parser.add_argument('--height', type=int, default=1280, help='Height of the image')

    args = parser.parse_args()
    
    main(args.base_name, args.width, args.height)
