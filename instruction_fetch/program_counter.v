module Update_PC
(
    input [31:0] PC,
    output [31:0] new_PC,
    input Branch, zero_flag,
    input [31:0] immediate
);

    wire [31:0] Branch_Target;

    assign Branch_Target = (immediate << 2) + PC + 4;

    Mux_2_1_32 m4(PC+4, Branch_Target, (zero_flag & Branch), new_PC);

endmodule

module ProgramCounter
(
    input [31:0] in_PC, 
    input clk,
    input rst,
    output [31:0] out_PC
);

    reg [31:0] out_PC;

    always @(rst)
    begin
        if(rst)
        begin
            out_PC = 00000000000001000000000000000000;
        end
    end

    always @(posedge clk) 
    begin
        if(!rst)
        begin
            out_PC = in_PC;
        end
    end

endmodule