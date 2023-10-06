// First-In-First-Out, Depth: 8bits
// reference: SoC Design (E.4), Chapter 7.3.3, Page 119

// read control part of FIFO
module fifo_rd_ctrl(
    rd_clk          ,
    rd_rstn         ,
    rd_en_i         ,
    rd_empty_o      ,
    rd_ptr_o        ,
    wr_ptr_sync_i   
);

    parameter                           FIFO_ADDR_WD    =   3   ;

    input                               rd_clk          ;
    input                               rd_rstn         ;
    input                               rd_en_i         ;
    output                              rd_empty_o      ;
    output [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;   // read pointer, use gray-code
    input  [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_i   ;   // write pointer (sync), use gray-code

    reg                                 rd_empty_o      ;
    reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
    reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_next     ;

    always@(*) begin
        case(rd_ptr_o)
            3'b000:     rd_ptr_next = 3'b001;
            3'b001:     rd_ptr_next = 3'b011;
            3'b011:     rd_ptr_next = 3'b010;
            3'b010:     rd_ptr_next = 3'b110;
            3'b110:     rd_ptr_next = 3'b111;
            3'b111:     rd_ptr_next = 3'b101;
            3'b101:     rd_ptr_next = 3'b100;
            3'b100:     rd_ptr_next = 3'b000;
        endcase
    end 
/*
    always@(posedge rd_clk or negedge rd_rstn) begin
        if(~rd_rstn) begin
            rd_empty_o <= 1'b0;
        end
        else begin
            if      (rd_ptr_next == wr_ptr_sync_i) begin
                rd_empty_o <= 1'b1;
            end
            else if (rd_ptr_next != wr_ptr_sync_i) begin
                rd_empty_o <= 1'b0;
            end
        end
    end
*/
    always@(*) begin
        if      (rd_ptr_o == wr_ptr_sync_i) begin
            rd_empty_o <= 1'b1;
        end
        else if (rd_ptr_o != wr_ptr_sync_i) begin
            rd_empty_o <= 1'b0;
        end
    end

    always@(posedge rd_clk or negedge rd_rstn) begin
        if(~rd_rstn) begin
            rd_ptr_o <= 3'b000;
        end
        else begin
            if((rd_en_i == 1'b1) && (rd_empty_o == 1'b0)) begin
                rd_ptr_o <= rd_ptr_next;
            end
        end
    end

endmodule