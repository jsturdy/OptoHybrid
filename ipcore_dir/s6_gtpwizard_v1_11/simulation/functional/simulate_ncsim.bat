   
REM ############################################################################
REM   ____  ____ 
REM  /   /\/   / 
REM /___/  \  /    Vendor: Xilinx 
REM \   \   \/     Version : 1.11
REM  \   \         Application : Spartan-6 FPGA GTP Transceiver Wizard
REM  /   /         Filename : simulate_ncsim.bat
REM /___/   /\  
REM \   \  /  \ 
REM  \___\/\___\ 
REM
REM
REM Script SIMULATE_NCSIM.BAT
REM Generated by Xilinx Spartan-6 FPGA GTP Transceiver Wizard
REM
REM *************************** Beginning of Script ***************************

                
REM Ensure the follwoing
REM The library paths for UNISIMS_VER, SIMPRIMS_VER, XILINXCORELIB_VER,
REM UNISIM, SIMPRIM, XILINXCORELIB are set correctly in the cds.lib and hdl.var files.
REM Variables LMC_HOME and XILINX are set 
REM Define the mapping for the work library in cds.lib file. DEFINE work ./work

mkdir work
REM MGT Wrapper
ncvhdl -RELAX -V93 -work work   ../../../s6_gtpwizard_v1_11_tile.vhd;
ncvhdl -RELAX -V93 -work work   ../../../s6_gtpwizard_v1_11.vhd;

ncvhdl -RELAX -V93 -work work  ../../example_design/mgt_usrclk_source_pll.vhd;

REM Example Design modules
ncvhdl -RELAX -V93 -work work   ../../example_design/frame_gen.vhd;
ncvhdl -RELAX -V93 -work work   ../../example_design/frame_check.vhd;
ncvhdl -RELAX -V93 -work work   ../../example_design/s6_gtpwizard_v1_11_top.vhd;
ncvhdl -RELAX -V93 -work work   ../demo_tb.vhd;

REM Other modules
ncvhdl -RELAX -V93 -work work ../sim_reset_mgt_model.vhd;

REM Elaborate Design
ncelab -relax -TIMESCALE 1ns/1ps -ACCESS +rwc work.DEMO_TB

ncsim +access+rw work.DEMO_TB -input @"simvision -input wave_ncsim.sv" 

