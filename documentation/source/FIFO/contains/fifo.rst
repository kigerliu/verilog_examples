fifo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

模块描述
-----------------------------
异步FIFO的实现主体，分别实例化了一组双端口存储器和一组读/写地址控制逻辑

参数说明
-----------------------------
.. code-block:: v
   :caption: parameters of fifo

   parameter                           FIFO_DEPTH      =   8   ;
   parameter                           FIFO_DAT_WD     =   4   ;
   parameter                           FIFO_ADDR_WD    =   3   ;

*  FIFO_DEPTH   : FIFO的深度，即一共可以存储多少个数据
*  FIFO_DAT_WD  : FIFO的数据位宽
*  FIFO_ADDR_WD : FIFO地址位所需的最大位宽（与深度相对应）

I/O端口及变量说明
-----------------------------
.. code-block:: v
   :caption: ports & variables of fifo

   input                               wr_clk      ;
   input                               wr_rstn     ;
   input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
   input                               wr_en_i     ;
   input                               rd_clk      ;
   input                               rd_rstn     ;
   output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
   input                               rd_en_i     ;

   wire                                wr_full_w   ;
   wire                                rd_empty_w  ;
   wire   [FIFO_ADDR_WD    -1:0]       rd_addr_w   ;
   wire   [FIFO_ADDR_WD    -1:0]       wr_addr_w   ;

==========   =========   ============================     =======================================================
端口名称      端口类型    描述                             具体说明
==========   =========   ============================     =======================================================
wr_clk        输入        写时钟                            \-
wr_rstn       输入        写时钟域的异步复位信号            \-
wr_dat_i      输入        待写入数据（与写时钟同步）        \-
wr_en_i       输入        写使能信号（与写时钟同步）        其有效且未写满时，向FIFO中写入待写入数据并令写地址+1
rd_clk        输入        读时钟                            \-
rd_rstn       输入        读时钟域的异步复位信号            \-
rd_dat_o      输出        数据读出端（与读时钟同步）        \-
rd_en_i       输入        读使能信号（与读时钟同步）        其有效且未读空时，从FIFO中读出数据到rd_dat_o并令读地址+1
==========   =========   ============================     =======================================================

============ ============ ================= =========================================================================================================
变量名称      变量类型     描述              具体说明
============ ============ ================= =========================================================================================================
wr_full_w     wire         写满标志信号      由写指针和同步到写时钟域的读指针决定，若写指针追上读指针，则表示写满，在有数据被读出前不允许继续写入新数据
rd_empty_w    wire         读空标志信号      由读指针和同步到读时钟域的写指针决定，若读指针追上写指针，则表示读空，在有新数据被写入前不允许继续读取数据
rd_addr_w     wire         读地址（读指针）  指向FIFO中下一个待读取的数据，编码方式为格雷码
wr_addr_w     wire         写地址（写指针）  指向FIFO中下一个待写入数据的位置，编码方式为格雷码
============ ============ ================= =========================================================================================================

工作时序
-----------------------------
*  上电，读时钟域和写时钟域分别完成复位操作
*  写时钟域

   *  当写使能信号有效且写满标志位无效（未写满）时，将wr_dat_i写入FIFO中写指针wr_addr_w指向的位置，并将写指针+1（指向下一个待写入位置）
   *  在完成一次写入（写指针发生变化）或者同步过来的读指针发生变化后，比较当前写指针+1后的地址与同步过来的读指针的地址

      *  若二者相等，意味着写指针已经再次追上读指针（滞后的），此时不可继续写入，写满标志位置1（写满有效）
      *  若二者不相等，意味着写指针未再次追上读指针（滞后的），允许写入，写满标志位置0（写满无效）

*  读时钟域

   *  当读使能信号有效且读空标志位无效（未读空）时，将FIFO中读指针rd_addr_w指向处的数据读出到rd_dat_o，并将读指针+1（指向下一个待读出位置）
   *  在完成一次读出（读指针发生变化）或者同步过来的写指针发生变化后，比较当前读指针的地址与同步过来的写指针的地址

      *  若二者相等，意味着读指针已经追上写指针（滞后的），此时不可继续读FIFO数据，读空标志位置1（读空有效）
      *  若二者不相等，意味着读指针未追上写指针（滞后的），允许读出FIFO数据，读空标志位置0（读空无效）

备注
-----------------------------
*  当写满/读空有效时，即使写/读使能有效，也不能执行写/读以及指针+1的操作
*  从时序上来看是先写入/读取后再执行指针+1，但二者是在同一个时钟边沿完成的，尽管如此，考虑到实际路径的延时，写入/读取操作肯定会早于指针+1，因此不必考虑写入/读取位置错误的可能性
*  所谓的同步过来的指针是“滞后的”，是指当前反馈到写时钟域的读指针（反馈到读时钟域的写指针类似）是滞后于当前的读指针的

   *  原因：考虑到两个异步信号直接比较时会产生亚稳态问题，进行了两拍同步
   *  带来的影响：当“写满”信号有效时，写指针并未完全追上实际的读指针，即实际并未写满（“虚满”），这不会导致数据同步出现错误，仅仅增大了同步的延时

*  慢时钟域同步快时钟域的地址时，会出现遗漏问题，但这同样不会导致同步出现错误，因为这一情况并不会跳过“读空”或者“写满状态”（即任一指针实际上并不会越过另一指针），原理与上类似

RTL代码
-----------------------------
*注：此顶层模块中仅进行了模块例化，所涉及具体逻辑请参考各子模块*

.. code-block:: v
   :caption: fifo.v
   :linenos:

   module fifo(
       wr_clk      ,
       wr_rstn     ,
       wr_dat_i    ,
       wr_en_i     ,
       rd_clk      ,
       rd_rstn     ,
       rd_dat_o    ,
       rd_en_i      
   );
   
       parameter                           FIFO_DEPTH      =   8   ;
       parameter                           FIFO_DAT_WD     =   4   ;
       parameter                           FIFO_ADDR_WD    =   3   ;
   
   
       input                               wr_clk      ;
       input                               wr_rstn     ;
       input   [FIFO_DAT_WD    -1:0]       wr_dat_i    ;
       input                               wr_en_i     ;
       input                               rd_clk      ;
       input                               rd_rstn     ;
       output  [FIFO_DAT_WD    -1:0]       rd_dat_o    ;
       input                               rd_en_i     ;
   
   
       wire                                wr_full_w   ;
       wire                                rd_empty_w  ;
       wire   [FIFO_ADDR_WD    -1:0]       rd_addr_w   ;
       wire   [FIFO_ADDR_WD    -1:0]       wr_addr_w   ;
   
       fifo_ctrl #(.FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_ctrl(
           .rd_clk     (   rd_clk      ),
           .rd_rstn    (   rd_rstn     ),
           .rd_en_i    (   rd_en_i     ),
           .rd_empty_o (   rd_empty_w  ),
           .rd_ptr_o   (   rd_addr_w   ),
           .wr_clk     (   wr_clk      ),
           .wr_rstn    (   wr_rstn     ),
           .wr_en_i    (   wr_en_i     ),
           .wr_full_o  (   wr_full_w   ),
           .wr_ptr_o   (   wr_addr_w   )
       );
   
       fifo_mem #(.FIFO_DEPTH(FIFO_DEPTH), .FIFO_DAT_WD(FIFO_DAT_WD), .FIFO_ADDR_WD(FIFO_ADDR_WD)) fifo_mem(
           .wr_clk     (   wr_clk      ),
           .wr_rstn    (   wr_rstn     ),
           .wr_dat_i   (   wr_dat_i    ),
           .wr_en_i    (   wr_en_i     ),
           .wr_addr_i  (   wr_addr_w   ),
           .wr_full_i  (   wr_full_w   ),
           .rd_clk     (   rd_clk      ),
           .rd_rstn    (   rd_rstn     ),
           .rd_dat_o   (   rd_dat_o    ),
           .rd_en_i    (   rd_en_i     ),
           .rd_addr_i  (   rd_addr_w   ),
           .rd_empty_i (   rd_empty_w  )
       );
   
   endmodule

链接到
-----------------------------

子模块
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  :doc:`fifo_mem` 

*  :doc:`fifo_ctrl` 

其他下属模块
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
*  :doc:`fifo_rd_ctrl` 

*  :doc:`fifo_wr_ctrl` 