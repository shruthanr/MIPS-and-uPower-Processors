module Instruction_Memory
(
    input [31:0] curr_line,
    output [31:0] curr_instr
);

    reg [31:0] instruction_memory [0:100];
    initial
    begin
        $readmemb("instructions.mem", instruction_memory);
    end

    assign curr_instr = instruction_memory[curr_line]; 

endmodule

module Instruction_Fetch
(
    input rst, Branch, zero_flag,
    input [31:0] immediate,
    output [31:0] curr_instr
);

    wire [31:0] PC, new_PC;
    wire [31:0] curr_instr;
    wire [31:0] curr_line;

    reg clk;

    initial
    begin
        clk = 0;
        #60;
        forever #20 clk = ~clk;
    end

    ProgramCounter p(.clk(clk), .rst(rst), .out_PC(PC), .in_PC(new_PC));
    Update_PC upc(PC, new_PC, Branch, zero_flag, immediate);

    reg [31:0] offset = 00000000000001000000000000000000;
    assign curr_line = (PC - offset)/4;

    Instruction_Memory M(.curr_line(curr_line), .curr_instr(curr_instr));

endmodule

/* module Instruction_Fetch_tb;

    reg clk = 1'b0;
    reg rst = 1'b0;
    wire [31:0] curr_instr;

    always #100 clk = ~clk;

    Instruction_Fetch I(.rst(rst), .clk(clk), .curr_instr(curr_instr));

    initial
    begin
        rst = 1;
        #500;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;

        rst = 0;
        #100;
    end

    initial
    begin 
        $monitor("Current instruction is %32b at time %d", curr_instr, $time);

        #10000;
        $finish;
    end

endmodule */