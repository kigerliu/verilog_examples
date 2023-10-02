`timescale 1ns/1ns
`define HALF_PERIOD_CLK_S 18
`define HALF_PERIOD_CLK_F 5

module tb_sync_f2s;

    reg         clk_f       ;
    reg         rstn_f      ;
    reg         clk_s       ;
    reg         rstn_s      ;
    wire        rd_en_i     ;
    wire        rd_en_o     ;

    reg [31:0]  dat_i = 32'b01000000010000010100010101000100;

    assign      rd_en_i = dat_i[31];

    sync_f2s sync_f2s(
        .clk_f      (clk_f      ),
        .rstn_f     (rstn_f     ),
        .clk_s      (clk_s      ),
        .rstn_s     (rstn_s     ),
        .rd_en_i    (rd_en_i    ),
        .rd_en_o    (rd_en_o    )
    );

    initial begin
        clk_s = 1'b0;
        clk_f = 1'b0;
    end

    always #(`HALF_PERIOD_CLK_S) clk_s = ~clk_s;
    always #(`HALF_PERIOD_CLK_F) clk_f = ~clk_f;

    initial begin
        rstn_s = 1'b0;
        rstn_f = 1'b0;
        #21;
        rstn_s = 1'b1;
        rstn_f = 1'b1;
    end

    always @(posedge clk_f or negedge rstn_f) begin
        if(~rstn_f) begin
            dat_i[31] <= 1'b0;
        end
        else begin
            dat_i <= dat_i << 1;
        end
    end

endmodule