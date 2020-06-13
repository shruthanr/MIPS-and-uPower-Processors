`include "./utils/ALU.v"
`include "./utils/RegFile.v"
`include "./utils/dataMemory.v"
`include "./utils/Mux.v"

module load_store_R_I_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst, XO);

    parameter N = 64;

    input [31 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst, XO; 
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    // assign read_reg_1 = instruction[25:21];
    // assign read_reg_2 = instruction[20:16];
    // assign write_reg = instruction[20:16];


    wire [N-1:0] alu_in;
    reg [N-1:0] immediate;
    always @(posedge clk) begin
    if (MemRead == 0 && MemWrite == 0)
        immediate = { {48{instruction[15]}}, instruction[15:0] };
    else
        immediate = { {50{instruction[15]}}, instruction[15:2] };   
    end
    

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;
    wire [N-1:0] writeAddress, writeData, readData, readAddress;
    wire [1:0] reg2;
    assign reg2[0] = XO;
    assign reg2[1] = MemWrite;

    
    Mux_2_1_5 m1(instruction[20:16], instruction[25:21], RegDst, write_reg);
    Mux_2_1_64 m2(data_out2, immediate, ALUSrc, alu_in);
    Mux_2_1_5 m3(instruction[25:21], instruction[20:16], XO, read_reg_1);
    Mux_4_1_5 m4(instruction[20:16], instruction[15:11], 5'b0, instruction[25:21], reg2, read_reg_2);
    
    
    DataMemory D(writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    
    ALU_64 alu(data_out1, alu_in, ALU_OP, result, cout, slt, overflow, zero_flag);
    Mux_2_1_64 m5(result, readData, MemtoReg, data_in);
    
    
    assign readAddress = result;
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule

module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite, MemWrite, MemRead, MemtoReg, ALUSrc, RegDst, XO;
    reg [3:0] ALU_OP;
    
    integer i;

    load_store_R_I_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst, XO);

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
        MemtoReg = 1;
        RegDst = 1;
        ALUSrc = 1;

        instruction = 32'b11101000001000100000000000000100;
        ALU_OP = 4'b0010;
        XO = 0;
        #39;
        $display("\nInstruction : ld R1, 1(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        #1;

        instruction = 32'b11101000011000100000000000001000;
        ALU_OP = 4'b0010;
        XO = 0;
        #39;
        $display("\nInstruction : ld R3, 2(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        #1;
        RegWrite = 0;
        MemWrite = 1;
        MemRead = 0;

        
        instruction = 32'b11111000101000100000000000001000;
        ALU_OP = 4'b0010;
        XO = 1;
        #39;
        $display("\nInstruction : std R5, 2(R2)"); // Contents of R5 to address pointed by (R5 + 2). Here 5 is stored in R5 
        #1;


        instruction = 32'b11111000001001000000000000001000;
        ALU_OP = 4'b0010;
        XO = 1;
        #39;
        $display("\nInstruction : std R1, 2(R4)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        #1;

        // instruction = 32'b10101100101010100000000000000011;
        // ALU_OP = 4'b0010;
        // #39;
        // $display("\nInstruction : sw R10, 3(R5)"); // Contents of R10 to address pointed by (R5 + 2). Here 5 is stored in R5 
        // #1;

        // instruction = 32'b10101100101011010000000000000100;
        // ALU_OP = 4'b0010;
        // #39;
        // $display("\nInstruction : sw R13, 4(R5)"); // Contents of R13 to address pointed by (R5 + 2). Here 5 is stored in R5 
        
    
        MemtoReg = 0;
        MemWrite = 0;
        MemRead = 0;
        RegWrite = 1;
        
        instruction = 32'b00111010001000000000000000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : addi R17, R0, 20");
        #1;
        
        instruction = 32'b01111110000000000000101000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : add R16, R0, R1");
        #1;


        instruction = 32'b00111010010000100000000000111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : addi R18, R2, 63");
        #1;

        instruction = 32'b01111110011000100001101000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : add R19, R2, R3");
        #1;

        instruction = 32'b00111010100001001111111111111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : addi R20, R4, -1");
        #1;

        // instruction = 32'b00000001001010001010100000100010;
        // ALU_OP = 4'b0110;
        // ALUSrc = 0;
        // RegDst = 1;
        // #39;
        // $display("\nInstruction : sub R21, R9, R8");
        // #1;

        instruction = 32'b01110000110101100000000000000000;
        ALU_OP = 4'b0000;
        ALUSrc = 1;
        RegDst = 0;
        XO = 0;
        #39;
        $display("\nInstruction : andi R22, R6, 0");
        #1;

        instruction = 32'b01100001000101110000000000000000;
        ALU_OP = 4'b0001;
        ALUSrc = 1;
        RegDst = 0;
        XO = 0;
        #39;
        $display("\nInstruction : ori R23, R8, 0");
        #1;

        instruction = 32'b01111100110110000011100000111001;
        ALU_OP = 4'b0000;
        ALUSrc = 0;
        RegDst = 0;
        XO = 1;
        #39;
        $display("\nInstruction : and R24, R6, R7");
        #1;

        instruction = 32'b01100001011010111111111111110110;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : addi R11, R11, -10");
        #1;

        #10;
        $finish;
    end

endmodule