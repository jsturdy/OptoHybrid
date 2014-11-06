
REM
REM   ____  ____
REM  /   /\/   /
REM /___/  \  /    Vendor: Xilinx
REM \   \   \/     Version : 1.11
REM  \   \         Application : Spartan-6 FPGA GTP Transceiver Wizard
REM  /   /         Filename : implement_sh.ejava
REM /___/   /\      
REM \   \  /  \
REM  \___\/\___\
REM
REM
REM implement.sh script
REM Generated by Xilinx Spartan-6 FPGA GTP Transceiver Wizard
REM

REM Set XST as default synthesizer

REM Read command line arguments

REM Change CWD to results

REM Clean results directory
REM Create results directory
REM Change current directory to results
ECHO WARNING: Removing existing results directory
RMDIR /S /Q results
MKDIR results
COPY xst.prj      .\results\
COPY xst.scr      .\results\
COPY *.ngc        .\results\

REM Run Synthesis

ECHO "### Running Xst - "
xst -ifn xst.scr

COPY s6_gtpwizard_v1_11_top.ngc .\results
cd .\results

REM Run ngdbuild

ngdbuild -uc ..\..\example_design\s6_gtpwizard_v1_11_top.ucf -p xc6slx150t-fgg676-3 s6_gtpwizard_v1_11_top.ngc s6_gtpwizard_v1_11_top.ngd

REM end run ngdbuild section

REM Run map

ECHO 'Running NGD'
map -register_duplication on -global_opt speed -logic_opt on -retiming on -timing -ol high -p xc6slx150t-fgg676-3 -o mapped.ncd s6_gtpwizard_v1_11_top.ngd

REM Run par

ECHO 'Running par'
par -ol high mapped.ncd routed.ncd 

REM Report par results

ECHO 'Running design through bitgen'
bitgen -w routed.ncd

REM Trace Report

ECHO 'Running trce'
trce -e 10 routed.ncd mapped.pcf -o routed

REM Run netgen

ECHO 'Running netgen to create gate level VHDL model'
netgen -ofmt vhdl -sim -dir . -tm s6_gtpwizard_v1_11_top -w routed.ncd routed.vhd

REM Change directory to implement

CD ..

