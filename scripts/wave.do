onerror {resume}
quietly WaveActivateNextPane {} 0
add wave sim:/pe_tb/clk
add wave sim:/pe_tb/reset

add wave -position end -group index_info sim:/pe_tb/index
add wave -position end -group index_info sim:/pe_tb/valid
add wave -position end -group index_info sim:/pe_tb/shift
add wave -position end -group index_info sim:/pe_tb/finished
add wave -position end -group index_info sim:/pe_tb/index
add wave -position end -group index_info sim:/pe_tb/ifmap_index
add wave -position end -group index_info sim:/pe_tb/weight_index


TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {122737 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
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

run 10000 ns

update
WaveRestoreZoom {10956 ps} {124782 ps}
