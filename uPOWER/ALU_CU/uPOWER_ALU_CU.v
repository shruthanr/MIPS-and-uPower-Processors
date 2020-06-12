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

module uPower_ALU_CU(in_signal, ALU_OP);

    input[3:0] in_signal;
    output[3:0] ALU_OP;

    assign m = in_signal[3];
    assign n = in_signal[2];
    assign p = in_signal[1];
    assign q = in_signal[0];

    assign ALU_OP[3] = m & (~n) & p;
    assign ALU_OP[2] = q & (m ^ n);
    assign ALU_OP[1] = (~m & n) | (p ^ q);
    assign ALU_OP[0] = (~n & ~q) | (p & q & m);
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

module ALU_64
(
    input [63:0] A, B,
    input [3:0] ALU_OP,
    output [63:0] result,
    output cout, slt, overflow, zero_flag
);
    reg slt;
    reg zero_flag;
    wire [64:0] C;

    assign C[0] = ALU_OP[2];

    genvar i;

    generate
    for(i=0; i<64; i=i+1)
    begin
        ALU_1 Al(.a(A[i]), .b(B[i]), .ALU_OP(ALU_OP), .cin(C[i]), .result(result[i]), .cout(C[i+1]));
    end
    endgenerate

    assign cout = C[64];

    assign overflow = C[64] ^ C[63];

    always@(*)
    begin
        if(ALU_OP[1:0] == 2'b11)
        begin
            slt <= result[31];
        end

        if(result == 64'b0)
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

    reg [63:0] A, B;
    reg [3:0] in_signal;
    wire cout, slt, overflow, zero_flag;
    wire [63:0] result;
    wire [3:0] ALU_OP;
    
    uPower_ALU_CU upowerALU(in_signal, ALU_OP);
    ALU_64 alu(.A(A), .B(B), .ALU_OP(ALU_OP), .cout(cout), .slt(slt), .overflow(overflow), .result(result), .zero_flag(zero_flag));

    initial
    begin
        A = 64'b0000000000000000000000000000000011111111111111111111111111111111;
        B = 64'b1111111111111111111111111111111100000000000000000000000000000000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b0001;
        #20;
        #1;
        $display("Operation : Addition\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 64'b0000001100000000111110000111100100000011000000001111100001111001;
        B = 64'b1111111111111111111000000000000011111111111111111110000000000000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b0100;
        #20;
        #1;
        $display("Operation : Add Immediate\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);


        A = 64'b1111111111111000000000111111111111111111111110000000001111111111;
        B = 64'b1111111111111000000000111111111111111111111110000000001111111111;
        // ALU_OP = 4'b0110;
        in_signal = 4'b0101;
        #20;
        #1;
        $display("Operation : Subtraction\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 64'b00000000010111011110111000000000;
        B = 64'b00000000000000011111001110111000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b0001;
        #20;
        #1;
        $display("Operation : Addition\n");
        $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 64'b0000111111110000111100000000111100001111111100001111000000001111;
        B = 64'b1111111111111111000000000000000011111111111111110000000000000000;
        // ALU_OP = 4'b0000;
        in_signal = 4'b0011;
        #20; 
        #1;
        $display("Operation : Bitwise AND\n");
    
        A = 64'b0000111111110000111100000000111100001111111100001111000000001111;
        B = 64'b1111111001111111000001110000000011111110011111110000011100000000;
        // ALU_OP = 4'b0000;
        in_signal = 4'b1100;
        #1;
        $display("Operation : Bitwise AND Immediate\n");
        #20;   
              
        A = 64'b0000000001011101111000000000000000000000010111011110000000000000;
        B = 64'b0000000000000001111100111011100000000000000000011111001110111000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b0110;
        #20;
        #1;
        $display("Operation : Load Word\n");
    

        A = 64'b0000000001011101111000000000000000000000010111011110000000000000;
        B = 64'b0000000000000001111100111011100000000000000000011111001110111000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b1001;
        #20;
        #1;
        $display("Operation : Branch on Equal\n");

        A = 64'b0000000001011101111000000000000000000000010111011110000000000000;
        B = 64'b0000000001011101111000000000000000000000010111011110000000000000;
        // ALU_OP = 4'b0010;
        in_signal = 4'b1001;
        #20;
        #1;
        $display("Operation : Branch on Equal\n");
        #20

        A = 64'b1111000000001111000011111111000011110000000011110000111111110000;
        B = 64'b0101111001100000001111000110011001011110011000000011110001100110;
        // ALU_OP = 4'b0001;
        in_signal = 4'b1111;
        #1;
        $display("Operation : Bitwise OR\n");
        #20;

        A = 64'b1111000000001111000011111111000011110000000011110000111111110000;
        B = 64'b0101111001100000001111000110011001011110011000000011110001100110;
        // ALU_OP = 4'b0001;
        in_signal = 4'b1000;
        #1;
        $display("Operation : Bitwise OR Immediate\n");
        #20;

        // A = 32'b01011110011000000011110001100110;
        // B = 32'b00000001100111000111000101010101;
        // ALU_OP = 4'b0110;
        // #20;
        // #1;
        // $display("Operation : Subtraction");
        // $display("CarryOut = %b\t Overflow = %b\n", cout, overflow);

        A = 64'b0000111111110000111100000000111100001111111100001111000000001111;
        B = 64'b1111111111111111000000000000000011111111111111110000000000000000;
        // ALU_OP = 4'b1101;
        in_signal = 4'b1011;
        #1;
        $display("Operation : Bitwise NAND\n");
        #20;

        // A = 64'b1111000000001111000011111111000011110000000011110000111111110000;
        // B = 64'b0101111001100000001111000110011001011110011000000011110001100110;
        // ALU_OP = 4'b1100;
        // #1;
        // $display("Operation : Bitwise NOR\n");
        // #20;
    end

    initial
    begin
        $monitor("A = \t %b\nB = \t %b\nALU Operation = %b\nResult = %b\nZero Flag = %b", A, B, ALU_OP, result, zero_flag);
    end

endmodule
