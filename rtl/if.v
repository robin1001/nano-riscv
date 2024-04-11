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


module instruction_fetch(
    input wire i_clk,
    input wire i_rst,
    input wire i_branch,
    input wire [31:0] i_addr,  // target address
    output reg [31:0] o_pc
);

    always @(posedge i_clk) begin
        if (i_rst)
            o_pc <= 32'b0;
        else if (i_branch)
            o_pc <= i_addr;
        else
            o_pc <= o_pc + 32'h4;
    end

endmodule
