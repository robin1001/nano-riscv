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

module instruction_fetch_tb();
    wire clk;
    reg rst;
    reg branch;
    reg [31:0] addr;
    wire [31:0] pc;

    clock_gen #(2) clk_gen(
        .o_clk(clk)
    );

    instruction_fetch inf(
       .i_clk(clk),
       .i_rst(rst),
       .i_branch(branch),
       .i_addr(addr),
       .o_pc(pc)
    );

    initial begin
        rst = 1; branch = 0;
        #2; $display("clk=%b pc=%b", clk, pc);
        rst = 0;
        #2; $display("clk=%b pc=%b", clk, pc);
        #2; $display("clk=%b pc=%b", clk, pc);
        #2; $display("clk=%b pc=%b", clk, pc);
        branch = 1; addr = 32'hFF;
        #2; $display("clk=%b pc=%b", clk, pc);
        $finish;
    end

endmodule
