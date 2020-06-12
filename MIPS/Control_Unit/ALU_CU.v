module ALU_CU(in_signal, ALU_OP);

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