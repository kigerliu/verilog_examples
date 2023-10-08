fifo_ctrl
-----------------------------

模块描述
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
读/写地址控制逻辑，用于产生读/写指针和读空/写满信号，分别实例化了一组读地址控制逻辑和一组写地址控制逻辑，并进行了地址的跨时钟域同步

参数说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: parameters of fifo_ctrl

   parameter                           FIFO_ADDR_WD    =   3   ;

*  FIFO_ADDR_WD : FIFO地址位所需的最大位宽（与深度相对应）

I/O端口及变量说明
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: ports & variables of fifo_ctrl

   input                               rd_clk          ;
   input                               rd_rstn         ;
   input                               rd_en_i         ;
   output                              rd_empty_o      ;
   output [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
   input                               wr_clk          ;
   input                               wr_rstn         ;
   input                               wr_en_i         ;
   output                              wr_full_o       ;
   output [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
    
   wire   [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_r   ;
   wire   [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_r   ;

   reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_1_r      ;
   reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_2_r      ;
   reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_1_r      ;
   reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_2_r      ;

==========   =========   ============================     ==========================================================================================================
端口名称      端口类型    描述                             具体说明
==========   =========   ============================     ==========================================================================================================
rd_clk        输入        读时钟                            \-
rd_rstn       输入        读时钟域的异步复位信号            \-
rd_en_i       输入        读使能信号（与读时钟同步）        其有效且未读空时，从FIFO中读出数据到rd_dat_o并令读地址+1
rd_empty_o    输出        读空标志信号                      由读指针和同步到读时钟域的写指针决定，若读指针追上写指针，则表示读空，在有新数据被写入前不允许继续读取数据
rd_ptr_o      输出        读指针                            指向FIFO中下一个待读取的数据，编码方式为格雷码
wr_clk        输入        写时钟                            \-
wr_rstn       输入        写时钟域的异步复位信号            \-
wr_en_i       输入        写使能信号（与写时钟同步）        其有效且未写满时，向FIFO中写入待写入数据并令写地址+1
wr_full_o     输出        写满标志信号                      由写指针和同步到写时钟域的读指针决定，若写指针追上读指针，则表示写满，在有数据被读出前不允许继续写入新数据
wr_ptr_o      输出        写指针                            指向FIFO中下一个待写入数据的位置，编码方式为格雷码
==========   =========   ============================     ==========================================================================================================

============== ============ ================================ ================
变量名称        变量类型     描述                             具体说明
============== ============ ================================ ================
rd_ptr_sync_r   wire        同步到写时钟域的读指针            \-
wr_ptr_sync_r   wire        同步到读时钟域的写指针            \-
rd_ptr_1_r      reg         在写时钟域进行一拍寄存后的读指针  \-
rd_ptr_2_r      reg         在写时钟域进行两拍寄存后的读指针  同rd_ptr_sync_r
wr_ptr_1_r      reg         在读时钟域进行一拍寄存后的写指针  \-
wr_ptr_2_r      reg         在读时钟域进行两拍寄存后的写指针  同wr_ptr_sync_r
============== ============ ================================ ================

工作时序
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  上电，读时钟域和写时钟域分别完成读/写指针复位操作
*  写时钟域

   *  当写使能信号wr_en_i有效且写满标志位wr_full_o无效（未写满）时，将写指针+1（指向下一个待写入位置）
   *  在完成一次写入（写指针发生变化）或者同步过来的读指针rd_ptr_sync_r发生变化后，比较当前写指针+1后的地址与同步过来的读指针的地址

      *  若二者相等，意味着写指针已经再次追上读指针（滞后的），此时不可继续写入，写满标志位置1（写满有效）
      *  若二者不相等，意味着写指针未再次追上读指针（滞后的），允许写入，写满标志位置0（写满无效）

*  读时钟域

   *  当读使能信号rd_en_i有效且读空标志位rd_empty_o无效（未读空）时，将读指针+1（指向下一个待读出位置）
   *  在完成一次读出（读指针发生变化）或者同步过来的写指针wr_ptr_sync_r发生变化后，比较当前读指针的地址与同步过来的写指针的地址

      *  若二者相等，意味着读指针已经追上写指针（滞后的），此时不可继续读FIFO数据，读空标志位置1（读空有效）
      *  若二者不相等，意味着读指针未追上写指针（滞后的），允许读出FIFO数据，读空标志位置0（读空无效）

*  在读/写指针变化的同时（之前），FIFO存储器会根据指针完成相应数据的读出/写入

RTL代码
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
.. code-block:: v
   :caption: fifo_ctrl.v
   :linenos:

   module fifo_ctrl(
      rd_clk          ,
      rd_rstn         ,
      rd_en_i         ,
      rd_empty_o      ,
      rd_ptr_o        ,
      wr_clk          ,
      wr_rstn         ,
      wr_en_i         ,
      wr_full_o       ,
      wr_ptr_o        
   );

      parameter                           FIFO_ADDR_WD    =   3   ;

      input                               rd_clk          ;
      input                               rd_rstn         ;
      input                               rd_en_i         ;
      output                              rd_empty_o      ;
      output [FIFO_ADDR_WD    -1:0]       rd_ptr_o        ;
      input                               wr_clk          ;
      input                               wr_rstn         ;
      input                               wr_en_i         ;
      output                              wr_full_o       ;
      output [FIFO_ADDR_WD    -1:0]       wr_ptr_o        ;
      
      wire   [FIFO_ADDR_WD    -1:0]       rd_ptr_sync_r   ;
      wire   [FIFO_ADDR_WD    -1:0]       wr_ptr_sync_r   ;

      reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_1_r      ;
      reg    [FIFO_ADDR_WD    -1:0]       rd_ptr_2_r      ;
      reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_1_r      ;
      reg    [FIFO_ADDR_WD    -1:0]       wr_ptr_2_r      ;
      
      assign  rd_ptr_sync_r = rd_ptr_2_r;
      assign  wr_ptr_sync_r = wr_ptr_2_r;

      always@(posedge rd_clk or negedge rd_rstn) begin
         if(~rd_rstn) begin
               wr_ptr_1_r <= 3'b000;
               wr_ptr_2_r <= 3'b000;
         end
         else begin
               {wr_ptr_2_r,wr_ptr_1_r} <= {wr_ptr_1_r,wr_ptr_o};
         end
      end

      always@(posedge wr_clk or negedge wr_rstn) begin
         if(~wr_rstn) begin
               rd_ptr_1_r <= 3'b000;
               rd_ptr_2_r <= 3'b000;
         end
         else begin
               {rd_ptr_2_r,rd_ptr_1_r} <= {rd_ptr_1_r,rd_ptr_o};
         end
      end

      fifo_rd_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_rd_ctrl(
         .rd_clk         (   rd_clk          ),
         .rd_rstn        (   rd_rstn         ),
         .rd_en_i        (   rd_en_i         ),
         .rd_empty_o     (   rd_empty_o      ),
         .rd_ptr_o       (   rd_ptr_o        ),
         .wr_ptr_sync_i  (   wr_ptr_sync_r   )
      );

      fifo_wr_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_wr_ctrl(
         .wr_clk         (   wr_clk          ),
         .wr_rstn        (   wr_rstn         ),
         .wr_en_i        (   wr_en_i         ),
         .wr_full_o      (   wr_full_o       ),
         .wr_ptr_o       (   wr_ptr_o        ),
         .rd_ptr_sync_i  (   rd_ptr_sync_r   )
      );

   endmodule

链接到
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

子模块
*****************************
*  :doc:`fifo_rd_ctrl` 

*  :doc:`fifo_wr_ctrl` 

父模块
*****************************
*  :doc:`fifo` 