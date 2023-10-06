// First-In-First-Out, Depth: 8bits
// reference: SoC Design (E.4), Chapter 7.3.3, Page 119

// FIFO (top module)
module fifo(
    wr_clk      ,
    wr_rstn     ,
    wr_dat_i    ,
    wr_en_i     ,
    rd_clk      ,
    rd_rstn     ,
    rd_dat_o    ,
    rd_en_i      
);

    parameter                           FIFO_DEPTH      =   8   ;
    parameter                           FIFO_DAT_WD     =   4   ;
    parameter                           FIFO_ADDR_WD    =   3   ;


    input                               wr_clk      ;
    input                               wr_rstn     ;
    input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
    input                               wr_en_i     ;
    input                               rd_clk      ;
    input                               rd_rstn     ;
    output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
    input                               rd_en_i     ;


    wire                                wr_full_w   ;
    wire                                rd_empty_w  ;
    wire   [FIFO_ADDR_WD    -1:0]       rd_addr_w   ;
    wire   [FIFO_ADDR_WD    -1:0]       wr_addr_w   ;

    fifo_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_ctrl(
        .rd_clk     (   rd_clk      ),
        .rd_rstn    (   rd_rstn     ),
        .rd_en_i    (   rd_en_i     ),
        .rd_empty_o (   rd_empty_w  ),
        .rd_ptr_o   (   rd_addr_w   ),
        .wr_clk     (   wr_clk      ),
        .wr_rstn    (   wr_rstn     ),
        .wr_en_i    (   wr_en_i     ),
        .wr_full_o  (   wr_full_w   ),
        .wr_ptr_o   (   wr_addr_w   )
    );

    fifo_mem #(.FIFO_DEPTH(FIFO_DEPTH), .FIFO_DAT_WD(FIFO_DAT_WD), .FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_mem(
        .wr_clk     (   wr_clk      ),
        .wr_rstn    (   wr_rstn     ),
        .wr_dat_i   (   wr_dat_i    ),
        .wr_en_i    (   wr_en_i     ),
        .wr_addr_i  (   wr_addr_w   ),
        .wr_full_i  (   wr_full_w   ),
        .rd_clk     (   rd_clk      ),
        .rd_rstn    (   rd_rstn     ),
        .rd_dat_o   (   rd_dat_o    ),
        .rd_en_i    (   rd_en_i     ),
        .rd_addr_i  (   rd_addr_w   ),
        .rd_empty_i (   rd_empty_w  )
    );

endmodule