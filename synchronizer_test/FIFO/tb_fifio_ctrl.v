// testbench of fifo_ctrl
`timescale 1ns/1ps
`define HALF_CLK_PERIOD_RD 5
`define HALF_CLK_PERIOD_WR 18

module tb_fifo_ctrl;

    localparam                          FIFO_ADDR_WD    =   3   ;

    reg                                 rd_clk          ;
    reg                                 rd_rstn         ;
    wire                                rd_en_i         ;
    wire                                rd_empty_o      ;
    wire   [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
    reg                                 wr_clk          ;
    reg                                 wr_rstn         ;
    wire                                wr_en_i         ;
    wire                                wr_full_o       ;
    wire   [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
    
    reg    [64              -1:0]       rd_en_i_array   = 64'b0100000000000000000000000000000001010101010101010101010101010101;
    reg    [64              -1:0]       wr_en_i_array   = 64'b0000001010101010101010101010101010101010101010101010101010101010;

    fifo_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_ctrl(
        .rd_clk     (   rd_clk      ),
        .rd_rstn    (   rd_rstn     ),
        .rd_en_i    (   rd_en_i     ),
        .rd_empty_o (   rd_empty_o  ),
        .rd_ptr_o   (   rd_ptr_o    ),
        .wr_clk     (   wr_clk      ),
        .wr_rstn    (   wr_rstn     ),
        .wr_en_i    (   wr_en_i     ),
        .wr_full_o  (   wr_full_o   ),
        .wr_ptr_o   (   wr_ptr_o    )
    );
    
    assign  rd_en_i         = rd_en_i_array     [64 -1] ;
    assign  wr_en_i         = wr_en_i_array     [64 -1] ;

    initial begin
        rd_clk = 1'b0;
        wr_clk = 1'b0;
    end

    always #(`HALF_CLK_PERIOD_RD) rd_clk = ~rd_clk;
    always #(`HALF_CLK_PERIOD_WR) wr_clk = ~wr_clk;

    initial begin
        rd_rstn = 1'b0;
        wr_rstn = 1'b0;
        #21;
        rd_rstn = 1'b1;
        wr_rstn = 1'b1;
    end

    always@(posedge rd_clk) begin
        if(rd_rstn) begin
            rd_en_i_array   = rd_en_i_array     << 1;
        end
    end

    always@(posedge wr_clk) begin
        if(wr_rstn) begin
            wr_en_i_array   = wr_en_i_array     << 1;
        end
    end

endmodule