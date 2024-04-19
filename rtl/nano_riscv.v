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
    wire [31:0] addr = reg_file[rs1] + imm_i;


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
