## common parameter settings
set_units -time ns
set DUTYCYCLE   0.5;
set OD_RATIO    0.6;
set ID_RATIO    0.6;
set ITRANSITION 0.5;
set OLOAD       0.2;

## clock specific parameters
set MAINCLK     CLK;
set MAINPERIOD  5.0;
set UNCERTAINTY 0.2;
set MAINWAVE    [list 0.0000 [expr ${MAINPERIOD}*${DUTYCYCLE}]];

# create clocks
create_clock -name ${MAINCLK} -period ${MAINPERIOD} -waveform ${MAINWAVE} [get_ports clk]
set_clock_uncertainty ${UNCERTAINTY} ${MAINCLK}

set_max_transition 1.0 -data_path [get_clocks CLK]

set_input_delay -clock CLK 2.5 [all_inputs]
set_output_delay -clock CLK 2.5 [all_outputs]

#set_dont_touch [get_pins Test_*] true
