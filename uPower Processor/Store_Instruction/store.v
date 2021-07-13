`include "../utils/ALU.v"
`include "../utils/RegFile.v"
`include "../utils/dataMemory.v"
module store_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite);

    parameter N = 64;

    input [31 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite;
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign read_reg_1 = instruction[20:16];
    assign read_reg_2 = instruction[25:21];

    wire [63:0] immediate;
    assign immediate = { {50{instruction[15]}}, instruction[15:2] };

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;
    wire [N-1:0] writeAddress, writeData, readData;

    DataMemory D(writeAddress, writeData, result, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    ALU_64 alu(data_out1, immediate, ALU_OP, result, cout, slt, overflow, zero_flag);
    
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule

module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite, MemWrite, MemRead;
    reg [3:0] ALU_OP;
    reg [31:0] DMemory[0:128];
    integer i;

    store_instruction S(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite);

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
        MemWrite = 1;
        MemRead = 0;



        instruction = 32'b11111000001001000000000000001000;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : std R1, 2(R4)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        #1;

        instruction = 32'b11111000110000100000000000001000;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : std R6, 2(R2)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        #1;

 
        #10;
        $finish;
    end

endmodule