// First-In-First-Out, Depth: 8bits
// reference: SoC Design (E.4), Chapter 7.3.3, Page 119

// write control part of FIFO
module fifo_wr_ctrl(
    wr_clk          ,
    wr_rstn         ,
    wr_en_i         ,
    wr_full_o       ,
    wr_ptr_o        ,
    rd_ptr_sync_i   
);

    parameter                           FIFO_ADDR_WD    =   3   ;

    input                               wr_clk          ;
    input                               wr_rstn         ;
    input                               wr_en_i         ;
    output                              wr_full_o       ;
    output [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;   // write pointer, use gray-code
    input  [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_i   ;   // read pointer (sync), use gray-code

    reg                                 wr_full_o       ;
    reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
    reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_next     ;

    always@(*) begin
        case(wr_ptr_o)
            3'b000:     wr_ptr_next = 3'b001;
            3'b001:     wr_ptr_next = 3'b011;
            3'b011:     wr_ptr_next = 3'b010;
            3'b010:     wr_ptr_next = 3'b110;
            3'b110:     wr_ptr_next = 3'b111;
            3'b111:     wr_ptr_next = 3'b101;
            3'b101:     wr_ptr_next = 3'b100;
            3'b100:     wr_ptr_next = 3'b000;
        endcase
    end 
/*
    always@(posedge wr_clk or negedge wr_rstn) begin
        if(~wr_rstn) begin
            wr_full_o <= 1'b0;
        end
        else begin
            if      (wr_ptr_next == rd_ptr_sync_i) begin
                wr_full_o <= 1'b1;
            end
            else if (wr_ptr_next != rd_ptr_sync_i) begin
                wr_full_o <= 1'b0;
            end
        end
    end
*/
    always@(*) begin
        if      (wr_ptr_next == rd_ptr_sync_i) begin
            wr_full_o <= 1'b1;
        end
        else if (wr_ptr_next != rd_ptr_sync_i) begin
            wr_full_o <= 1'b0;
        end
    end

    always@(posedge wr_clk or negedge wr_rstn) begin
        if(~wr_rstn) begin
            wr_ptr_o <= 3'b000;
        end
        else begin
            if((wr_en_i == 1'b1) && (wr_full_o == 1'b0)) begin
                wr_ptr_o <= wr_ptr_next;
            end
        end
    end

endmodule