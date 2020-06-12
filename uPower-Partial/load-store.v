`include "ALU.v"
`include "RegFile.v"
`include "dataMemory.v"
`include "Mux.v"

module load_store_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, XO);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite, XO;
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign write_reg = instruction[25:21];
    Mux_2_1_5 m1(instruction[25:21], instruction[20:16],  XO, read_reg_1);
    Mux_2_1_5 m2(instruction[20:16], instruction[25:21],  XO, read_reg_2);

    wire [31:0] immediate;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] };

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;
    wire [31:0] writeAddress, writeData, readData, readAddress;
    

    DataMemory D(writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    ALU_32 alu(data_out1, immediate, ALU_OP, result, cout, slt, overflow, zero_flag);

    
    assign readAddress = result;
    assign data_in = readData; 
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule


module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite, MemWrite, MemRead, XO;
    reg [3:0] ALU_OP;
    reg [31:0] DMemory[0:128];
    integer i;

    load_store_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, XO);

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

        instruction = 32'b10000000001000100000000000000001;
        // instruction = 32'b100011 00010 00001 0000000000000001;
        ALU_OP = 4'b0010;
        XO = 0;
        #39;
        $display("\nInstruction : lw R1, 1(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        

        #1;
        instruction = 32'b10000000011000100000000000000010;
        ALU_OP = 4'b0010;
        XO = 0;
        #39;
        $display("\nInstruction : lw R3, 2(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.

        #1;
        RegWrite = 0;
        MemWrite = 1;
        MemRead = 0;

        
        instruction = 32'b10010000001001000000000000000010;
        ALU_OP = 4'b0010;
        XO = 1;
        #39;
        $display("\nInstruction : stw R1, 2(R4)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        #1;

        instruction = 32'b10010000101000100000000000000010;
        ALU_OP = 4'b0010;
        XO = 1;
        #39;
        $display("\nInstruction : stw R5, 2(R2)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        #1;
    


    
        #10;
        $finish;
    end

endmodule