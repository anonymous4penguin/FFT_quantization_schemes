## Clock signal
#set_property PACKAGE_PIN W5 [get_ports {clk}]
#set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
#create_clock -period 10.00 -name sys_clk -waveform {0 5} [get_ports {clk}]
set_property -dict {PACKAGE_PIN W5 IOSTANDARD LVCMOS33} [get_ports CLK]

create_clock -period 5 [get_ports CLK]