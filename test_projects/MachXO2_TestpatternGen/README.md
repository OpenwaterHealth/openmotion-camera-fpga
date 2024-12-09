# Grayscale Color Bar Generator (240x180, 10-bit) with Verilog

This project generates a grayscale color bar at a resolution of 240x180 pixels using a Verilog module. The design outputs a pixel per clock pulse at a frequency of 133 MHz, producing 40 frames per second. The module also provides `frame_valid` and `line_valid` signals, with a 10 µs blanking period after each line.

## Features

- **Resolution:** 240x180 pixels
- **Grayscale Depth:** 10-bit (values from 0 to 1023, wrapped at 239)
- **Frame Rate:** 40 FPS
- **Clock Frequency:** 133.00 MHz
- **Blanking Period:** 10 µs between each line
- **Outputs:**
  - `frame_valid`: Signal active during the entire frame
  - `line_valid`: Signal active during each line, de-asserted during the blanking period

## Project Structure

- `top.v`: The top-level Verilog module that instantiates the grayscale color bar generator and controls the clock, LEDs, and signals.
- `grayscale_color_bar.v`: The module that generates the grayscale pattern, pixel by pixel, with proper timing signals (`frame_valid`, `line_valid`).
- `README.md`: This documentation file.
  
## How it Works

### Frame and Line Generation

1. **Frame Timing**: The module outputs a total of 43,200 pixels (240x180) per frame at 40 frames per second. Each pixel value is represented as a 10-bit grayscale value.
2. **Line Blanking**: After each line of 240 pixels, a blanking period of 10 µs (1330 clock cycles) is introduced, during which no pixel data is output (`line_valid` goes low).
3. **Frame Rate**: The module generates a new frame every 25 ms (40 FPS), with a delay between frames to achieve this rate.

### Signals

- **Pixel Output (`pixel_out`)**: 10-bit grayscale value ranging from 0 to 239. Each value represents a pixel in the color bar.
- **Frame Valid (`frame_valid`)**: Active during the entire frame. It can be monitored on an oscilloscope to observe the start and end of a frame.
- **Line Valid (`line_valid`)**: Active during each line of pixel output and goes low during the blanking period.

## Usage

To integrate the grayscale color bar generator into your design:

1. **Instantiate the Top Module (`top`)**: This will automatically set up the clock, control signals, and grayscale generation.
2. **Monitor `frame_valid` and `line_valid`**: These can be connected to external monitors or probes to validate the timing of frames and lines.
3. **Connect the `pixel_out` Signal**: This 10-bit signal outputs the grayscale pixel values that can be fed into a display driver or other processing logic.
