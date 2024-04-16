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
    input wire [31:0] i_inst,
    output reg [31:0] o_pc,
    output [31:0] debug
);
    // 32 * 32 bits regs
    reg [31:0] reg_file [31:0];
    integer i;

    // Step 1. IF, Instruction Fetch
    // See outside, i_inst = mem[o_pc];

    // Step 2. ID, Instruction Decode
    wire [6:0] opcode = i_inst[6:0];
    wire [4:0] rd = i_inst[11:7];
    wire [2:0] funct3 = i_inst[14:12];
    wire [4:0] rs1 = i_inst[19:15];
    wire [4:0] rs2 = i_inst[24:20];
    wire [6:0] funct7 = i_inst[31:25];
    wire [31:0] imm_i = {{21{i_inst[31]}}, i_inst[30:20]};  // i type immediate

    wire [31:0] n1 = reg_file[rs1];
    wire [31:0] n2 = opcode == `INST_TYPE_I_C ? imm_i : reg_file[rs2];
    wire signed [31:0] sn1 = n1;
    wire signed [31:0] sn2 = n2;
    wire [31:0] nd;

    wire [31:0] imm_sb = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0}; // SB type
    wire [31:0] imm_lui = {i_inst[31:12], 12'b0}; // LUI

    wire r_x = opcode == `INST_TYPE_R ||
               opcode == `INST_TYPE_I_C; // R
    wire lui_x = opcode == `INST_TYPE_U_LUI; // LUI

    // Step 3. Ex, Execute
    // R & I compute instruction
    assign nd = funct3 == `INST_ADD_SUB ? (funct7[5] == 1'b0 ? n1 + n2 : n1 - n2) :
                funct3 == `INST_SLL ? n1 << n2[4:0] :
                funct3 == `INST_SLT ? sn1 < sn2 :
                funct3 == `INST_SLTU ? n1 < n2 :
                funct3 == `INST_XOR ? n1 | n2 :
                funct3 == `INST_SRL_SRA ? (funct7[5] == 1'b0 ? n1 >> n2[4:0]: n1 >>> n2[4:0]):
                funct3 == `INST_OR ? n1 | n2 :
                n1 & n2;
    wire bx = funct3 == `INST_BEQ && n1 == n2 ||
              funct3 == `INST_BNE && n1 != n2 ||
              funct3 == `INST_BLT && n1 < n2 ||
              funct3 == `INST_BGE && n1 >= n2 ||
              funct3 == `INST_BLTU && sn1 < sn2 ||
              funct3 == `INST_BGEU && sn1 >= sn2;

    // Step 4. MEM, Data Memory Access


    // Step 5. WB, Write Back
    always @(posedge i_clk) begin
        if (i_rst) begin
            // note x0 is always 0
            for (i = 0; i < 32; i = i + 1)
                reg_file[i] <= 32'b0;
            o_pc <= 32'b0;
        end else begin
            o_pc <= bx ? o_pc + imm_sb : o_pc + 32'h1;
            reg_file[rd] <= r_x   ? nd :
                            lui_x ? imm_lui :
                            32'b0;
        end
    end

    assign debug = reg_file[rd];

endmodule
