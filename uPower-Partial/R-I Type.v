`include "ALU.v"
`include "RegFile.v"
`include "Mux.v"

/*This module can execute MIPS R-type as well as I-type ALU instructions like add, addi, and, andi, or, ori.*/

module R_I_Type_Instructions (instruction, clk, rst, ALU_OP, RegWrite, RegDst, ALUSrc, XO);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst;
    input RegWrite, RegDst, ALUSrc, XO; // Datapath control signals associated with this module
    input [3:0] ALU_OP; // ALU control signal which is given by the ALU Control Unit

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;

    wire [4:0] reg_id_r1, reg_id_r2, reg_id_w;
    // assign reg_id_r1 = instruction[25:21];
    assign reg_id_r2 = instruction[15:11];

    wire [31:0] immediate;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] };
    wire [31:0] alu_in;

    Mux_2_1_5 m1(instruction[20:16], instruction[25:21], XO, reg_id_w);
    Mux_2_1_5 m2(instruction[25:21], instruction[20:16], XO, reg_id_r1);

    Mux_2_1_32 m3(data_out2, immediate, ALUSrc, alu_in);

    RegFile_32_32 RF(data_out1, data_out2, reg_id_r1, reg_id_r2, reg_id_w, data_in, RegWrite, rst, clk);

    ALU_32 alu(data_out1, alu_in, ALU_OP, result, cout, slt, overflow, zero_flag);

    assign data_in = result;
    
endmodule

module TestBench();

    reg [31:0] instruction;
    reg clk, rst, RegWrite, ALUSrc, RegDst, XO;
    reg [3:0] ALU_OP;
    integer i;

    R_I_Type_Instructions RI(instruction, clk, rst, ALU_OP, RegWrite, RegDst, ALUSrc, XO);

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

        // instruction = 32'b00000000000000011000000000100000;
        instruction = 32'b01111110000000000000101000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : add R16, R0, R1");
        #1;

        // instruction = 32'b00100000000100010000000000010100;
        instruction = 32'b00111010001000000000000000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        XO = 1;
        #39;
        $display("\nInstruction : addi R17, R0, 20");
        #1;

        // instruction = 32'b00100000010100100000000000111111;
        instruction = 32'b00111010010000100000000000111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        XO = 1;
        #39;
        $display("\nInstruction : addi R18, R2, 63");
        #1;

        // instruction = 32'b00000000010000111001100000100000;
        instruction = 32'b01111110011000100001101000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : add R19, R2, R3");
        #1;

        // instruction = 32'b00100000100101001111111111111111;
        instruction = 32'b00111010100001001111111111111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
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

        // instruction = 32'b00110000110101100000000000000000;
        instruction = 32'b01110000110101100000000000000000;
        ALU_OP = 4'b0000;
        ALUSrc = 1;
        RegDst = 0;
        XO = 0;
        #39;
        $display("\nInstruction : andi R22, R6, 0");
        #1;

        // instruction = 32'b00110101000101110000000000000000;
        instruction = 32'b01100001000101110000000000000000;
        ALU_OP = 4'b0001;
        ALUSrc = 1;
        RegDst = 0;
        XO = 0;
        #39;
        $display("\nInstruction : ori R23, R8, 0");
        #1;

        // instruction = 32'b00000000110001111100000000100100;
        instruction = 32'b01111100110110000011100000111001;
        ALU_OP = 4'b0000;
        ALUSrc = 0;
        RegDst = 1;
        XO = 1;
        #39;
        $display("\nInstruction : and R24, R6, R7");
        #1;

        // instruction = 32'b00100001011010111111111111110110;
        instruction = 32'b01100001011010111111111111110110;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        XO = 1;
        #39;
        $display("\nInstruction : addi R11, R11, -10");
        #1;
        
        #10;
        $finish;
    end

endmodule