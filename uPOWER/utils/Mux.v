module Mux_2_1_5 (a1, a2, s, res);  

    parameter N = 5;

    input [N-1 : 0] a1, a2;
    input s;
    output [N-1 : 0] res;

    reg [N-1 : 0] A;
    always @(*)
    begin
        case (s)
            1'b0 : A <= a1;
            1'b1 : A <= a2;
        endcase
    end
    
    assign res = A;

endmodule

module Mux_3_1_5 (a1, a2, a3, s, res);  

    parameter N = 5;

    input [N-1 : 0] a1, a2, a3;
    input [1:0] s;
    output [N-1 : 0] res;

    reg [N-1 : 0] A;
    always @(*)
    begin
        case (s)
            2'b00 : A <= a1;
            2'b01 : A <= a2;
            2'b10 : A <= a3;
        endcase
    end
    
    assign res = A;

endmodule

module Mux_4_1_5 (a1, a2, a3, a4, s, res);  

    parameter N = 5;

    input [N-1 : 0] a1, a2, a3, a4;
    input [1:0] s;
    output [N-1 : 0] res;

    reg [N-1 : 0] A;
    always @(*)
    begin
        case (s)
            2'b00 : A <= a1;
            2'b01 : A <= a2;
            2'b10 : A <= a3;
            2'b11 : A <= a4;
        endcase
    end
    
    assign res = A;

endmodule

module Mux_2_1_32 (a1, a2, s, res);  

    parameter N = 32;

    input [N-1 : 0] a1, a2;
    input s;
    output [N-1 : 0] res;

    reg [N-1 : 0] A;
    always @(*)
    begin
        case (s)
            1'b0 : A <= a1;
            1'b1 : A <= a2;
        endcase
    end
    
    assign res = A;

endmodule

module Mux_2_1_64 (a1, a2, s, res);  

    parameter N = 64;

    input [N-1 : 0] a1, a2;
    input s;
    output [N-1 : 0] res;

    reg [N-1 : 0] A;
    always @(*)
    begin
        case (s)
            1'b0 : A <= a1;
            1'b1 : A <= a2;
        endcase
    end
    
    assign res = A;

endmodule