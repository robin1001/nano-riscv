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


// The defination is from "The RISC-V Instruction Set Manual Volume",
// Chapter 9: RV32/64G Instruction Set Listings
// see https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf
// for details


`include "macro.v"

module nano_riscv (
    input i_clk,
    input i_rst,
    input [31:0] i_inst,
);

    reg [31:0] pc;
    reg [31:0] regs [31:0];  // 32 * 32 bits regs

    wire [6:0] opcode = i_inst[6:0];
    wire [4:0] rd = i_inst[11:7];
    wire [2:0] funct3 = i_inst[14:12];
    wire [4:0] rs1 = i_inst[19:15];
    wire [4:0] rs2 = i_inst[24:20];
    wire [6:0] funct7 = i_inst[31:25];

    always @(posedge i_clk) begin

    end

endmodule
