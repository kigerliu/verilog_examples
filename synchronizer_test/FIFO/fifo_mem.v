// First-In-First-Out, Depth: 8bits
// reference: SoC Design (E.4), Chapter 7.3.3, Page 119

// Memory part of FIFO
module fifo_mem(
    wr_clk      ,
    wr_rstn     ,
    wr_dat_i    ,
    wr_en_i     ,
    wr_addr_i   ,
    wr_full_i   ,
    rd_clk      ,
    rd_rstn     ,
    rd_dat_o    ,
    rd_en_i     ,
    rd_addr_i   ,
    rd_empty_i  
);

    parameter                           FIFO_DEPTH      =   8   ;
    parameter                           FIFO_DAT_WD     =   4   ;
    parameter                           FIFO_ADDR_WD    =   3   ;

    input                               wr_clk      ;
    input                               wr_rstn     ;
    input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
    input                               wr_en_i     ;
    input   [FIFO_ADDR_WD   -1:0]       wr_addr_i   ;
    input                               wr_full_i   ;
    input                               rd_clk      ;
    input                               rd_rstn     ;
    output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
    input                               rd_en_i     ;
    input   [FIFO_ADDR_WD   -1:0]       rd_addr_i   ;
    input                               rd_empty_i  ;

    reg     [FIFO_DAT_WD    -1:0]       fifo_memory [FIFO_DEPTH -1:0]   ;
    reg     [FIFO_DAT_WD    -1:0]       rd_dat_o    ;

    integer                             i;

    always@(posedge wr_clk or negedge wr_rstn) begin
        if(~wr_rstn) begin
            for(i = 0;i < FIFO_ADDR_WD;i = i + 1) begin
                fifo_memory[i] <= 0;
            end
        end
        else begin
            if((wr_en_i == 1'b1) && (wr_full_i == 1'b0)) begin
                fifo_memory[wr_addr_i] <= wr_dat_i;
            end
        end
    end

    always @(posedge rd_clk or negedge rd_rstn) begin
        if(~rd_rstn) begin
            rd_dat_o <= 0;
        end
        else begin
            if((rd_en_i == 1'b1) && (rd_empty_i == 1'b0))  begin
                rd_dat_o <= fifo_memory[rd_addr_i];
            end
        end
    end

endmodule