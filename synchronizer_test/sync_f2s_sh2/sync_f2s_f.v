// synchronizer from fast clk domain to slow clk domain
// shake-hands implementation method 2: stop the fast clk
// reference: SoC Design (E.4), Chapter 7.3.2.2, Page 116

// fast clk domain part
module sync_f2s_f(
    clk_f       ,
    rstn        ,
    rd_en_ack_i ,
    rd_en_o     
);

//*** PARAMETER *************************************************************************
    // none

//*** INPUT/OUTPUT **********************************************************************

    input       clk_f               ;
    input       rstn                ;
    input       rd_en_ack_i         ;
    output      rd_en_o             ;

//*** WIRE/REG **************************************************************************

    wire        rd_en_sh_w          ;
    wire        rd_en_ack_sync_w    ;

//*** MAIN BODY *************************************************************************

    sync_f2s_f_ckgt sync_f2s_f_ckgt(
        .clk                (clk_f              ),
        .rstn               (rstn               ),
        .rd_en_ack_sync_i   (rd_en_ack_sync_w   ),
        .rd_en_o            (rd_en_sh_w         )
    );

    sync_f2s_f_sh sync_f2s_f_sh(
        .clk_f              (clk_f              ),
        .rstn               (rstn               ),
        .rd_en_i            (rd_en_sh_w         ),
        .rd_en_ack_i        (rd_en_ack_i        ),
        .rd_en_ack_sync_o   (rd_en_ack_sync_w   ),
        .rd_en_o            (rd_en_o            )
    );

endmodule