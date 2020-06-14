`include "../utils/ALU.v"
`include "../utils/RegFile.v"

/*This module can execute MIPS I-type ALU instructions like addi, andi, ori.*/

module I_Type_Instructions (instruction, clk, rst, ALU_OP, RegWrite);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite;
    input [3:0] ALU_OP;

    wire [4:0] reg_id_r1, reg_id_r2, reg_id_w;
    assign reg_id_r1 = instruction[25:21];
    assign reg_id_r2 = instruction[20:16];
    assign reg_id_w = instruction[20:16];

    wire [31:0] immediate;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] };

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;

    RegFile_32_32 RF(data_out1, data_out2, reg_id_r1, reg_id_r2, reg_id_w, data_in, RegWrite, rst, clk);

    ALU_32 alu(data_out1, immediate, ALU_OP, result, cout, slt, overflow, zero_flag);

    assign data_in = result;
    
endmodule

module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite;
    reg [3:0] ALU_OP;
    integer i;

    I_Type_Instructions I(instruction, clk, rst, ALU_OP, RegWrite);

     /*Clock behaviour*/
    initial 
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial
    begin
        rst = 1;
        #40;

        rst = 0;
        RegWrite = 1;

        instruction = 32'b00100000000100000000000000010100;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : addi R16, R0, 20");
        #1;

        instruction = 32'b00100000010100010000000000111111;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : addi R17, R2, 63");
        #1;

        instruction = 32'b00100000100100101111111111111111;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : addi R18, R4, -1");
        #1;

        instruction = 32'b00110000110100110000000000000000;
        ALU_OP = 4'b0000;
        #39;
        $display("\nInstruction : andi R19, R6, 0");
        #1;

        instruction = 32'b00110101000101000000000000000000;
        ALU_OP = 4'b0001;
        #39;
        $display("\nInstruction : ori R20, R8, 0");
        #1;

        instruction = 32'b00100001011010111111111111110110;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : addi R11, R11, -10");
        #1;
        
        #10;
        $finish;
    end

endmodule