set_host_options -max_cores 32
set search_path [ list "/pdk/180nm/stdlib/fs120/liberty/lib_flow_ss" "/pdk/180nm/stdlib/fs120/liberty/lib_flow_ff" ]
set work_dir ./.

set_app_var link_library "tsl18fs120_scl_ss.db"
set_app_var target_library "tsl18fs120_scl_ss.db"

set_min_library tsl18fs120_scl_ss.db    -min_version tsl18fs120_scl_ff.db
set symbol_library ""

set_tlu_plus_files -max_tluplus \
/pdk/180nm/design_kit/icc_tech/tluplus/RCE_TS18SL_SCL_STAR_RCXT_4M1L_TYP.tlup -tech2itf_map \
/pdk/180nm/design_kit/icc_tech/RCE_TS18SL_STAR_RCXT_4M1L.map
