module clock_gen(
    output reg o_clk
);
    parameter PERIOD = 2;

    initial begin
        o_clk = 1'b0;
    end

    always #(PERIOD / 2) begin
        o_clk = ~o_clk;
    end

endmodule
