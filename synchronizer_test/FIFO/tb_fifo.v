// testbench of fifo (top module)
`timescale 1ns/1ps
`define HALF_CLK_PERIOD_RD 5
`define HALF_CLK_PERIOD_WR 18

module tb_fifo;

    parameter                           FIFO_DEPTH      =   8   ;
    parameter                           FIFO_DAT_WD     =   4   ;
    parameter                           FIFO_ADDR_WD    =   3   ;


    reg                                 wr_clk      ;
    reg                                 wr_rstn     ;
    reg     [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
    wire                                wr_en_i     ;
    reg                                 rd_clk      ;
    reg                                 rd_rstn     ;
    wire    [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
    wire                                rd_en_i     ;

    fifo #(.FIFO_DEPTH(FIFO_DEPTH), .FIFO_DAT_WD(FIFO_DAT_WD), .FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo(
        .wr_clk     (   wr_clk      ),
        .wr_rstn    (   wr_rstn     ),
        .wr_dat_i   (   wr_dat_i    ),
        .wr_en_i    (   wr_en_i     ),
        .rd_clk     (   rd_clk      ),
        .rd_rstn    (   rd_rstn     ),
        .rd_dat_o   (   rd_dat_o    ),
        .rd_en_i    (   rd_en_i     ) 
    );

    reg     [64             -1:0]       rd_en_i_array   = 64'b0100000000000000000000000000000001010101010101010101010101010101;
    reg     [64             -1:0]       wr_en_i_array   = 64'b0000001010101010101010101010101010101010101010101010101010101010;

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

    always @(posedge wr_clk or negedge wr_rstn) begin
        if(~wr_rstn) begin
            wr_dat_i = 0;
        end
        else begin
            wr_dat_i = wr_dat_i + 1'b1;
        end
    end

endmodule