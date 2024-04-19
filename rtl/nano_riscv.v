// Copyright (c) 2024 Binbin Zhang (binbzha@qq.com)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


`include "macro.v"

module nano_riscv(
    input wire i_clk,
    input wire i_rst,
    output wire [31:0] o_inst,
    output wire [31:0] o_pc,
    output [31:0] debug
);
    // 32 * 32 bits regs
    reg [31:0] reg_file [31:0];
    integer i;

    // Memory, please note register is used as memory to
    // simplify the design
    reg [31:0] mem_file [1023:0];


    // Stage 1. IF, Instruction Fetch
    reg [31:0] inst;
    reg [31:0] pc;
    wire [31:0] pc_addr = {2'h0, pc[31:2]};  // pc_addr = pc / 4
    always @(posedge i_clk) begin
       if (i_rst)
           inst <= 32'b0;
       else
           inst <= mem_file[pc_addr];
    end
    assign o_inst = inst;


    // Stage 2. ID, Instruction Decode
    wire x_r       =   opcode ==   `INST_TYPE_R ||
                       opcode ==   `INST_TYPE_I_C;
    wire x_lui     =   opcode ==   `INST_TYPE_U_LUI;
    wire x_auipc   =   opcode ==   `INST_TYPE_U_AUIPC;
    wire x_jal     =   opcode ==   `INST_TYPE_UJ_JAL;
    wire x_jalr    =   opcode ==   `INST_TYPE_I_JALR;
    wire x_load    =   opcode ==   `INST_TYPE_I_L;
    wire x_store   =   opcode ==   `INST_TYPE_S;
    wire x_csr     =   opcode ==   `INST_TYPE_S;

    wire [6:0] opcode = inst[6:0];
    wire [4:0] rd = (x_r || x_lui || x_auipc || x_jal || x_jalr || x_load) ?
                    inst[11:7] : 5'b0;
    wire [2:0] funct3 = inst[14:12];
    wire [4:0] rs1 = inst[19:15];
    wire [4:0] rs2 = inst[24:20];
    wire [6:0] funct7 = inst[31:25];
    wire [31:0] imm_i = {{21{inst[31]}}, inst[30:20]};  // i type immediate

    wire [31:0] n1 = reg_file[rs1];
    wire [31:0] n2 = opcode == `INST_TYPE_I_C ? imm_i : reg_file[rs2];
    wire signed [31:0] sn1 = n1;
    wire signed [31:0] sn2 = n2;
    wire [31:0] nd;

    wire [31:0] imm_s = {{21{inst[31]}}, inst[30:25], inst[11:7]};
    wire [31:0] imm_sb = {{20{inst[31]}}, inst[7], inst[30:25],
                          inst[11:8], 1'b0}; // SB type
    wire [31:0] imm_lu20 = {inst[31:12], 12'b0}; // LUI
    wire [31:0] imm_jal = {{12{inst[31]}}, inst[19:12], inst[20],
                            inst[30:21]};


    // Stage 3. Ex, Execute
    // R & I compute instruction
    assign nd = funct3 == `INST_ADD_SUB ?
                    (funct7[5] == 1'b0 ? n1 + n2 : n1 - n2) :
                funct3 == `INST_SLL ? n1 << n2[4:0] :
                funct3 == `INST_SLT ? sn1 < sn2 :
                funct3 == `INST_SLTU ? n1 < n2 :
                funct3 == `INST_XOR ? n1 | n2 :
                funct3 == `INST_SRL_SRA ?
                    (funct7[5] == 1'b0 ? n1 >> n2[4:0]: n1 >>> n2[4:0]):
                funct3 == `INST_OR ? n1 | n2 :
                n1 & n2;
    wire x_b = opcode == `INST_TYPE_SB &&
               (funct3 == `INST_BEQ && n1 == n2 ||
                funct3 == `INST_BNE && n1 != n2 ||
                funct3 == `INST_BLT && n1 < n2 ||
                funct3 == `INST_BGE && n1 >= n2 ||
                funct3 == `INST_BLTU && sn1 < sn2 ||
                funct3 == `INST_BGEU && sn1 >= sn2);

    wire [31:0] pc_b = pc + imm_sb;
    wire [31:0] pc_aui = pc + imm_lu20;
    wire [31:0] pc_jal = pc + imm_jal;
    wire [31:0] pc_jalr = pc + imm_i;


    // Stage 4. MEM, Data Memory Access
    wire [31:0] r_addr = reg_file[rs1] + imm_i;
    wire [31:0] r_mem = {2'b0, r_addr[31:2]};
    wire [31:0] rv = mem_file[r_mem];
    wire [31:0] r_val =  // H/W are 16 bits and 32 bits aligned
        funct3 == `INST_LB ? (r_addr[1:0] == 3 ? {rv[31], 24'h0, rv[30:24]} :
                              r_addr[1:0] == 2 ? {rv[23], 24'h0, rv[22:16]} :
                              r_addr[1:0] == 1 ? {rv[15], 24'h0, rv[14:8]} :
                                                 {rv[7], 24'h0, rv[6:0]}) :
        funct3 == `INST_LH ? (r_addr[1:0] == 2 ? {rv[31], 16'h0, rv[30:16]} :
                                                 {rv[15], 16'h0, rv[14:0]}) :
        funct3 == `INST_LBU ? (r_addr[1:0] == 3 ? {24'h0, rv[31:24]} :
                               r_addr[1:0] == 2 ? {24'h0, rv[23:16]} :
                               r_addr[1:0] == 1 ? {24'h0, rv[15:8]} :
                                                  {24'h0, rv[7:0]}) :
        funct3 == `INST_LHU ? (r_addr[1:0] == 2 ? {16'h0, rv[31:16]} :
                                                  {16'h0, rv[15:0]}) :
        rv;

    wire [31:0] w_addr = reg_file[rs1] + imm_s;
    wire [31:0] w_val =  // H/W are 16 bits and 32 bits aligned
        funct3 == `INST_SB ? (w_addr[1:0] == 3 ? {n2[7:0], 24'h0} :
                              w_addr[1:0] == 2 ? {8'h0, n2[7:0], 16'h0} :
                              w_addr[1:0] == 1 ? {16'h0, n2[7:0], 8'h0} :
                                                 {24'h0, n2[7:0]}) :
        funct3 == `INST_SH ? (w_addr[1:0] == 2 ? {n2[15:0], 16'h0} :
                                                 {16'h0, n2[15:0]}) :
        n2;
    wire [3:0] w_bits =  // H/W are 16 bits and 32 bits aligned
        funct3 == `INST_SB ? (w_addr[1:0] == 3 ? 4'b1000 :
                              w_addr[1:0] == 2 ? 4'b0100 :
                              w_addr[1:0] == 1 ? 4'b0010 :
                                                 4'b0001) :
        funct3 == `INST_SH ? (w_addr[1:0] == 2 ? 4'b1100 :
                                                 4'b0011) :
        4'b1111;
    wire [31:0] w_mem = {2'b0, w_addr[31:2]};

    always @(posedge i_clk) begin
        if (x_store) begin
           if (w_bits[0]) mem_file[w_mem][7:0]   <= w_val[7:0];
           if (w_bits[1]) mem_file[w_mem][15:8]  <= w_val[15:8];
           if (w_bits[2]) mem_file[w_mem][23:16] <= w_val[23:16];
           if (w_bits[3]) mem_file[w_mem][31:24] <= w_val[31:24];
        end
    end


    // Stage 5. WB, Write Back
    wire [31:0] next_pc = x_b       ?   pc_b      :
                          x_auipc   ?   pc_aui    :
                          x_jal     ?   pc_jal    :
                          x_jalr    ?   pc_jalr   :
                          pc + 32'h4;
    wire [31:0] dest_v = x_r       ?   nd         :
                         x_lui     ?   imm_lu20   :
                         x_auipc   ?   pc_aui     :
                         x_jal     ?   pc + 4   :
                         x_jalr    ?   pc + 4   :
                         x_load    ?   r_val :
                         32'b0;
    always @(posedge i_clk) begin
        if (i_rst) begin
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'b0;
            pc <= 32'b0;
        end else begin
            pc <= next_pc;
            // note x0 is always 0
            reg_file[rd] <= rd == 0 ? 32'b0 : dest_v;
        end
    end

    assign o_pc = pc;
    assign debug = dest_v;

endmodule
