Testbench
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

仿真过程
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#. 读/写时钟域复位并释放
#. 设计两串读/写使能序列，作为DUT的rd_en_i和wr_en_i输入，其值在相应时钟的上升沿发生变化
#. 设计待写入数据序列从4'b0000开始递增，作为DUT的wr_dat_i输入，其值在写时钟的上升沿发生变化
#. 完成复位释放后，同步给入使能信号和待写入数据，并观察相应输出信号的变化

备注
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  为了分别验证慢时钟域（写）到快时钟域（读）和快时钟域（写）到慢时钟域（读），设置了两组激励，可根据实际需要选用
*  已完成慢时钟域到快时钟域以及快时钟域到慢时钟域模式下的仿真验证，FIFO工作正常

仿真代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
    :caption: tb_fifo.v
    :linenos:

    // testbench of fifo (top module)
    `timescale 1ns/1ps
    // `define HALF_CLK_PERIOD_RD 5
    `define HALF_CLK_PERIOD_RD 18
    // `define HALF_CLK_PERIOD_WR 18
    `define HALF_CLK_PERIOD_WR 5

    module tb_fifo;

        parameter                           FIFO_DEPTH      =   8   ;
        parameter                           FIFO_DAT_WD     =   4   ;
        parameter                           FIFO_ADDR_WD    =   3   ;


        reg                                 wr_clk      ;
        reg                                 wr_rstn     ;
        reg     [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
        wire                                wr_en_i     ;
        reg                                 rd_clk      ;
        reg                                 rd_rstn     ;
        wire    [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
        wire                                rd_en_i     ;

        fifo #(.FIFO_DEPTH(FIFO_DEPTH), .FIFO_DAT_WD(FIFO_DAT_WD), .FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo(
            .wr_clk     (   wr_clk      ),
            .wr_rstn    (   wr_rstn     ),
            .wr_dat_i   (   wr_dat_i    ),
            .wr_en_i    (   wr_en_i     ),
            .rd_clk     (   rd_clk      ),
            .rd_rstn    (   rd_rstn     ),
            .rd_dat_o   (   rd_dat_o    ),
            .rd_en_i    (   rd_en_i     ) 
        );

        // reg     [64             -1:0]       rd_en_i_array   = 64'b0100000000000000000000000000000001010101010101010101010101010101;
        reg     [64             -1:0]       rd_en_i_array   = 64'b0101010101010101010101010101010101010101010101010101010101010101;
        // reg     [64             -1:0]       wr_en_i_array   = 64'b0000001010101010101010101010101010101010101010101010101010101010;
        reg     [64             -1:0]       wr_en_i_array   = 64'b0000101010101010101010101010101000000000000000000000000000000000;

        assign  rd_en_i         = rd_en_i_array     [64 -1] ;
        assign  wr_en_i         = wr_en_i_array     [64 -1] ;

        initial begin
            rd_clk = 1'b0;
            wr_clk = 1'b0;
        end

        always #(`HALF_CLK_PERIOD_RD) rd_clk = ~rd_clk;
        always #(`HALF_CLK_PERIOD_WR) wr_clk = ~wr_clk;

        initial begin
            rd_rstn = 1'b0;
            wr_rstn = 1'b0;
            #21;
            rd_rstn = 1'b1;
            wr_rstn = 1'b1;
        end

        always@(posedge rd_clk) begin
            if(rd_rstn) begin
                rd_en_i_array   = rd_en_i_array     << 1;
            end
        end

        always@(posedge wr_clk) begin
            if(wr_rstn) begin
                wr_en_i_array   = wr_en_i_array     << 1;
            end
        end

        always @(posedge wr_clk or negedge wr_rstn) begin
            if(~wr_rstn) begin
                wr_dat_i = 0;
            end
            else begin
                wr_dat_i = wr_dat_i + 1'b1;
            end
        end

    endmodule