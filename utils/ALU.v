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