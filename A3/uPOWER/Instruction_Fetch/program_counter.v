module update_PC
(
    input [31:0] PC,
    input clk,
    output [31:0] new_PC
);

    assign new_PC = PC + 4;

endmodule

module ProgramCounter
(
    input [31:0] new_PC, 
    input clk,
    input rst,
    output [31:0] PC
);

    reg [31:0] update_PC;

    update_PC upc(.PC(PC), .new_PC(new_PC));

    always @(rst)
    begin
        if(rst)
        begin
            update_PC = 00000000000001000000000000000000;
        end
    end

    always @(posedge clk) 
    begin
        update_PC = new_PC;
    end

    assign PC = update_PC;

endmodule