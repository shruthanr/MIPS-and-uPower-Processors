module Control_Unit(opcode, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2);

    input [5:0] opcode;
    output RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;

    wire a, b, c, d, e, f;

    assign a = opcode[5];
    assign b = opcode[4];
    assign c = opcode[3];
    assign d = opcode[2];
    assign e = opcode[1];
    assign f = opcode[0];

    assign RegDst = ~a & ~c;
    assign ALUSrc = f | c;
    assign MemToReg = e;
    assign RegWrite = (~c & ~d) | (~a & c);
    assign MemRead = ~c & f;
    assign MemWrite = c & e;
    assign Branch = ~c & d;
    assign ALUOp1 = (~a & ~d) | (~a & c);
    assign ALUOp2 = d | (~a & c);

endmodule