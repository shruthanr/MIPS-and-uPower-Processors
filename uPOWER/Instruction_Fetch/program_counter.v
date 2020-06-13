module Update_PC
(
    input [63:0] PC,
    input clk,
    output [63:0] new_PC
    
    // input Branch, zero_flag,
    // input [31:0] immediate
);
    assign new_PC = PC + 4;
    // wire [31:0] Branch_Target;

    // assign Branch_Target = (immediate << 2) + PC + 4;

    // Mux_2_1_32 m4(PC+4, Branch_Target, (zero_flag & Branch), new_PC);

endmodule

module ProgramCounter
(
    input [63:0] new_PC, 
    input clk,
    input rst,
    output [63:0] PC
);

    reg [63:0] update_PC;
    Update_PC upc(.PC(PC), .new_PC(new_PC));

    always @(rst)
    begin
        if(rst)
        begin
            update_PC = 0000000000000000000000000000000000000000000001000000000000000000;
        end
    end

    always @(posedge clk) 
    begin
        if(!rst)
        begin
            update_PC = new_PC;
        end
    end
    assign PC = update_PC;

endmodule