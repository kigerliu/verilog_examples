// synchronizer from fast clk domain to slow clk domain
// shake-hands implementation method 1: hold the signal
// reference: SoC Design (E.4), Chapter 7.3.2.2, Page 116

// fast clk domain part
module sync_f2s_f(
    clk_f       ,
    rstn        ,
    rd_en_i     ,
    rd_en_ack_i ,
    rd_en_o     
);

//*** PARAMETER *************************************************************************
    // none

//*** INPUT/OUTPUT **********************************************************************

    input       clk_f;
    input       rstn;
    input       rd_en_i; // suppose the input rd_en is synchronized with the clock
    input       rd_en_ack_i;
    output      rd_en_o;

//*** WIRE/REG **************************************************************************

    reg         rd_en_ack_1_r;
    reg         rd_en_ack_2_r;
    reg         rd_en_ack_3_r;
    reg         rd_en_ack_sync;
    reg         rd_en_o;

//*** MAIN BODY *************************************************************************

    always @(posedge clk_f or negedge rstn) begin
        if(~rstn) begin
            rd_en_ack_1_r   <= 1'b0;
            rd_en_ack_2_r   <= 1'b0;
            rd_en_ack_3_r   <= 1'b0;
            rd_en_ack_sync  <= 1'b0;
            rd_en_o         <= 1'b0;
        end
        else begin
            {rd_en_ack_3_r, rd_en_ack_2_r, rd_en_ack_1_r} <= {rd_en_ack_2_r, rd_en_ack_1_r, rd_en_ack_i};
        end
    end

    always @(*) begin
        if({rd_en_ack_3_r, rd_en_ack_2_r, rd_en_ack_1_r} == 3'b011) begin
            rd_en_ack_sync = 1'b1;
        end
        else begin
            rd_en_ack_sync = 1'b0;
        end
    end

    // shake-hands logic
    // Q: Can this be replaced by combination logic?
    // A: NO! Or latch will be inferred in the circuit!
    always @(posedge clk_f) begin
        if((rd_en_o == 1'b0) && (rd_en_i == 1'b1)) begin
            rd_en_o <= 1'b1;
        end
        else begin
            if((rd_en_o == 1'b1) && (rd_en_ack_sync == 1'b1)) begin
                rd_en_o <= 1'b0;
            end
        end
    end

endmodule