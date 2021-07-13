/*
Team Members:
1. Niranjan S Yadiyala - 181CO136
2. Shruthan R - 181CO250
3. Varun N R - 181CO134
4. Rajath C Aralikatti - 181CO241

Date : 13/03/2020

This file includes a 1-bit ALU module, a 32-bit ALU module that instantiates a 1-bit ALU 32 times and supports operations addition, subtracion, bitwise OR, AND, NOR, NAND, set less than and zero detection. There is also a module for the MIPS ALU Control Unit that takes in a binary string as input from the main Control Unit depending on the corresponding MIPS instruction, and gives output to the ALU, instructing it to perform the required operation.  

*/


`timescale 1ns/1ns

module And
(
    input a, b,
    output c
);
    assign c = a & b;

endmodule

module Or
(
    input a, b,
    output c
);
    assign c = a | b;

endmodule

module FullAdder
(
    input a, b, c,
    output sum, carry
);

    assign sum = a ^ b ^ c;
    assign carry = (a&b) | (b&c) | (c&a);

endmodule

module MIPS_ALU_CU(in_signal, ALU_OP);

    input[5:0] in_signal;
    output[3:0] ALU_OP;

    assign a = in_signal[5];
    assign b = in_signal[4];
    assign c = in_signal[3];
    assign d = in_signal[2];
    assign e = in_signal[1];
    assign f = in_signal[0];

    assign ALU_OP[3] = a & e & f;
    assign ALU_OP[2] = (~a & b) | (a & e);
    assign ALU_OP[1] = ~a | ~d;
    assign ALU_OP[0] = (a & ~e & f) | (a & c);

endmodule


module ALU_1
(
    input a, b, cin, 
    input [3:0] ALU_OP,
    output cout, result
);
    wire ainv, binv;
    wire[1:0] op;
    assign ainv = ALU_OP[3];
    assign binv = ALU_OP[2];
    assign op = ALU_OP[1:0];

    reg res;
    reg a1, b1;

    always@(*)
    begin
        case(ainv)
            1'b1:  a1 = ~a;
            1'b0:  a1 = a;
        endcase

        case(binv)
            1'b1:  b1 = ~b;
            1'b0:  b1 = b;  
        endcase  
    end

    wire c1, c2, s;

    And A(a1, b1, c1);

    Or O(a1, b1, c2);

    FullAdder FA(a1, b1, cin, s, cout);

    always@(*)
    begin
        case(op)
            2'b00: res = c1;
            2'b01: res = c2;
            2'b10: res = s;
            2'b11: res = s;
        endcase
    end

    assign result = res;

endmodule

module ALU_32
(
    input [31:0] A, B,
    input [3:0] ALU_OP,
    output [31:0] result,
    output cout, slt, overflow, zero_flag
);
    reg slt;
    reg zero_flag;
    wire [32:0] C;

    assign C[0] = ALU_OP[2];

    genvar i;

    generate
    for(i=0; i<32; i=i+1)
    begin
        ALU_1 Al(.a(A[i]), .b(B[i]), .ALU_OP(ALU_OP), .cin(C[i]), .result(result[i]), .cout(C[i+1]));
    end
    endgenerate

    assign cout = C[32];

    assign overflow = C[32] ^ C[31];

    always@(*)
    begin
        if(ALU_OP[1:0] == 2'b11)
        begin
            slt <= result[31];
        end

        if(result == 32'b0)
        begin
            zero_flag <= 1;
        end
        else
        begin
            zero_flag <= 0;
        end
    end

endmodule

module TB;

    reg [31:0] A, B;
    reg [5:0] in_signal;
    wire cout, slt, overflow, zero_flag;
    wire [31:0] result;
    wire [3:0] ALU_OP;
    
    MIPS_ALU_CU MIPSALU(in_signal, ALU_OP);
    ALU_32 alu(.A(A), .B(B), .ALU_OP(ALU_OP), .cout(cout), .slt(slt), .overflow(overflow), .result(result), .zero_flag(zero_flag));

    initial
    begin
        A = 32'b00000000000000001111111111111111;
        B = 32'b11111111111111110000000000000000;
        // ALU_OP = 4'b0010;
        in_signal = 6'b100000;
        #20;
        #1;
        $display("Operation : Addition\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 32'b00000011000000001111100001111001;
        B = 32'b11111111111111111110000000000000;
        // ALU_OP = 4'b0010;
        in_signal = 6'b110000;
        #20;
        #1;
        $display("Operation : Add Immediate\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 32'b11111111111110000000001111111111;
        B = 32'b11111111111110000000001111111111;
        // ALU_OP = 4'b0110;
        in_signal = 6'b100010;
        #20;
        #1;
        $display("Operation : Subtraction\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 32'b00000000010111011110111000000000;
        B = 32'b00000000000000011111001110111000;
        // ALU_OP = 4'b0010;
        in_signal = 6'b100000;
        #20;
        #1;
        $display("Operation : Addition\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 32'b00000000010111011110000000000000;
        B = 32'b00000000000000011111001110111000;
        // ALU_OP = 4'b0010;
        in_signal = 6'b000110;
        #20;
        #1;
        $display("Operation : Load Word\n");

        A = 32'b00000000010111011110000000000000;
        B = 32'b00000000000000011111001110111000;
        // ALU_OP = 4'b0110;
        in_signal = 6'b010110;
        #20;
        #1;
        $display("Operation : Branch on Equal\n");

        A = 32'b00000000010111011110000000000000;
        B = 32'b00000000010111011110000000000000;
        // ALU_OP = 4'b0110;
        in_signal = 6'b010110;
        #20;
        #1;
        $display("Operation : Branch on Equal\n");

        A = 32'b00001111111100001111011000001111;
        B = 32'b11111100011111110000000000000110;
        // ALU_OP = 4'b0000;
        in_signal = 6'b100100;
        #1;
        $display("Operation : Bitwise AND\n");
        #20;       

        A = 32'b00001111111100001111000000001111;
        B = 32'b11111110011111110000011100000000;
        // ALU_OP = 4'b0000;
        in_signal = 6'b110100;
        #1;
        $display("Operation : Bitwise AND Immediate\n");
        #20;   

        A = 32'b11110000000011110000111111110000;
        B = 32'b01011110011000000011110001100110;
        // ALU_OP = 4'b0001;
        in_signal = 6'b100101;
        #1;
        $display("Operation : Bitwise OR\n");
        #20;

        A = 32'b11110000000011110000111111110000;
        B = 32'b01011110011000000011110001100110;
        // ALU_OP = 4'b0001;
        in_signal = 6'b110101;
        #1;
        $display("Operation : Bitwise OR Immediate\n");
        #20;

        A = 32'b01011110011000000011110001100110;
        B = 32'b00000001100111000111000101010101;
        // ALU_OP = 4'b0110;
        in_signal = 6'b100010;
        #20;
        #1;
        $display("Operation : Subtraction");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 32'b11110000000011110000111111110000;
        B = 32'b01011110011000000011110001100110;
        // ALU_OP = 4'b1100;
        in_signal = 6'b100111;
        #1;
        $display("Operation : Bitwise NOR\n");
        #20;
    end

    initial
    begin
        $monitor("A = \t %b\nB = \t %b\nALU CU Input Signal = %b\nALU Operation = %b\nResult = %b\nZero Flag = %b", A, B, in_signal, ALU_OP, result, zero_flag);
    end

endmodule
