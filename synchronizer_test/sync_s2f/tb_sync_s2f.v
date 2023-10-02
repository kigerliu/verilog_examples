`timescale 1ns/1ns
`define HALF_PERIOD_CLK_S 18
`define HALF_PERIOD_CLK_F 5

module tb_sync_s2f;

    reg         clk_f   ;
    reg         clk_s   ;
    wire        rd_en_i ;
    wire        rd_en_o ;
    reg         rstn    ;

    reg [15:0]  dat_i = 16'b0101001110101101;

    assign      rd_en_i = dat_i[15];

    initial begin
        clk_s = 1'b0;
        clk_f = 1'b0;
    end
    
    always #(`HALF_PERIOD_CLK_S) clk_s = ~clk_s;
    always #(`HALF_PERIOD_CLK_F) clk_f = ~clk_f;

    always @(posedge clk_s) begin
        dat_i = dat_i << 1;
    end

    sync_s2f sync_s2f(
        .clk    (clk_f   ) ,
        .rd_en_i(rd_en_i ) ,
        .rd_en_o(rd_en_o ) ,
        .rstn   (rstn    ) 
    );

endmodule