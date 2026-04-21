## Nexys 4 Rev. B constraints (official Digilent pinout)

##================ CLOCK =================##
set_property -dict { PACKAGE_PIN E3 IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

##================ VGA RGB =================##
set_property -dict { PACKAGE_PIN A3 IOSTANDARD LVCMOS33 } [get_ports {red[0]}]
set_property -dict { PACKAGE_PIN B4 IOSTANDARD LVCMOS33 } [get_ports {red[1]}]
set_property -dict { PACKAGE_PIN C5 IOSTANDARD LVCMOS33 } [get_ports {red[2]}]
set_property -dict { PACKAGE_PIN A4 IOSTANDARD LVCMOS33 } [get_ports {red[3]}]

set_property -dict { PACKAGE_PIN C6 IOSTANDARD LVCMOS33 } [get_ports {green[0]}]
set_property -dict { PACKAGE_PIN A5 IOSTANDARD LVCMOS33 } [get_ports {green[1]}]
set_property -dict { PACKAGE_PIN B6 IOSTANDARD LVCMOS33 } [get_ports {green[2]}]
set_property -dict { PACKAGE_PIN A6 IOSTANDARD LVCMOS33 } [get_ports {green[3]}]

set_property -dict { PACKAGE_PIN B7 IOSTANDARD LVCMOS33 } [get_ports {blue[0]}]
set_property -dict { PACKAGE_PIN C7 IOSTANDARD LVCMOS33 } [get_ports {blue[1]}]
set_property -dict { PACKAGE_PIN D7 IOSTANDARD LVCMOS33 } [get_ports {blue[2]}]
set_property -dict { PACKAGE_PIN D8 IOSTANDARD LVCMOS33 } [get_ports {blue[3]}]

##================ VGA SYNC =================##
set_property -dict { PACKAGE_PIN B11 IOSTANDARD LVCMOS33 } [get_ports h_sync]
set_property -dict { PACKAGE_PIN B12 IOSTANDARD LVCMOS33 } [get_ports v_sync]

##================ BUTTONS =================##
## BTNC=reset, BTNU=u, BTND=d, BTNL=l, BTNR=r
set_property -dict { PACKAGE_PIN E16 IOSTANDARD LVCMOS33 } [get_ports reset]
set_property -dict { PACKAGE_PIN F15 IOSTANDARD LVCMOS33 } [get_ports u]
set_property -dict { PACKAGE_PIN V10 IOSTANDARD LVCMOS33 } [get_ports d]
set_property -dict { PACKAGE_PIN T16 IOSTANDARD LVCMOS33 } [get_ports l]
set_property -dict { PACKAGE_PIN R10 IOSTANDARD LVCMOS33 } [get_ports r]