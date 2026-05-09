## Clock signal
create_clock -name clk -period 20.000 [get_ports clock]
#set_input_delay 0.001 -clock clk [all_inputs]
#set_output_delay 0.001 -clock clk [all_outputs]