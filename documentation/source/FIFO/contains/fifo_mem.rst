fifo_mem
-----------------------------

模块描述
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
一组双端口存储器，根据输入的使能和写满/读空标志，实现相应地址处数据的写入/读出

参数说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: parameters of fifo_mem

   parameter                           FIFO_DEPTH      =   8   ;
   parameter                           FIFO_DAT_WD     =   4   ;
   parameter                           FIFO_ADDR_WD    =   3   ;

*  FIFO_DEPTH   : FIFO的深度，即一共可以存储多少个数据
*  FIFO_DAT_WD  : FIFO的数据位宽
*  FIFO_ADDR_WD : FIFO地址位所需的最大位宽（与深度相对应）

I/O端口及变量说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: ports & variables of fifo_mem

   input                               wr_clk      ;
   input                               wr_rstn     ;
   input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
   input                               wr_en_i     ;
   input   [FIFO_ADDR_WD   -1:0]       wr_addr_i   ;
   input                               wr_full_i   ;
   input                               rd_clk      ;
   input                               rd_rstn     ;
   output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
   input                               rd_en_i     ;
   input   [FIFO_ADDR_WD   -1:0]       rd_addr_i   ;
   input                               rd_empty_i  ;

   reg     [FIFO_DAT_WD    -1:0]       fifo_memory [FIFO_DEPTH -1:0]   ;
   reg     [FIFO_DAT_WD    -1:0]       rd_dat_o    ;

==========   =========   ============================     ==========================================================================================================
端口名称      端口类型    描述                             具体说明
==========   =========   ============================     ==========================================================================================================
wr_clk        输入        写时钟                            \-
wr_rstn       输入        写时钟域的异步复位信号            \-
wr_dat_i      输入        待写入数据（与写时钟同步）        \-
wr_en_i       输入        写使能信号（与写时钟同步）        其有效且未写满时，向FIFO中写入待写入数据并令写地址+1
wr_addr_i     输入        写地址（写指针）                  指向FIFO中下一个待写入数据的位置，编码方式为格雷码
wr_full_i     输入        写满标志信号                      由写指针和同步到写时钟域的读指针决定，若写指针追上读指针，则表示写满，在有数据被读出前不允许继续写入新数据
rd_clk        输入        读时钟                            \-
rd_rstn       输入        读时钟域的异步复位信号            \-
rd_dat_o      输出        数据读出端（与读时钟同步）        \-
rd_en_i       输入        读使能信号（与读时钟同步）        其有效且未读空时，从FIFO中读出数据到rd_dat_o并令读地址+1
rd_addr_i     输入        读地址（读指针）                  指向FIFO中下一个待读取的数据，编码方式为格雷码
rd_empty_i    输入        读空标志信号                      由读指针和同步到读时钟域的写指针决定，若读指针追上写指针，则表示读空，在有新数据被写入前不允许继续读取数据
==========   =========   ============================     ==========================================================================================================

============ ============ =========================== =======================================
变量名称      变量类型     描述                        具体说明
============ ============ =========================== =======================================
fifo_memory   memory       FIFO存储器                  存储数据并根据地址实现数据的写入和读出
rd_dat_o      reg          数据读出端（与读时钟同步）   \-
============ ============ =========================== =======================================

工作时序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  上电，读时钟域对fifo_memory复位，写时钟域对rd_dat_o复位
*  写时钟域

   *  当写使能信号wr_en_i有效且写满标志位wr_full_i无效（未写满）时，将wr_dat_i写入FIFO中写指针wr_addr_i指向的位置（fifo_memory[wr_addr_i]）
   *  由外部的写控制逻辑控制写地址和写满标志位的变化

*  读时钟域

   *  当读使能信号rd_en_i有效且读空标志位rd_empty_i无效（未读空）时，将FIFO中读指针rd_addr_w指向处的数据（fifo_memory[rd_addr_i]）读出到rd_dat_o
   *  由外部的读控制逻辑控制读地址和读空标志位的变化

RTL代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: fifo_mem.v
   :linenos:

   module fifo_mem(
      wr_clk      ,
      wr_rstn     ,
      wr_dat_i    ,
      wr_en_i     ,
      wr_addr_i   ,
      wr_full_i   ,
      rd_clk      ,
      rd_rstn     ,
      rd_dat_o    ,
      rd_en_i     ,
      rd_addr_i   ,
      rd_empty_i  
   );

      parameter                           FIFO_DEPTH      =   8   ;
      parameter                           FIFO_DAT_WD     =   4   ;
      parameter                           FIFO_ADDR_WD    =   3   ;

      input                               wr_clk      ;
      input                               wr_rstn     ;
      input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
      input                               wr_en_i     ;
      input   [FIFO_ADDR_WD   -1:0]       wr_addr_i   ;
      input                               wr_full_i   ;
      input                               rd_clk      ;
      input                               rd_rstn     ;
      output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
      input                               rd_en_i     ;
      input   [FIFO_ADDR_WD   -1:0]       rd_addr_i   ;
      input                               rd_empty_i  ;

      reg     [FIFO_DAT_WD    -1:0]       fifo_memory [FIFO_DEPTH -1:0]   ;
      reg     [FIFO_DAT_WD    -1:0]       rd_dat_o    ;

      integer                             i;

      always@(posedge wr_clk or negedge wr_rstn) begin
         if(~wr_rstn) begin
               for(i = 0;i < FIFO_ADDR_WD;i = i + 1) begin
                  fifo_memory[i] <= 0;
               end
         end
         else begin
               if((wr_en_i == 1'b1) && (wr_full_i == 1'b0)) begin
                  fifo_memory[wr_addr_i] <= wr_dat_i;
               end
         end
      end

      always @(posedge rd_clk or negedge rd_rstn) begin
         if(~rd_rstn) begin
               rd_dat_o <= 0;
         end
         else begin
               if((rd_en_i == 1'b1) && (rd_empty_i == 1'b0))  begin
                  rd_dat_o <= fifo_memory[rd_addr_i];
               end
         end
      end

   endmodule

链接到
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

父模块
*****************************
*  :doc:`fifo` 