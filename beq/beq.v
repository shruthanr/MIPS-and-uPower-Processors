`include "../utils/ALU.v"
`include "../utils/RegFile.v"

/*This module can execute MIPS I-type ALU instructions like addi, andi, ori.*/

module beq_instruction(instruction, clk, rst, ALU_OP, RegWrite, pc, branchTarget);

    parameter N = 32;

    input [N-1 : 0] instruction, pc;
    input clk, rst, RegWrite;
    input [3:0] ALU_OP;
    output [31:0] branchTarget;
    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign read_reg_1 = instruction[25:21];
    assign read_reg_2 = instruction[20:16];
  
    wire [31:0] immediate;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] } << 2;

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;

    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);

    ALU_32 alu(data_out1, data_out2, ALU_OP, result, cout, slt, overflow, zero_flag);

    assign branchTarget = pc + immediate + 32'b00000000000000000000000000000100; // pc + left-shifted-immediate + 4

endmodule

module TestBench();

    reg [31:0] instruction, pc;
    wire [31:0] branchTarget;
    reg clk, rst, RegWrite;
    reg [3:0] ALU_OP;
    integer i;

    beq_instruction B(instruction, clk, rst, ALU_OP, RegWrite, pc, branchTarget);

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
        RegWrite = 0;
        pc = 32'b00000000000000000000000000000001;
        instruction = 32'b00010000001000100000000000000001;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : beq R1, R2, 1");
        $display("branchTarget = %d", branchTarget); // pc = 1; pc+4 is 5; immediate is 1; 1 << 2 = 4; 4+5 is 9
        #1;

        
        #10;
        $finish;
    end

endmodule