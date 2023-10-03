# replace these with your own DesignUnderTest, testbench, simulation time
set TB_DUT_TOP "tb_sync_f2s"
set DUT_TOP "sync_f2s"
set SIM_TIME "1.2us"

vlib work
vlog +acc ../*.v
# vlog +acc ../tb_wifi_top_simple.v
# vlog +acc ../wifi_crc_1x.v
# vlog +acc ../wifi_crc_2x.v
# vlog +acc ../wifi_crc_main.v
# vlog +acc ../wifi_main_cnt.v
# vlog +acc ../wifi_main_com.v
# vlog +acc ../wifi_main_dsel.v
# vlog +acc ../wifi_main_out.v
# vlog +acc ../wifi_main_soh.v
# vlog +acc ../wifi_main_srst.v
# vlog +acc ../wifi_main_top.v
# vlog +acc ../wifi_spi_top.v
# vlog +acc ../wifi_top.v

vsim -voptargs=+acc work.$TB_DUT_TOP

add wave sim:/$TB_DUT_TOP/$DUT_TOP/*
# add wave sim:/$TB_DUT_TOP/$DUT_TOP/sync_f2s_f/sync_f2s_f_ckgt/*
# view -new wave
# add wave sim:/$TB_DUT_TOP/*

run $SIM_TIME