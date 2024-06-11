create_clock -period 5 -waveform {0.0 2.5} [get_ports Clk]

set_input_delay -clock Clk 1 [all_inputs]

set_output_delay -clock Clk 1 [all_outputs]
