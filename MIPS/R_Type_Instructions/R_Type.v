`include "../utils/ALU.v"
`include "../utils/RegFile.v"

/*This module can execute MIPS R-type ALU instructions like add, sub, and, or.*/

module R_Type_Instructions (instruction, clk, rst, ALU_OP, RegWrite);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite;
    input [3:0] ALU_OP;

    wire [4:0] reg_id_r1, reg_id_r2, reg_id_w;
    assign reg_id_r1 = instruction[25:21];
    assign reg_id_r2 = instruction[20:16];
    assign reg_id_w = instruction[15:11];

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;

    RegFile_32_32 RF(data_out1, data_out2, reg_id_r1, reg_id_r2, reg_id_w, data_in, RegWrite, rst, clk);

    ALU_32 alu(data_out1, data_out2, ALU_OP, result, cout, slt, overflow, zero_flag);

    assign data_in = result;
    
endmodule

module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite;
    reg [3:0] ALU_OP;
    integer i;

    R_Type_Instructions R(instruction, clk, rst, ALU_OP, RegWrite);

     /*Clock behaviour*/
    initial 
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial
    begin
        rst = 1;
        #60;

        rst = 0;
        RegWrite = 1;

        instruction = 32'b00000000000000011000000000100000;
        ALU_OP = 4'b0010;
        #59;
        $display("\nInstruction : add R16, R0, R1");
        #1;

        instruction = 32'b00000000010000111000100000100000;
        ALU_OP = 4'b0010;
        #59;
        $display("\nInstruction : add R17, R2, R3");
        #1;

        instruction = 32'b00000000100001011001000000100000;
        ALU_OP = 4'b0010;
        #59;
        $display("\nInstruction : add R18, R4, R5");
        #1;

        instruction = 32'b00000000110001111001100000100100;
        ALU_OP = 4'b0000;
        #59;
        $display("\nInstruction : and R19, R6, R7");
        #1;

        instruction = 32'b00000001001010001010000000100010;
        ALU_OP = 4'b0110;
        #59;
        $display("\nInstruction : sub R20, R9, R8");
        #1;

        instruction = 32'b00000001010010101010100000100000;
        ALU_OP = 4'b0010;
        #59;
        $display("\nInstruction : add R21, R10, R10");
        #1;

        instruction = 32'b00000001011011000101100000100000;
        ALU_OP = 4'b0010;
        #59;
        $display("\nInstruction : add R11, R11, R12");
        #1;
        
        #10;
        $finish;
    end

endmodule