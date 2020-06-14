`include "./utils/ALU.v"
`include "./utils/RegFile.v"
`include "./utils/dataMemory.v"
`include "./utils/Mux.v"
`include "Control_Unit/CU.v"
`include "Control_Unit/ALU_CU.v"
`include "instruction_fetch/instruction_fetch.v"
`include "instruction_fetch/program_counter.v"

module load_store_R_I_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, RegDst, reg1, reg2, zero_flag, immediate);

    parameter N = 64;

    input [31 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, RegDst, reg1, reg2; 
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    // assign read_reg_1 = instruction[25:21];
    // assign read_reg_2 = instruction[20:16];
    // assign write_reg = instruction[20:16];


    wire [N-1:0] alu_in;
    output reg [N-1:0] immediate;
    output zero_flag;
    always @(*) 
    begin
        if (MemRead == 0 && MemWrite == 0)
            immediate = { {48{instruction[15]}}, instruction[15:0] };
        else
            immediate = { {50{instruction[15]}}, instruction[15:2] };   
    end
    

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow;
    wire [N-1:0] writeAddress, writeData, readData, readAddress;
    
    Mux_2_1_5 m1(instruction[25:21], instruction[20:16], RegDst, write_reg);
    Mux_2_1_64 m2(data_out2, immediate, ALUSrc, alu_in);
    Mux_2_1_5 m3(instruction[25:21], instruction[20:16], reg1, read_reg_1);
    Mux_2_1_5 m4(instruction[25:21], instruction[15:11], reg2, read_reg_2);
    
    
    DataMemory D(writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    
    ALU_64 alu(data_out1, alu_in, ALU_OP, result, cout, slt, overflow, zero_flag);
    Mux_2_1_64 m5(result, readData, MemToReg, data_in);
    
    
    assign readAddress = result;
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule

module TestBench();

    wire [31:0] instruction;
    reg clk, rst;
    wire RegWrite, MemWrite, MemRead, MemToReg, ALUSrc, RegDst, reg1, reg2, beq, bne, zero_flag;
    wire [3:0] ALU_OP;
    wire [63:0] immediate;
    
    integer i;
    Instruction_Fetch I(.rst(rst), .curr_instr(instruction), .zero_flag(zero_flag), .immediate(immediate), .BranchEqual(beq), .BranchNotEqual(bne));
    Control_Unit cu(instruction[31:26], instruction[10:1], RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, reg1, reg2, ALU_OP);
    load_store_R_I_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, RegDst, reg1, reg2, zero_flag, immediate);

     /*Clock behaviour*/
    initial 
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Stop execution if all 1's instruction is encountered
    always @(*)
    begin
        if (instruction == 32'b11111111111111111111111111111111)
        begin
            $finish();
        end
    end

    initial
    begin
        #40;
        $monitor("\nCurrent Instruction: %32b at time %d", instruction, $time);
    end

    initial
    begin
        rst = 1;
        #40;
        rst = 0;
    end

endmodule