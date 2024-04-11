参考《计算机组成与设计》(COD, Computer Orgnization and Design)，
该实现将 CPU 的数据通路划分成 5 个部分(模块)，并将每个部分用
对应的指令执行阶段来命名，分别为：

1. IF: Instruction Fetch，取指令
2. ID: Instruction Decode & Register Read, 指令译码和读寄存器
3. EX: Excution or Address Calculation，执行或计算地址
4. MEM: Data Memory Access，数据存储器访问
5. WB: Write Back，写回寄存器

