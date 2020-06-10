`include "../utils/ALU.v"
`include "../utils/RegFile.v"
`include "../utils/dataMemory.v"

module load_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite;
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign read_reg_1 = instruction[25:21];
    assign write_reg = instruction[20:16];

    wire [31:0] immediate;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] };

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;
    wire [31:0] writeAddress, writeData, readData;

    DataMemory D(writeAddress, writeData, result, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    ALU_32 alu(data_out1, immediate, ALU_OP, result, cout, slt, overflow, zero_flag);
    
    assign data_in = readData; 
    
endmodule


module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite, MemWrite, MemRead;
    reg [3:0] ALU_OP;
    reg [31:0] DMemory[0:128];
    integer i;

    load_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite);

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
        MemWrite = 0;
        MemRead = 1;

        instruction = 32'b10001100010000010000000000000001;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : lw R1, 1(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        #1;

    
        #10;
        $finish;
    end

endmodule