# Source synchronous DDR input interface timing constraints.  All times are in nanoseconds.
set tcox_max   0.20;         #max clock-to-output time of external device
set tcox_min   -0.20;        #min clock-to-output time of external device                
set tdif_max   0.0;          #max trace delay diff (data-delay minus clock-delay)
set tdif_min   0.0;          #min trace delay diff (data-delay minus clock-delay)
set dly_max   [expr $tcox_max + $tdif_max ]   
set dly_min   [expr $tcox_min + $tdif_min ]

# Bit clock
# fDCO=64 MHz
# TDCO=15.625 ns
# TDCO/2=7.81 ns
create_clock -period 15.625 -name clk_grp -waveform {0.000 7.81} [get_ports DCO_p]

set dat_port  {D_p};    #name of FPGA port(s) where forwarded-data enters FPGA
set clk_nam [get_clocks -of_objects [get_ports {DCO_p}]];  #net-name of forwarded-clock
#
set_input_delay -clock $clk_nam -max $dly_max [get_ports $dat_port ]
set_input_delay -clock $clk_nam -min $dly_min [get_ports $dat_port ]
set_input_delay -clock $clk_nam -max $dly_max -clock_fall -add_delay [get_ports $dat_port ]
set_input_delay -clock $clk_nam -min $dly_min -clock_fall -add_delay [get_ports $dat_port ]

#Simple phase-to-time conversion in MMCM (p. 225 UG906(v2019.2))
set_property PHASESHIFT_MODE LATENCY [get_cells system_i/AXIS_ADC_INTERFACE/Native_ADC_Interface/clk_wiz_0]


#-------------------------------------------------------------------------------------------
# Pin LOC constraints
#-------------------------------------------------------------------------------------------

#FMC 3-WIRE SPI SIGNALS
set_property PACKAGE_PIN A21 [get_ports {SDIO}];  #FMC H37
set_property IOSTANDARD LVCMOS25 [get_ports SDIO]

set_property PACKAGE_PIN A22 [get_ports {SCLK}];  # FMC H38
set_property IOSTANDARD LVCMOS25 [get_ports SCLK]

    #AD9467 CSB 
set_property PACKAGE_PIN B22 [get_ports {CSB[0]}]; #FMC G37
set_property IOSTANDARD LVCMOS25 [get_ports {CSB[0]}]

    #AD9517 CSB 
set_property PACKAGE_PIN B21 [get_ports {CSB[1]}]; #FMC G36
set_property IOSTANDARD LVCMOS25 [get_ports {CSB[1]}]

#Control signals (switches)
#set_property PACKAGE_PIN F22 [get_ports rst]; #Switch 0 = rst
#set_property IOSTANDARD LVCMOS25 [get_ports rst]

# Data clock (64 MHz)
set_property PACKAGE_PIN L18 [get_ports {DCO_p}];  # FMC H4
set_property PACKAGE_PIN L19 [get_ports {DCO_n}];  # FMC H5

# Data input 
    #D0/D1
set_property PACKAGE_PIN M19 [get_ports {D_p[0]}];  # FMC G6
set_property PACKAGE_PIN M20 [get_ports {D_n[0]}];  # FMC G7
    #D2/D3
set_property PACKAGE_PIN N19 [get_ports {D_p[1]}];  # FMC D8 
set_property PACKAGE_PIN N20 [get_ports {D_n[1]}];  # FMC D9 
    #D4/D5
set_property PACKAGE_PIN P17 [get_ports {D_p[2]}];  # FMC H7 
set_property PACKAGE_PIN P18 [get_ports {D_n[2]}];  # FMC H8 
    #D6/D7
set_property PACKAGE_PIN N22 [get_ports {D_p[3]}];  # FMC G9 
set_property PACKAGE_PIN P22 [get_ports {D_n[3]}];  # FMC G10 
    #D8/D9
set_property PACKAGE_PIN M21 [get_ports {D_p[4]}];  # FMC H10 
set_property PACKAGE_PIN M22 [get_ports {D_n[4]}];  # FMC H11 
    #D10/D11
set_property PACKAGE_PIN J18 [get_ports {D_p[5]}];  # FMC D11 
set_property PACKAGE_PIN K18 [get_ports {D_n[5]}];  # FMC D12 
    #D12/D13
set_property PACKAGE_PIN L21 [get_ports {D_p[6]}];  # FMC C10 
set_property PACKAGE_PIN L22 [get_ports {D_n[6]}];  # FMC C11 
    #D14/D15
set_property PACKAGE_PIN T16 [get_ports {D_p[7]}];  # FMC H13
set_property PACKAGE_PIN T17 [get_ports {D_n[7]}];  # FMC H14

set_property IOSTANDARD LVDS_25 [get_ports {DCO_p}];
set_property IOSTANDARD LVDS_25 [get_ports {DCO_n}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[0]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[0]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[1]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[1]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[2]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[2]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[3]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[3]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[4]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[4]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[5]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[5]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[6]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[6]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_p[7]}];
set_property IOSTANDARD LVDS_25 [get_ports {D_n[7]}];