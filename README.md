# Overview

# Requirments
- Icarus verilog simulator
- GTKWave

# Running the pipelines
To test each of the two pipelines, run `generate_sim.bat histogram_pipeline/camera_pipeline_tb` or `generate_sim.bat histogram_pipeline/camera_pipeline_tb`.


The following tests may also be run to see how the modules work:

### Histogram pipeline modules
camera_data_gen_tb
dpram_tb
histogam2_tb
ram_dq_tb
read_image_tb
soft_ram_dp_tb

### I2C pipeline modules
i2c_regmap_tb
rom_tb
state_machine_tb
timer_tb
top_tb