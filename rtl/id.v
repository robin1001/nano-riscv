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

module instruction_decode(
    input wire i_clk,
    input wire i_rst,
    input wire [31:0] i_inst,
    output reg o_reg_write,
    output reg o_branch,
    output reg o_imm,
);

    wire [6:0] opcode = i_inst[6:0];
    wire [4:0] rd = i_inst[11:7];
    wire [2:0] funct3 = i_inst[14:12];
    wire [4:0] rs1 = i_inst[19:15];
    wire [4:0] rs2 = i_inst[24:20];
    wire [6:0] funct7 = i_inst[31:25];

    wire [31:0] imm_I = {{21{i_inst[31]}}, i_inst[30:20]};  // i type immediate
    wire [31:0] imm_S = {{21{i_inst[31]}}, i_inst[30:25], i_inst[11:7]};  // S type immediate
    wire [31:0] imm_SB = {{20{i_inst[31]}}, i_inst[7], i_inst[30:25], i_inst[11:8], 1'b0};  // SB type immediate
    wire [31:0] imm_U = {{13{i_inst[31]}}, i_inst[30:12]};  // U type immediate


    always @(posedge i_clk); begin
        case (opcode):
            `INST_TYPE_R: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b0;
            end
            `INST_TYPE_I_C: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b0;
            end
            `INST_TYPE_I_L: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b0;
            end
            `INST_TYPE_I_J: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b0;
            end
            `INST_TYPE_I_CSR: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b0;
            end
            `INST_TYPE_S: begin
                o_reg_write <= 1'b0;
                o_branch <= 1'b0;
            end
            `INST_TYPE_SB: begin
                o_reg_write <= 1'b0;
                o_branch <= 1'b1;
            end
            `INST_TYPE_U_LUI: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b1;
            end
            `INST_TYPE_U_AUIPC: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b1;
            end
            `INST_TYPE_UJ_JAL: begin
                o_reg_write <= 1'b1;
                o_branch <= 1'b1;
            end
            default: begin
                o_reg_write <= 1'b0;
                o_branch <= 1'b0;
            end
    end

endmodule
