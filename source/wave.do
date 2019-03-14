onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test/clk
add wave -noupdate /test/rst_n
add wave -noupdate /test/inst
add wave -noupdate /test/r_addr
add wave -noupdate /test/r_data
add wave -noupdate /test/out_data
add wave -noupdate /test/out_rdy
add wave -noupdate /test/DUT/pixel_request/in_row
add wave -noupdate /test/DUT/pixel_request/in_column
add wave -noupdate -expand /test/DUT/scratchpad/out_data
add wave -noupdate /test/DUT/scratchpad/req_data
add wave -noupdate -expand /test/DUT/scratchpad/req
add wave -noupdate -expand /test/DUT/scratchpad/sel
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/in_row}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/in_column}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/in_width}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/in_offset}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/out_req}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/out_sel}
add wave -noupdate {/test/DUT/pixel_request/pixdec[0]/pixel_decoder/pixel}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/in_row}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/in_column}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/in_width}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/in_offset}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/out_req}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/out_sel}
add wave -noupdate {/test/DUT/pixel_request/pixdec[1]/pixel_decoder/pixel}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/in_mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/in_mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[1]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[1]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[2]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[2]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[3]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[3]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[4]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[4]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[5]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[5]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[6]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[6]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[7]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[7]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[8]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[8]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[9]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[9]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[10]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[10]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[11]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[11]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[12]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[12]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[13]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[13]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[14]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[14]/mac/reg_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[15]/mac/in_x}
add wave -noupdate {/test/DUT/sys_array/valid_pixel_coord[1]/col_coord[15]/mac/reg_x}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {475809 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 395
configure wave -valuecolwidth 270
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
configure wave -timelineunits ps
update
WaveRestoreZoom {427648 ps} {479598 ps}
