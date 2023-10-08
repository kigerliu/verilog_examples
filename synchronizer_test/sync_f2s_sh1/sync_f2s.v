// synchronizer from fast clk domain to slow clk domain
// shake-hands implementation method 1: hold the signal
// reference: SoC Design (E.4), Chapter 7.3.2.2, Page 116

// top module
module sync_f2s(
    clk_f   ,
    rstn_f  ,
    clk_s   ,
    rstn_s  ,
    rd_en_i ,
    rd_en_o 
);

//*** PARAMETER *************************************************************************
    // none

//*** INPUT/OUTPUT **********************************************************************

    input       clk_f       ;
    input       rstn_f      ;
    input       clk_s       ;
    input       rstn_s      ;
    input       rd_en_i     ;
    output      rd_en_o     ;

//*** WIRE/REG **************************************************************************

    wire        rd_en_f     ;

//*** MAIN BODY *************************************************************************

    sync_f2s_f sync_f2s_f(
        .clk_f          (clk_f      ),
        .rstn           (rstn_f     ),
        .rd_en_i        (rd_en_i    ),
        .rd_en_ack_i    (rd_en_o    ),
        .rd_en_o        (rd_en_f    )
    );

    sync_f2s_s sync_f2s_s(
        .clk_s          (clk_s      ),
        .rd_en_i        (rd_en_f    ),
        .rd_en_o        (rd_en_o    ),
        .rstn           (rstn_s     )
    );

endmodule