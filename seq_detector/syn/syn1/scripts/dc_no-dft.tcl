set DESIGN seq_detector_1010
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
analyze -autoread ../../../rtl/ -define {BSV_ASYNC_RESET BSV_RESET_FIFO_HEAD BSV_RESET_FIFO_ARRAY}
elaborate $DESIGN
current_design $DESIGN
link

#set_dont_use [get_lib_cells *tsl18fs*/*d0*]
#set_dont_touch [get_instances {top/soc_reset/reset_hold*}]


source ../scripts/$DESIGN.sdc
source ../scripts/appvariables.tcl
set_max_area 0
set_dont_retime $DESIGN true

source ../scripts/create_path_group.tcl
set verilogout_no_tri  "true"

compile_ultra -no_boundary_optimization -no_autoungroup -no_seq_output_inversion -timing_high_effort_script

define_name_rules verilog -allowed "a-z A-Z 0-9 _ /"
report_name_rules verilog

change_names -hier -rules verilog

uniquify

write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/$DESIGN.verilog.v
write -format ddc -hierarchy -output ../${_OUTPUTS_PATH}/$DESIGN.incr_compile.ddc

report_qor > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.qor
report_timing -nosplit -max_paths 20 -cap -tran -nosplit -sig 3 -group f2f      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.f2f.tim.rpt
report_timing -nosplit -max_paths 20 -cap -tran -nosplit -sig 3 -group i2f      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.i2f.tim.rpt
report_timing -nosplit -max_paths 20 -cap -tran -nosplit -sig 3 -group f2o      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.f2o.tim.rpt
report_timing -nosplit -max_paths 20 -cap -tran -nosplit -sig 3 -group i2o      > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.setup.i2o.tim.rpt

report_area -nosplit -hier > ../${_REPORTS_PATH}/$DESIGN.dc_compile_ultra_1.area.rpt
report_power > ../${_REPORTS_PATH}/$DESIGN.power.rpt

remove_attribute [get_cells {U_SCAN_EN_HOOKUP}] dont_touch

set verilogout_no_tri  "true"
set_app_var compile_advanced_fix_multiple_port_nets "true"
set_fix_multiple_port_nets -all -buffer_constants
change_names -hier -rules verilog

write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.verilog_noassign.v
uniquify
write -format verilog -hierarchy -output ../${_OUTPUTS_PATH}/${DESIGN}.verilog_noassign_uniquified.v

#exit
