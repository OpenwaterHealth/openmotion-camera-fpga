@echo off

rem Check if the user provided a testbench name
if "%1"=="" (
    echo Usage: %0 [testbench_name]
    exit /b 1
)

rem Set the testbench name
set TESTBENCH_FULLPATH=%1
for %%A in ("%TESTBENCH_FULLPATH%") do set "filename=%%~nxA"

rem Create the output directory if it doesn't exist
if not exist out mkdir out

rem Compile the Verilog files
iverilog -o out\%filename%.vvp %TESTBENCH_FULLPATH%.v

rem Run the compiled testbench
vvp out\%filename%.vvp

rem Move the generated files to the output directory
rem move %TESTBENCH_NAME%.vcd out\
rem move out\%TESTBENCH_NAME%.vvp out\

rem Open the VCD file in GTKWave
gtkwave out\%filename%.vcd
