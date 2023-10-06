// First-In-First-Out, Depth: 8bits
// reference: SoC Design (E.4), Chapter 7.3.3, Page 119

// Control part of FIFO (Rd. & Wr.)
module fifo_ctrl(
    rd_clk          ,
    rd_rstn         ,
    rd_en_i         ,
    rd_empty_o      ,
    rd_ptr_o        ,
    wr_clk          ,
    wr_rstn         ,
    wr_en_i         ,
    wr_full_o       ,
    wr_ptr_o        
);

    parameter                           FIFO_ADDR_WD    =   3   ;

    input                               rd_clk          ;
    input                               rd_rstn         ;
    input                               rd_en_i         ;
    output                              rd_empty_o      ;
    output [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
    input                               wr_clk          ;
    input                               wr_rstn         ;
    input                               wr_en_i         ;
    output                              wr_full_o       ;
    output [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
    
    wire   [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_r   ;
    wire   [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_r   ;

    reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_1_r      ;
    reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_2_r      ;
    reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_1_r      ;
    reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_2_r      ;
    
    assign  rd_ptr_sync_r = rd_ptr_2_r;
    assign  wr_ptr_sync_r = wr_ptr_2_r;

    always@(posedge rd_clk or negedge rd_rstn) begin
        if(~rd_rstn) begin
            wr_ptr_1_r <= 3'b000;
            wr_ptr_2_r <= 3'b000;
        end
        else begin
            {wr_ptr_2_r,wr_ptr_1_r} <= {wr_ptr_1_r,wr_ptr_o};
        end
    end

    always@(posedge wr_clk or negedge wr_rstn) begin
        if(~wr_rstn) begin
            rd_ptr_1_r <= 3'b000;
            rd_ptr_2_r <= 3'b000;
        end
        else begin
            {rd_ptr_2_r,rd_ptr_1_r} <= {rd_ptr_1_r,rd_ptr_o};
        end
    end

    fifo_rd_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_rd_ctrl(
        .rd_clk         (   rd_clk          ),
        .rd_rstn        (   rd_rstn         ),
        .rd_en_i        (   rd_en_i         ),
        .rd_empty_o     (   rd_empty_o      ),
        .rd_ptr_o       (   rd_ptr_o        ),
        .wr_ptr_sync_i  (   wr_ptr_sync_r   )
    );

    fifo_wr_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_wr_ctrl(
        .wr_clk         (   wr_clk          ),
        .wr_rstn        (   wr_rstn         ),
        .wr_en_i        (   wr_en_i         ),
        .wr_full_o      (   wr_full_o       ),
        .wr_ptr_o       (   wr_ptr_o        ),
        .rd_ptr_sync_i  (   rd_ptr_sync_r   )
    );

endmodule