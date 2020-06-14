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

    initial
    begin
        rst = 1;
        #40;

        rst = 0;
        // RegWrite = 1;
        // MemWrite = 0;
        // MemRead = 1;
        // MemToReg = 1;
        // RegDst = 0;
        // ALUSrc = 1;
        // reg1 = 1;
        // beq = 0;
        // bne = 0;
        
        #39;
        $display("\nInstruction : beq R1, R2, 1 \n %b", instruction); // Locations 1 to 10 in data memory have value 8 stored in them.
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        
        // instruction = 32'b11101000001000100000000000000100;
        // ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : ld R1, 1(R2) \n %b", instruction); // Locations 1 to 10 in data memory have value 8 stored in them.
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b11101000011000100000000000001000;
        // ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : ld R3, 2(R2) \n %b", instruction); // Locations 1 to 10 in data memory have value 8 stored in them.
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // RegWrite = 0;
        // MemWrite = 1;
        // MemRead = 0;
        // reg2 = 0;

        // instruction = 32'b11111000101000100000000000001000;
        // ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : std R5, 2(R2) \n %b", instruction); // Contents of R5 to address pointed by (R5 + 2). Here 5 is stored in R5 
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;


        // instruction = 32'b11111000001001000000000000001000;
        // ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : std R1, 2(R4) \n %b", instruction); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;
        
    
        // MemToReg = 0;
        // MemWrite = 0;
        // MemRead = 0;
        // RegWrite = 1;
        
        // instruction = 32'b00111010001000000000000000010100;
        // ALU_OP = 4'b0010;
        // ALUSrc = 1;
        // RegDst = 0;
        #39;
        $display("\nInstruction : addi R17, R0, 20");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;
        
        // instruction = 32'b01111110000000000000101000010100;
        // ALU_OP = 4'b0010;
        // ALUSrc = 0;
        // RegDst = 0;
        // reg2 = 1;
        #39;
        $display("\nInstruction : add R16, R0, R1");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;


        // instruction = 32'b00111010010000100000000000111111;
        // ALU_OP = 4'b0010;
        // ALUSrc = 1;
        #39;
        $display("\nInstruction : addi R18, R2, 63");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b01111110011000100001101000010100;
        // ALU_OP = 4'b0010;
        // ALUSrc = 0;
        #39;
        $display("\nInstruction : add R19, R2, R3");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b00111010100001001111111111111111;
        // ALU_OP = 4'b0010;
        // ALUSrc = 1;
        #39;
        $display("\nInstruction : addi R20, R4, -1");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b00000001001010001010100000100010;
        // ALU_OP = 4'b0110;
        // ALUSrc = 0;
        // RegDst = 1;
        // #39;
        // $display("\nInstruction : sub R21, R9, R8");
        // #1;

        // instruction = 32'b01110000110101100000000000000000;
        // ALU_OP = 4'b0000;
        // RegDst = 1;
        // reg1 = 0;
        #39;
        $display("\nInstruction : andi R22, R6, 0");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b01100001000101110000000000000000;
        // ALU_OP = 4'b0001;
        #39;
        $display("\nInstruction : ori R23, R8, 0");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b01111100110110000011100000111001;
        // ALU_OP = 4'b0000;
        // ALUSrc = 0;
        // RegDst = 1;
        // reg1 = 0;
        // reg2 = 1;
        #39;
        $display("\nInstruction : and R24, R6, R7");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        // instruction = 32'b01100001011010111111111111110110;
        // ALU_OP = 4'b0010;
        // ALUSrc = 1;
        // RegDst = 0;
        // reg1 = 1;
        #39;
        $display("\nInstruction : addi R11, R11, -10");
        $display("Control signals : %b, %b, %b, %b, %b, %b, %b, %b, %b, %b, %b", RegDst, reg1, reg2, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, ALU_OP);
        #1;

        #10;
        $finish;
    end

endmodule