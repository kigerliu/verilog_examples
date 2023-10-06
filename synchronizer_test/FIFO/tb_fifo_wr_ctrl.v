// testbench of fifo_wr_ctrl
`timescale 1ns/1ps
`define HALF_CLK_PERIOD 5

module tb_fifo_wr_ctrl;

    localparam                          FIFO_ADDR_WD    =   3   ;

    reg                                 wr_clk          ;
    reg                                 wr_rstn         ;
    wire                                wr_en_i         ;
    wire                                wr_full_o       ;
    wire   [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;   // write address
    reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_i   ;   // read address (sync)

    reg    [32              -1:0]       wr_en_i_array   = 32'b00101010101010101010101010101010;
    // reg    [32              -1:0]       wr_en_i_array   = 32'b00111111111111111111111111111111;
    reg    [32              -1:0]       rd_ptr_mv_array = 32'b00000010010010000010000010000000;
    wire                                rd_ptr_mv_symb  ;   // if it is 1'b1, move the read address

   fifo_wr_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_wr_ctrl(
        .wr_clk         (   wr_clk          ),
        .wr_rstn        (   wr_rstn         ),
        .wr_en_i        (   wr_en_i         ),
        .wr_full_o      (   wr_full_o       ),
        .wr_ptr_o       (   wr_ptr_o        ),
        .rd_ptr_sync_i  (   rd_ptr_sync_i   )
    );

    assign  wr_en_i         = wr_en_i_array     [32 -1] ;
    assign  rd_ptr_mv_symb  = rd_ptr_mv_array   [32 -1] ;

    // wr_clk
    initial begin
        wr_clk          =   1'b0    ;
    end

    always # (`HALF_CLK_PERIOD) wr_clk = ~ wr_clk;

    // wr_rstn
    initial begin
        wr_rstn         =   1'b0    ;
        # (2.7 * `HALF_CLK_PERIOD);
        wr_rstn         =   1'b1    ;
    end

    // rd_ptr_sync_i
    initial begin
        rd_ptr_sync_i   =   3'b000  ;
    end
    // change the rd_ptr_sync_i signal
    always@(posedge wr_clk) begin
        if(wr_rstn) begin
            if(rd_ptr_mv_symb) begin
                case(rd_ptr_sync_i)
                    3'b000:     rd_ptr_sync_i <= 3'b001;
                    3'b001:     rd_ptr_sync_i <= 3'b011;
                    3'b011:     rd_ptr_sync_i <= 3'b010;
                    3'b010:     rd_ptr_sync_i <= 3'b110;
                    3'b110:     rd_ptr_sync_i <= 3'b111;
                    3'b111:     rd_ptr_sync_i <= 3'b101;
                    3'b101:     rd_ptr_sync_i <= 3'b100;
                    3'b100:     rd_ptr_sync_i <= 3'b000;
                endcase
            end
        end
    end

    // change the wr_en_i & rd_ptr_mv_array
    always@(posedge wr_clk) begin
        if(wr_rstn) begin
            wr_en_i_array   = wr_en_i_array     << 1;
            rd_ptr_mv_array = rd_ptr_mv_array   << 1;
        end
    end

endmodule