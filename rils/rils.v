`include "../utils/ALU.v"
`include "../utils/RegFile.v"
`include "../utils/dataMemory.v"
`include "../utils/Mux.v"
`include "../instruction_fetch/instruction_fetch.v"
`include "../instruction_fetch/program_counter.v"
// `include "../instruction_fetch/instructions.mem"
// `include "../load-store/mem.dat"

module load_store_R_I_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst;
    input [3:0] ALU_OP;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign read_reg_1 = instruction[25:21];
    assign read_reg_2 = instruction[20:16];
    // assign write_reg = instruction[20:16];


    wire [31:0] immediate, alu_in;
    assign immediate = { {16{instruction[15]}}, instruction[15:0] };
    

    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow, zero_flag;
    wire [31:0] writeAddress, writeData, readData, readAddress;

    
    Mux_2_1_5 m1(instruction[20:16], instruction[15:11], RegDst, write_reg);
    Mux_2_1_32 m2(data_out2, immediate, ALUSrc, alu_in);
    
    DataMemory D(writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    
    ALU_32 alu(data_out1, alu_in, ALU_OP, result, cout, slt, overflow, zero_flag);
    Mux_2_1_32 m3(result, readData, MemtoReg, data_in);
    
    always @(posedge clk) begin
        // $display("data_in = %d, %d, %d, %d, %d, %d", result, readData, MemtoReg, data_in, MemRead, MemWrite);
        // $display("dataout1 = %d, alu_in=%d %d %d ", data_out1, alu_in, read_reg_1, read_reg_2);
    end
    
    assign readAddress = result;
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule

module TestBench();

    wire [31:0] instruction;
    reg clk, rst, RegWrite, MemWrite, MemRead, MemtoReg, ALUSrc, RegDst;
    reg [3:0] ALU_OP;
    
    integer i;

    Instruction_Fetch I(.rst(rst), .curr_instr(instruction));
    load_store_R_I_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst);

     /*Clock behaviour*/
    initial 
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial
    begin
        rst = 1;
        #60;

        rst = 0;
        RegWrite = 1;
        MemWrite = 0;
        MemRead = 1;
        MemtoReg = 1;
        RegDst = 0;
        ALUSrc = 1;

        $display("\nCurrent Instructino: %32b", instruction);

        // instruction = 32'b10001100010000010000000000000001;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : lw R1, 1(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b10001100010000110000000000000010;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : lw R3, 2(R2)"); // Locations 1 to 10 in data memory have value 8 stored in them.
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        RegWrite = 0;
        MemWrite = 1;
        MemRead = 0;

        
        // instruction = 32'b10101100101001010000000000000010;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : sw R5, 2(R5)"); // Contents of R5 to address pointed by (R5 + 2). Here 5 is stored in R5 
        $display("\nCurrent Instructino: %32b", instruction);
        #1;


        // instruction = 32'b10101100001001000000000000000010;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : sw R1, 2(R4)"); // Contents of R1 to address pointed by (R4 + 2). Here 4 is stored in R4 
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b10101100101010100000000000000011;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : sw R10, 3(R5)"); // Contents of R10 to address pointed by (R5 + 2). Here 5 is stored in R5 
        $display("\nCurrent Instructino: %32b", instruction);
        #1;
        
        // instruction = 32'b10101100101011010000000000000100;
        ALU_OP = 4'b0010;
        #39;
        $display("\nInstruction : sw R13, 4(R5)"); // Contents of R13 to address pointed by (R5 + 2). Here 5 is stored in R5 
        $display("\nCurrent Instructino: %32b", instruction);
        #1;
    
        MemtoReg = 0;
        MemWrite = 0;
        MemRead = 0;
        RegWrite = 1;

        // instruction = 32'b00100000000100010000000000010100;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : addi R17, R0, 20");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;
        
        // instruction = 32'b00000000000000101000000000100000;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        #39;
        $display("\nInstruction : add R16, R0, R1");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;


        // instruction = 32'b00100000010100100000000000111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : addi R18, R2, 63");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00000000010000111001100000100000;
        ALU_OP = 4'b0010;
        ALUSrc = 0;
        RegDst = 1;
        #39;
        $display("\nInstruction : add R19, R2, R3");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00100000100101001111111111111111;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : addi R20, R4, -1");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00000001001010001010100000100010;
        ALU_OP = 4'b0110;
        ALUSrc = 0;
        RegDst = 1;
        #39;
        $display("\nInstruction : sub R21, R9, R8");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00110000110101100000000000000000;
        ALU_OP = 4'b0000;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : andi R22, R6, 0");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00110101000101110000000000000000;
        ALU_OP = 4'b0001;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : ori R23, R8, 0");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00000000110001111100000000100100;
        ALU_OP = 4'b0000;
        ALUSrc = 0;
        RegDst = 1;
        #39;
        $display("\nInstruction : and R24, R6, R7");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;

        // instruction = 32'b00100001011010111111111111110110;
        ALU_OP = 4'b0010;
        ALUSrc = 1;
        RegDst = 0;
        #39;
        $display("\nInstruction : addi R11, R11, -10");
        $display("\nCurrent Instructino: %32b", instruction);
        #1;


    
        #10;
        $finish;
    end

    // initial
    // begin
    //     rst = 1;
    //     #60;

    //     $monitor("instruction %32b fetched at time %d", instruction, $time);
        
    //     #1000;
    //     $finish;
    // end

endmodule