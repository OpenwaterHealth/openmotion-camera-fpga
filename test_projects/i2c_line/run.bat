@echo off
rem Usage: run.bat <tb_name_without_extension>
setlocal
set IVERILOG=C:\iverilog\bin\iverilog.exe
set VVP=C:\iverilog\bin\vvp.exe
cd /d %~dp0..
if not exist out mkdir out
%IVERILOG% -g2005 -o out\%1.vvp -I . i2c_line\%1.v || exit /b 1
%VVP% out\%1.vvp
