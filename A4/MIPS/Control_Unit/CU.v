module Control_Unit(opcode, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, BranchEqual, BranchNotEqual, ALUOp1, ALUOp2);

    input [5:0] opcode;
    output RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, BranchEqual, BranchNotEqual, ALUOp1, ALUOp2;

    wire a, b, c, d, e, f;

    assign a = opcode[5];
    assign b = opcode[4];
    assign c = opcode[3];
    assign d = opcode[2];
    assign e = opcode[1];
    assign f = opcode[0];

    assign RegDst = ~a & ~c;
    assign ALUSrc = e | c;
    assign MemToReg = e;
    assign RegWrite = (~c & ~d) | (~a & c);
    assign MemRead = ~c & e;
    assign MemWrite = c & e;
    assign BranchEqual = ~c & d & ~f;
    assign BranchNotEqual = ~a & ~c & f;
    assign ALUOp1 = (~a & ~d) | (~a & c);
    assign ALUOp2 = d | (~a & c);

endmodule