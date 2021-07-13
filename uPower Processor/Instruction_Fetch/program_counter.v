module Update_PC
(
    input [63:0] PC,
    output [63:0] new_PC,
    input BranchEqual, BranchNotEqual, zero_flag,
    input [63:0] immediate
);
    // assign new_PC = PC + 4;
    wire [63:0] Branch_Target;

    assign Branch_Target = (immediate << 2) + PC + 4;

    wire Branch_Condition;
    assign Branch_Condition = (zero_flag & BranchEqual) | (~zero_flag & BranchNotEqual);

    Mux_2_1_64 m4(PC+4, Branch_Target, Branch_Condition, new_PC);

endmodule

module ProgramCounter
(
    input [63:0] in_PC, 
    input clk,
    input rst,
    output [63:0] out_PC
);

    reg [63:0] out_PC;
   

    always @(rst)
    begin
        if(rst)
        begin
            out_PC = 0000000000000000000000000000000000000000000001000000000000000000;
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