import sys
import numpy as np
import matplotlib.pyplot as plt

def generate_histogram(data, title):
    plt.hist(data.ravel(), bins=1024, range=(0, 1023), histtype='step', label=title)
    plt.title(f"Histogram of {title}")
    plt.xlabel("Pixel Value")
    plt.ylabel("Frequency")
    plt.legend()

if len(sys.argv) != 2:
    print("Usage: python script.py <filename>")
    sys.exit(1)

filename = sys.argv[1]

# Read histogram data from file
histogram_data = {}
with open(filename, "r") as file:
    in_histogram_section = False
    total_pixel_count = 0
    for line in file:
        if line.strip() == "<< Histogram Start >>":
            in_histogram_section = True
            continue
        elif line.strip() == "<< Histogram End >>":
            break
        
        if in_histogram_section:
            bin_number, bin_value = line.split(":")
            histogram_data[int(bin_number.strip())] = int(bin_value.strip())
            total_pixel_count += int(bin_value.strip())

# Convert histogram data to numpy array
histogram_array = []
for key in sorted(histogram_data.keys()):
    histogram_array.extend([key] * histogram_data[key])
histogram_array = np.array(histogram_array)

# Plot histogram
generate_histogram(histogram_array, "Histogram")
plt.show()

print("Total Pixel Count:", total_pixel_count)
