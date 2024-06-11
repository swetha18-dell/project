set DESIGN mksoc_top_wrapper
set DATE [clock format [clock seconds] -format "%b%d-%T"]
set _OUTPUTS_PATH outputs_${DESIGN}
set _REPORTS_PATH reports_${DESIGN}
####
source ../scripts/path.tcl
set_host_options -max_cores 8

file mkdir ../${_OUTPUTS_PATH}
file mkdir ../${_REPORTS_PATH}
set_svf ../${_OUTPUTS_PATH}/${DESIGN}.svf
source ../scripts/dont_use.tcl
analyze -autoread ../rtl/ -define {BSV_ASYNC_RESET BSV_RESET_FIFO_HEAD BSV_RESET_FIFO_ARRAY}
elaborate $DESIGN
current_design $DESIGN
link

#set_dont_use [get_lib_cells *tsl18fs*/*d0*]

set_dont_touch [get_references -hierarchical mod_dfcrq1] true
set_dont_touch [get_references -hierarchical mod_mux] false
#set_dont_touch {i_edt_in_1 i_edt_in_2 i_edt_in_3 i_edt_in_4 i_edt_in_5 i_edt_in_6 i_edt_in_7 i_edt_in_8 i_edt_in_9 i_edt_in_10}
#set_dont_touch {o_mx_edt_out1_pwm1 o_mx_edt_out2_pwm2 o_mx_edt_out3_pwm3 o_mx_edt_out4_pwm4 o_mx_edt_out5_pwm5 o_mx_edt_out6_pwm6 o_mx_edt_out7_pwm7 o_mx_edt_out8_pwm8 o_mx_edt_out8_pwm9 o_mx_edt_out8_pwm10}
#set_dont_touch [get_instances *edt*]
#set_dont_touch [get_instances {top/soc_reset/reset_hold*}]

# fail1
#set_dont_touch [get_cells -hierarchical -rtl {reset_hold*}]
set_dont_touch [get_cells {U_SCAN_EN_HOOKUP}]
#set_dont_touch [get_cells {top/U_DFT_FIX}]


write -f ddc     -hier -o  ../${_OUTPUTS_PATH}/$DESIGN.gtech.hier.ddc
write -f verilog -hier -o  ../${_OUTPUTS_PATH}/$DESIGN.gtech.hier.v

source ../scripts/$DESIGN.sdc
source ../scripts/appvariables.tcl
set_max_area 0
set_dont_retime $DESIGN true
#set_clock_gating_check -setup 0.75 -hold 0.5

source ../scripts/create_path_group.tcl
check_design                             > ../${_REPORTS_PATH}/$DESIGN.check_design.pre_compile.rpt
report_net_fanout -threshold 50 -nosplit > ../${_REPORTS_PATH}/$DESIGN.fanout.pre_compile.rpt
set verilogout_no_tri  "true"

write -f ddc     -hier -o   ../${_OUTPUTS_PATH}/$DESIGN.compile.ddc
write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/$DESIGN.precompile.verilog.v


compile_ultra -no_boundary_optimization -no_autoungroup -no_seq_output_inversion -timing_high_effort_script

define_name_rules verilog -allowed "a-z A-Z 0-9 _ /"
report_name_rules verilog

change_names -hier -rules verilog

uniquify

write_sdc ../${_OUTPUTS_PATH}/$DESIGN.dc_compile_ultra_1.sdc
write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/$DESIGN.verilog.v
write -format ddc -hierarchy -output ../${_OUTPUTS_PATH}/$DESIGN.incr_compile.ddc
write_parasitics -output ../${_OUTPUTS_PATH}/$DESIGN.out.spef
write_sdf ../${_OUTPUTS_PATH}/$DESIGN.out.sdf

report_qor > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.qor
report_timing -nosplit -max_paths 25 -input -nets -cap -tran -nosplit -sig 3                 > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.all.tim.rpt.by_group
report_timing -nosplit -max_paths 25 -input -nets -cap -tran -nosplit -sig 3 -sort_by slack  > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.all.tim.rpt.by_slack
report_timing -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 -group f2f      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.f2f.tim.rpt
report_timing -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 -group i2f      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.i2f.tim.rpt
report_timing -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 -group f2o      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.f2o.tim.rpt
report_timing -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 -group i2o      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.i2o.tim.rpt
#report_timing -through [get_ports SDRAM_*] -nosplit -max_paths 25 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.sdram.rpt
#report_timing -through [get_ports SPI0_*]  -nosplit -max_paths 25 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.spi0.rpt
#report_timing -through [get_ports SPI1_*]  -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.spi1.rpt
#report_timing -through [get_ports QSPI0_*] -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.qspi0.rpt
#report_timing -through [get_ports I2C0_*]  -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.i2c0.rpt
#report_timing -through [get_ports I2C1_*]  -nosplit -max_paths 20 -input -nets -cap -tran -nosplit -sig 3 > ../${_REPORTS_PATH}/$DESIGN.i2c1.rpt

report_area -nosplit -hier > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.area.rpt
report_clock_gating -verbose -gated  -gating_elements  > ../${_REPORTS_PATH}/$DESIGN.dc_compile_1.clock_gate.rpt
check_design                             > ../${_REPORTS_PATH}/$DESIGN.check_design.dc_compile_1.rpt
report_net_fanout -threshold 50 -nosplit > ../${_REPORTS_PATH}/$DESIGN.fanout.dc_compile_1.rpt
check_timing                             > ../${_REPORTS_PATH}/$DESIGN.check_timing.dc_compile_1.rpt
report_resources -nosplit -hierarchy > ../${_REPORTS_PATH}/$DESIGN.report_resources.compile_1
report_power > ../${_REPORTS_PATH}/$DESIGN.power.rpt
report_clock_gating_check > ../${_REPORTS_PATH}/$DESIGN.clockgating_check.rpt
######read_ddc  ../${_OUTPUTS_PATH}/$DESIGN.incr_compile.ddc

remove_attribute [get_cells {U_SCAN_EN_HOOKUP}] dont_touch

#fail2
#set_dont_touch [get_cells -hierarchical {reset_hold*}]
#fail4 fail5 (dft_cons)
#set_dont_touch [get_cells {top/soc_reset/reset_hold*}]
#fail8
#set_dont_touch [get_designs {MakeResetA_*}]
#set_dont_touch [get_designs {SyncReset_*}]

set_dont_touch [get_references -hierarchical mod_dfcrq1] false

source ../scripts/dft_cons_mksoc_top_wrapper.src
##source ../scripts/dft_gopi_cons.src
set_dft_drc_configuration -allow_se_set_reset_fix true
create_test_protocol
dft_drc > ../${_REPORTS_PATH}/${DESIGN}_predft_drc.rpt
preview_dft -show all -test_points all > ../${_REPORTS_PATH}/autofix.pts
dft_drc -verbose > ../${_REPORTS_PATH}/${DESIGN}_predft_drc_verb.rpt
#set_scan_path chain1 -head_elements {} -tail_elements {}
insert_dft
compile_ultra -scan -no_autoungroup -no_seq_output_inversion -incremental -timing_high_effort_script

#fail3 fail4 fail5 (dft_cons) fail8
#compile_ultra -scan -no_boundary_optimization -no_autoungroup -no_seq_output_inversion -timing_high_effort_script -incremental
report_dft_signal > ../${_REPORTS_PATH}/dft_signal.txt
dft_drc > ../${_REPORTS_PATH}/${DESIGN}_postdft_drc.rpt
dft_drc -verbose > ../${_REPORTS_PATH}/${DESIGN}_postdft_drc_verb.rpt
dft_drc -cov > ../${_REPORTS_PATH}/${DESIGN}_dft_coverage.rpt
report_scan_path -view existing -chain all > ../${_REPORTS_PATH}/${DESIGN}_scanchains.rpt
report_scan_path -view existing -cell all > ../${_REPORTS_PATH}/${DESIGN}_scanchain_cells.rpt
write_test_protocol -output ../${_OUTPUTS_PATH}/${DESIGN}.spf
write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.verilog_postdft.v
write -format ddc -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.incr_compile_dft.ddc
write_parasitics -output ../${_OUTPUTS_PATH}/${DESIGN}.out.spef
write_sdf -version 1.0 ../${_OUTPUTS_PATH}/${DESIGN}.out.sdf_1.0
#write_scan_def -output ../${_OUTPUTS_PATH}/${DESIGN}.scan_def.def

set verilogout_no_tri  "true"
set_app_var compile_advanced_fix_multiple_port_nets "true"
set_fix_multiple_port_nets -all -buffer_constants
change_names -hier -rules verilog

write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.verilog_postinsert_noassign.v

uniquify

write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.verilog_postinsert_noassign_uniquified.v

write_sdf -version 1.0 ../${_OUTPUTS_PATH}/${DESIGN}.out.sdf_1.0.uniquified
write_scan_def -output ../${_OUTPUTS_PATH}/${DESIGN}.scan_def.def

#exit
