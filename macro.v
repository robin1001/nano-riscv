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


`define INST_TYPE_R        7'b0110011
`define INST_TYPE_I_C      7'b0010011  // I type, compute operation, +/- etc.
`define INST_TYPE_I_L      7'b0000011  // I type, Load releated
`define INST_TYPE_I_J      7'b1100111  // I type, JALR
`define INST_TYPE_I_CSR    7'b1110011
`define INST_TYPE_S        7'b1000011
`define INST_TYPE_SB       7'b1100111
`define INST_TYPE_U_LUI    7'b0110111
`define INST_TYPE_U_AUIPC  7'b0010111
`define INST_TYPE_UJ_JAL   7'b1101111

// R type instruction
`define INST_ADD_SUB  3'b000
`define INST_SLL      3'b001
`define INST_SLT      3'b010
`define INST_SLTU     3'b011
`define INST_XOR      3'b100
`define INST_SRL_SRA  3'b101
`define INST_OR       3'b110
`define INST_AND      3'b111

// I type instruction, compute
`define INST_ADDI   3'b000
`define INST_SLTI   3'b010
`define INST_SLTIU  3'b011
`define INST_XORI   3'b100
`define INST_ORI    3'b110
`define INST_ANDI   3'b111
`define INST_SLLI   3'b001
`define INST_SRI    3'b101

// I type instruction, load
`define INST_LB     3'b000
`define INST_LH     3'b001
`define INST_LW     3'b010
`define INST_LBU    3'b100
`define INST_LHU    3'b101

// I type instruction, JALR
`define INST_JALR   3'b000

// I type instruction, CSR
`define INST_CSRRW  3'b001
`define INST_CSRRS  3'b010
`define INST_CSRRC  3'b011
`define INST_CSRRWI 3'b101
`define INST_CSRRSI 3'b110
`define INST_CSRRCI 3'b111

// S type instruction
`define INST_SB     3'b000
`define INST_SH     3'b001
`define INST_SW     3'b010

// SB type instruction
`define INST_BEQ    3'b000
`define INST_BNE    3'b001
`define INST_BLT    3'b100
`define INST_BGE    3'b101
`define INST_BLTU   3'b110
`define INST_BGEU   3'b111
