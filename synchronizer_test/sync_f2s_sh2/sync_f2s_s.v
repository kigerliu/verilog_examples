// synchronizer from fast clk domain to slow clk domain
// shake-hands implementation method 2: stop the fast clk
// reference: SoC Design (E.4), Chapter 7.3.2.2, Page 116

// slow clk domain part
module sync_f2s_s(
    clk_s   ,
    rd_en_i ,
    rd_en_o ,
    rstn    
);

//*** PARAMETER *************************************************************************
    // none

//*** INPUT/OUTPUT **********************************************************************

    input       clk_s;
    input       rd_en_i;
    output      rd_en_o;
    input       rstn;

//*** WIRE/REG **************************************************************************

    reg         rd_en_1_r;
    reg         rd_en_2_r;
    reg         rd_en_3_r;
    reg         rd_en_o;

//*** MAIN BODY *************************************************************************

    always @(posedge clk_s or negedge rstn) begin
        if(~rstn) begin
            rd_en_1_r <= 1'b0;
            rd_en_2_r <= 1'b0;
            rd_en_3_r <= 1'b0;
            rd_en_o   <= 1'b0;
        end
        else begin
            {rd_en_3_r, rd_en_2_r, rd_en_1_r} <= {rd_en_2_r, rd_en_1_r, rd_en_i};
        end
    end

    always @(*) begin
        if({rd_en_3_r, rd_en_2_r, rd_en_1_r} == 3'b011) begin
            rd_en_o <= 1'b1;
        end
        else begin
            rd_en_o <= 1'b0;
        end
    end

endmodule