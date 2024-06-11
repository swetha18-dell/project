####### Read the synthesized netlist, constraints and scandef files
set L 100
source ../scripts/icc_lib_setup.tcl
source ../scripts/icc_initial_setup.tcl
#
read_verilog -top upordown_counter -cell upordown_counter {../../syn/outputs_upordown_counter/upordown_counter.verilog_postinsert_noassign.v}                            
read_sdc ../scripts/upordown_counter.sdc

#
link -force
current_design
#
set_user_grid -user_grid {{0 0} {0.005 0.005}}
set_fp_pin_constraints -allowed_layers {M2 M3} -pin_spacing 5 -use_physical_constraints on
source ../scripts/PlacePins.tcl
create_floorplan -control_type width_and_height -core_width $L -core_height $L -no_double_back
#
create_port {VDD VSS} -direction inout
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -tie
connect_net {VDD} {VDD}
connect_net {VSS} {VSS}
#
create_power_straps  -direction vertical  -start_at 10.000 -nets  {VDD VSS}  -layer TOP_M \
-width 2.0 -configure step_and_stop  -step 20 -stop $L -pitch_within_group 5.0
#
preroute_standard_cells -extend_for_multiple_connections  -extension_gap 50 -connect horizontal \
-fill_empty_rows  -port_filter_mode off -cell_master_filter_mode off -cell_instance_filter_mode \
off -voltage_area_filter_mode off -route_type {P/G Std. Cell Pin Conn}
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS} -tie
# verify_pg_nets
set_operating_conditions -analysis_type on_chip_variation -max tsl18fs120_scl_ss -min tsl18fs120_scl_ff \
-min_library {tsl18fs120_scl_ff} -max_library {tsl18fs120_scl_ss}
#
#
set_auto_disable_drc_nets -constant false
set_fix_hold Clk
set_app_var enable_recovery_removal_arcs true
set_place_opt_strategy -layer_optimization_effort high
set_place_opt_strategy -consider_routing  true
create_fp_placement -effort high
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS} -tie
place_opt -effort high -congestion
save_mw_cel -as upordown_counter_PlaceOpt
#report_timing
#report_qor
set unq_input_list [all_inputs]
foreach_in_collection unq_clock_element [all_clocks] {
     set unq_clock_name [get_port  $unq_clock_element]
     set unq_input_list [remove_from_collection $unq_input_list $unq_clock_name]
}
group_path -name f2f -from [all_registers]  -to [all_registers] -critical_range 0.7
group_path -name i2f -from $unq_input_list -to [all_registers] -critical_range 0.7
group_path -name f2o -from [all_registers]  -to [all_outputs]   -critical_range 0.7
group_path -name i2o -from $unq_input_list -to [all_outputs]   -critical_range 0.7

report_timing -delay_type max -transition > ../reports/PlaceOpt_Timing
report_qor > ../reports/PlaceOpt_QOR
#
# CTS steps
check_legality  -verbose
refine_placement -num_cpus 0
legalize_placement -effort high
report_placement_utilization
set_auto_disable_drc_nets -constant false
remove_ideal_network Clk
remove_ideal_network -all
set_propagated_clock [all_clocks]
set_fix_hold [get_clocks *]
set_route_zrt_common_options -read_user_metal_blockage_layer true
set_app_var cto_enable_drc_fixing true
set cts_instance_name_prefix cts
set_si_options -delta_delay true -route_xtalk_prevention true -static_noise true
set_clock_tree_options -target_skew 0.300 -max_transition 0.350 -max_fanout 32
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -tie
#
clock_opt -fix_hold_all_clocks -operating_condition min_max -congestion
report_clock_timing -type summary > ../reports/ClockSummary
report_timing > ../reports/CTS_Timing
report_qor    > ../reports/CTS_QOR
#
save_mw_cel -as upordown_counter_CTS
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS}  -tie
#
remove_ideal_network Clk
set_propagated_clock [all_clocks]
#
set_fix_hold [get_clocks *]
psynopt -only_hold_time
save_mw_cel -as upordown_conter_CTSopt
report_timing > ../reports/CTSopt_Timing
report_qor    > ../reports/CTSopt_QOR
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS}  -tie
verify_pg_nets
#
set_app_var enable_recovery_removal_arcs true
set_fix_hold [get_clocks *]
#
set lib [current_mw_lib]
remove_antenna_rules $lib
set_route_zrt_detail_options  -antenna true -antenna_fixing_preference hop_layers \
-check_antenna_on_pg true -timing_driven true -insert_diodes_during_routing true
define_antenna_rule $lib -mode 4 -diode_mode 1 -metal_ratio 300 -cut_ratio 20
define_antenna_layer_rule $lib -mode 4 -layer "V2" -ratio 20 -diode_ratio {0.203 0 83.33 75}
define_antenna_layer_rule $lib -mode 4 -layer "V3" -ratio 20 -diode_ratio {0.203 0 83.33 75}
define_antenna_layer_rule $lib -mode 4 -layer "TOP_V" -ratio 20 -diode_ratio {0.203 0 83.33 75}
define_antenna_rule $lib -mode 4 -diode_mode 1 -metal_ratio 300 -cut_ratio 20
define_antenna_layer_rule $lib -mode 4 -layer "M1" -ratio 300 -diode_ratio {0.203 0 400 2200}
define_antenna_layer_rule $lib -mode 4 -layer "M2" -ratio 300 -diode_ratio {0.203 0 400 2200}
define_antenna_layer_rule $lib -mode 4 -layer "M3" -ratio 300 -diode_ratio {0.203 0 400 2200}
define_antenna_layer_rule $lib -mode 4 -layer "TOP_M" -ratio 300 -diode_ratio {0.203 0 8000 30000}
#
set_si_options -delta_delay true -static_noise true
set_route_mode_options -zroute true
set_route_zrt_global_options -default true
set_route_zrt_global_options -effort high
set_route_zrt_track_options -default true
set_app_var routeopt_drc_over_timing true
set_route_zrt_detail_options -timing_driven false -antenna true
set_route_zrt_detail_options -drc_convergence_effort_level high
set_route_zrt_detail_options -insert_diodes_during_routing true -diode_libcell_names tsl18fs120_scl_ss/adiode
set_route_opt_strategy  -fix_hold_mode all
#
route_opt -effort high
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS} -tie
#
save_mw_cel -as upordwon_counter_Route
report_timing -transition -capacitance -crosstalk_delta > ../reports/RouteOpt_Timing
report_qor    > ../reports/RouteOpt_QOR
verify_zrt_route > ../reports/DRCreport
#
insert_stdcell_filler  -cell_without_metal "feedth9 feedth3 feedth"  -cell_with_metal "feedth9 feedth3 feedth" \
-connect_to_power {VDD}  -connect_to_ground {VSS}
#
derive_pg_connection -power_net {VDD} -ground_net {VSS} -power_pin {VDD} -ground_pin {VSS}
derive_pg_connection -power_net {VDD} -ground_net {VSS}  -tie
save_mw_cel -as upordown_counter_fillers
#
change_names -rules verilog -hierarchy
write_verilog -pg -no_corner_pad_cells -no_pad_filler_cells -no_core_filler_cells -supply_statement  \
all -split_bus -force_no_output_references {feedth9 feedth3 feedth} ../results/upordown_counter_out.v
#
write_verilog -no_physical_only_cells -no_pg_pin_only_cells -no_corner_pad_cells ../results/upordown_counter_for_pt.v
#
set_write_stream_options -skip_ref_lib_cells
set_write_stream_options -output_pin text -keep_data_type
set_write_stream_options -output_pin geometry
set_write_stream_options -map_layer /pdk/180nm/design_kit/icc_tech/icc_gds_out.map
#
write_stream -format gds -cells {upordown_counter} ../results/upordown_counter.gds
