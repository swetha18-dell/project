create_mw_lib -technology ../scripts/icc.tf -mw_reference_library {/pdk/180nm/stdlib/fs120/mw/fs120_scl/ } ../database/upordown_counter_mw
open_mw_lib ../database/upordown_counter_mw

set hdlin_enable_rtldrc_info true
set enable_recovery_removal_arcs true

