// synchronizer from fast clk domain to slow clk domain
// shake-hands implementation method 2: stop the fast clk
// reference: SoC Design (E.4), Chapter 7.3.2.2, Page 116

// fast clk domain part - clock gating (and data synchronization) part
module sync_f2s_f_ckgt(
    clk                 ,
    rstn                ,
    rd_en_ack_sync_i    ,
    rd_en_o             
);

//*** PARAMETER *************************************************************************
    // none
    localparam              DAT_WD = 32;

//*** INPUT/OUTPUT **********************************************************************

    input                   clk                 ;
    input                   rstn                ;
    input                   rd_en_ack_sync_i    ;
    output                  rd_en_o             ;

//*** WIRE/REG **************************************************************************

    wire                    clk_gt              ;
    reg                     clk_gt_1            ;
    reg                     gt_ctrl             ;   // 1 - original clock, 0 - stop the clock
    reg     [DAT_WD -1:0]   dat_i = 32'b00000101000000010000010100010101 ;

//*** MAIN BODY *************************************************************************

    assign                  rd_en_o = dat_i[DAT_WD - 1];

    always@(*) begin
        if      (~rstn) begin
            gt_ctrl = 1'b1;
        end
        else if (rd_en_ack_sync_i == 1) begin   // continue the clock
            gt_ctrl = 1'b1;
        end
    end

    always@(*) begin
        if      (rd_en_o == 1'b1) begin         // stop the clock
            gt_ctrl = 1'b0;
        end
    end

    assign clk_gt = gt_ctrl & clk;

    always@(posedge clk or negedge clk) begin
        clk_gt_1 <= clk_gt;
    end

//    always@(*) begin
//        if      ((gt_ctrl == 1'b1) && (clk == 1'b1)) begin
//            clk_gt = clk;
//        end
//        else if ((gt_ctrl == 1'b0) && (clk == 1'b0)) begin
//            clk_gt = 1'b0;
//        end
//    end

    always @(posedge clk_gt_1) begin
        dat_i <= dat_i << 1;
    end

endmodule