fifo_rd_ctrl
-----------------------------

模块描述
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
读地址控制逻辑，用于产生读指针和读空信号

参数说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: parameters of fifo_rd_ctrl

   parameter                           FIFO_ADDR_WD    =   3   ;

*  FIFO_ADDR_WD : FIFO地址位所需的最大位宽（与深度相对应）

I/O端口及变量说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: I/O ports & variables of fifo_rd_ctrl

   input                               rd_clk          ;
   input                               rd_rstn         ;
   input                               rd_en_i         ;
   output                              rd_empty_o      ;
   output [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;   // read pointer, use gray-code
   input  [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_i   ;   // write pointer (sync), use gray-code

   reg                                 rd_empty_o      ;
   reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
   reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_next     ;

==============   =========   ============================     ==========================================================================================================
端口名称          端口类型    描述                             具体说明
==============   =========   ============================     ==========================================================================================================
rd_clk            输入        读时钟                            \-
rd_rstn           输入        读时钟域的异步复位信号            \-
rd_en_i           输入        读使能信号（与读时钟同步）        其有效且未读空时，从FIFO中读出数据到rd_dat_o并令读地址+1
rd_empty_o        输出        读空标志信号                      由读指针和同步到读时钟域的写指针决定，若读指针追上写指针，则表示读空，在有新数据被写入前不允许继续读取数据
rd_ptr_o          输出        读指针                            指向FIFO中下一个待读取的数据，编码方式为格雷码
wr_ptr_sync_i     输入        同步到读时钟域的写指针            \-
==============   =========   ============================     ==========================================================================================================

============== ========== ============= ================
变量名称        变量类型   描述          具体说明
============== ========== ============= ================
rd_empty_o      reg       读空标志信号   \-
rd_ptr_o        reg       读指针         \-
rd_ptr_next     reg       下一个读指针   \-
============== ========== ============= ================

工作时序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  上电，完成读指针复位操作
*  当读使能信号rd_en_i有效且读空标志位rd_empty_o无效（未读空）时，将读指针+1（指向下一个待读出位置）
*  在完成一次读出（读指针发生变化）或者同步过来的写指针wr_ptr_sync_r发生变化后，比较当前读指针的地址与同步过来的写指针的地址

   *  若二者相等，意味着读指针已经追上写指针（滞后的），此时不可继续读FIFO数据，读空标志位置1（读空有效）
   *  若二者不相等，意味着读指针未追上写指针（滞后的），允许读出FIFO数据，读空标志位置0（读空无效）

RTL代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: fifo_rd_ctrl.v
   :linenos:

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

链接到
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

父模块
*****************************
*  :doc:`fifo_ctrl`

其他上层模块
*****************************
*  :doc:`fifo`
