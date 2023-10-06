// testbench of fifo_rd_ctrl
`timescale 1ns/1ps
`define HALF_CLK_PERIOD 5

module tb_fifo_rd_ctrl;

    localparam                          FIFO_ADDR_WD    =   3   ;

    reg                                 rd_clk          ;
    reg                                 rd_rstn         ;
    wire                                rd_en_i         ;
    wire                                rd_empty_o      ;
    wire   [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;   // read address
    reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_i   ;   // write address (sync)

    reg    [32              -1:0]       rd_en_i_array   = 32'b00101000000000000000101010101010;
    // reg    [32              -1:0]       rd_en_i_array   = 32'b00111111111111111111111111111111;
    reg    [32              -1:0]       wr_ptr_mv_array = 32'b00001010101010101010001000100010;
    wire                                wr_ptr_mv_symb  ;   // if it is 1'b1, move the write address

   fifo_rd_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_rd_ctrl(
        .rd_clk         (   rd_clk          ),
        .rd_rstn        (   rd_rstn         ),
        .rd_en_i        (   rd_en_i         ),
        .rd_empty_o     (   rd_empty_o      ),
        .rd_ptr_o       (   rd_ptr_o        ),
        .wr_ptr_sync_i  (   wr_ptr_sync_i   )
    );

    assign  rd_en_i         = rd_en_i_array     [32 -1] ;
    assign  wr_ptr_mv_symb  = wr_ptr_mv_array   [32 -1] ;

    // rd_clk
    initial begin
        rd_clk          =   1'b0    ;
    end

    always # (`HALF_CLK_PERIOD) rd_clk = ~ rd_clk;

    // rd_rstn
    initial begin
        rd_rstn         =   1'b0    ;
        # (2.7 * `HALF_CLK_PERIOD);
        rd_rstn         =   1'b1    ;
    end

    // wr_ptr_sync_i
    initial begin
        wr_ptr_sync_i   =   3'b000  ;
    end
    // change the wr_ptr_sync_i signal
    always@(posedge rd_clk) begin
        if(rd_rstn) begin
            if(wr_ptr_mv_symb) begin
                case(wr_ptr_sync_i)
                    3'b000:     wr_ptr_sync_i <= 3'b001;
                    3'b001:     wr_ptr_sync_i <= 3'b011;
                    3'b011:     wr_ptr_sync_i <= 3'b010;
                    3'b010:     wr_ptr_sync_i <= 3'b110;
                    3'b110:     wr_ptr_sync_i <= 3'b111;
                    3'b111:     wr_ptr_sync_i <= 3'b101;
                    3'b101:     wr_ptr_sync_i <= 3'b100;
                    3'b100:     wr_ptr_sync_i <= 3'b000;
                endcase
            end
        end
    end

    // change the rd_en_i & wr_ptr_mv_array
    always@(posedge rd_clk) begin
        if(rd_rstn) begin
            rd_en_i_array   = rd_en_i_array     << 1;
            wr_ptr_mv_array = wr_ptr_mv_array   << 1;
        end
    end

endmodule