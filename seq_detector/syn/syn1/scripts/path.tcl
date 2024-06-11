set PDK_PATH /pdk/
set TOOL_PATH /tools/pd_tools
set target_library    [list]
set link_library      "*"
set mw_reference_lib  "*"
set synthetic_library [list \
$TOOL_PATH/synopsys/syn/O-2018.06-SP5-4/libraries/syn/dw_foundation.sldb \
$TOOL_PATH/synopsys/syn/O-2018.06-SP5-4/libraries/syn/standard.sldb \
$TOOL_PATH/synopsys/syn/O-2018.06-SP5-4/libraries/syn/dft_jtag.sldb \
$TOOL_PATH/synopsys/syn/O-2018.06-SP5-4/libraries/syn/dft_lbist.sldb \
$TOOL_PATH/synopsys/syn/O-2018.06-SP5-4/libraries/syn/dft_mbist.sldb \
]

set target_library      [concat $target_library \
$PDK_PATH/180nm/stdlib/fs120/liberty/lib_flow_ss/tsl18fs120_scl_ss.db \
$PDK_PATH/180nm/memlib/spram_64x32/SPRAM_64x32_max.db \
$PDK_PATH/180nm/memlib/SPRAM_64x27/SPRAM_64x27_max.db \
]

set link_library      [concat $link_library \
$PDK_PATH/180nm/stdlib/fs120/liberty/lib_flow_ss/tsl18fs120_scl_ss.db \
$PDK_PATH/180nm/memlib/spram_64x32/SPRAM_64x32_max.db \
$PDK_PATH/180nm/memlib/SPRAM_64x27/SPRAM_64x27_max.db \
]


set link_library      [concat $link_library $target_library $synthetic_library]

