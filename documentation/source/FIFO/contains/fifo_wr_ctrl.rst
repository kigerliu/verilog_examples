fifo_wr_ctrl
-----------------------------

模块描述
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
写地址控制逻辑，用于产生写指针和写满信号

参数说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: parameters of fifo_wr_ctrl

   parameter                           FIFO_ADDR_WD    =   3   ;

*  FIFO_ADDR_WD : FIFO地址位所需的最大位宽（与深度相对应）

I/O端口及变量说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: I/O ports & variables of fifo_wr_ctrl

   input                               wr_clk          ;
   input                               wr_rstn         ;
   input                               wr_en_i         ;
   output                              wr_full_o       ;
   output [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;   // write pointer, use gray-code
   input  [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_i   ;   // read pointer (sync), use gray-code

   reg                                 wr_full_o       ;
   reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
   reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_next     ;

==============   =========   ============================     ==========================================================================================================
端口名称          端口类型    描述                             具体说明
==============   =========   ============================     ==========================================================================================================
wr_clk            输入        写时钟                            \-
wr_rstn           输入        写时钟域的异步复位信号            \-
wr_en_i           输入        写使能信号（与写时钟同步）        其有效且未写满时，向FIFO中写入待写入数据并令写地址+1
wr_full_o         输出        写满标志信号                      由写指针和同步到写时钟域的读指针决定，若写指针追上读指针，则表示写满，在有数据被读出前不允许继续写入新数据
wr_ptr_o          输出        写指针                            指向FIFO中下一个待写入数据的位置，编码方式为格雷码
rd_ptr_sync_i     输入        同步到写时钟域的读指针            \-
==============   =========   ============================     ==========================================================================================================

============== ========== ============= ================
变量名称        变量类型   描述          具体说明
============== ========== ============= ================
wr_full_o       reg       写满标志信号   \-
wr_ptr_o        reg       写指针         \-
wr_ptr_next     reg       下一个写指针   \-
============== ========== ============= ================

工作时序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  上电，完成写指针复位操作
*  当写使能信号wr_en_i有效且写满标志位wr_full_o无效（未写满）时，将写指针+1（指向下一个待写入位置）
*  在完成一次写入（写指针发生变化）或者同步过来的读指针rd_ptr_sync_r发生变化后，比较当前写指针+1后的地址与同步过来的读指针的地址

   *  若二者相等，意味着写指针已经再次追上读指针（滞后的），此时不可继续写入，写满标志位置1（写满有效）
   *  若二者不相等，意味着写指针未再次追上读指针（滞后的），允许写入，写满标志位置0（写满无效）

RTL代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: fifo_wr_ctrl.v
   :linenos:

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

链接到
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

父模块
*****************************
*  :doc:`fifo_ctrl`

其他上层模块
*****************************
*  :doc:`fifo`
