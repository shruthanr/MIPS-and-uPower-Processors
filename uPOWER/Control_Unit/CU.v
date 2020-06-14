module Control_Unit(opcode, ext_opcode, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, reg1, reg2, ALU_OP);

    input [5:0] opcode;
    input [9:0] ext_opcode;
    output [3:0] ALU_OP;
    output RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, beq, bne, reg1, reg2;
    wire a, b, c, d, e, f, X;

    assign a = opcode[5];
    assign b = opcode[4];
    assign c = opcode[3];
    assign d = opcode[2];
    assign e = opcode[1];
    assign f = opcode[0];

    
    // ADD and AND/OR instrcutions have the same opcode of 31, so they are differentiated based on ext_opcode[2], whose value is 0 for ADD and 1 for AND/OR
    // Only RegDst and reg1 signals have different values for ADD and AND/OR
    assign X = ext_opcode[2];
    Mux_2_1_1 m6(~e, e, (opcode==31 && X==1), RegDst);
    Mux_2_1_1 m7((~c | e), (c & ~e), (opcode==31 && X==1), reg1);

    assign reg2 = ~a;
    assign ALUSrc = c & ~f;
    assign MemToReg = a;
    assign RegWrite = ~a | ~d;
    assign MemRead = ~d & e;
    assign MemWrite = a & d & e;
    assign beq = ~c & ~f;
    assign bne = ~c & f;

    // Generating input to the ALU_CU
    wire [3:0] alu_cu_in;
    wire [3:0] in1, in2, in;
    assign in1 = {opcode[4], opcode[2], opcode[5], opcode[0]};
    assign in2 = {ext_opcode[7], ext_opcode[5], ext_opcode[4], opcode[0]};
    Mux_2_1_4 m8(in1, in2, opcode[0], in);
    Mux_2_1_4 m9(in, 4'b1001, (opcode==52 || opcode==53), alu_cu_in);

    ALU_CU alucu(alu_cu_in, ALU_OP);

    initial
    begin
        #40;
        $display("CU : in1=%b, in2=%b, in=%b, alu_cu_in = %b, ALU_OP = %b", in1, in2, in, alu_cu_in, ALU_OP);
    end

endmodule