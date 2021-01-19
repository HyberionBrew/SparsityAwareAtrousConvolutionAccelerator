onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pe_tb/clk
add wave -noupdate /pe_tb/CLK_PERIOD
add wave -noupdate /pe_tb/finished
add wave -noupdate /pe_tb/ifmap_bitvecs
add wave -noupdate /pe_tb/ifmap_values
add wave -noupdate /pe_tb/kernel_bitvecs
add wave -noupdate /pe_tb/kernel_values
add wave -noupdate /pe_tb/new_ifmaps
add wave -noupdate /pe_tb/new_kernels
add wave -noupdate /pe_tb/reset
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2220544 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 440
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {10500 ns}
