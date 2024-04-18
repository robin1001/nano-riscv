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

module nano_riscv_tb();
    reg rst;
    wire clk;
    wire [31:0] pc;
    wire [31:0] inst;
    wire [31:0] debug;

    clock_gen #(.PERIOD(2)) clk_g(.o_clk(clk));

    nano_riscv nano(
       .i_clk(clk),
       .i_rst(rst),
       .o_inst(inst),
       .o_pc(pc),
       .debug(debug)
    );

    integer i;
    initial begin
        rst = 1;
        #2;
        rst = 0;
        for (i = 0; i < 5; i = i + 1) begin
            #2;
            $display("%h %b %b", pc, inst, debug);
        end
        $finish;
    end

endmodule
