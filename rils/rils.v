`include "../utils/ALU.v"
`include "../Control_Unit/CU.v"
`include "../Control_Unit/ALU_CU.v"
`include "../utils/RegFile.v"
`include "../utils/dataMemory.v"
`include "../utils/Mux.v"
`include "../instruction_fetch/instruction_fetch.v"
`include "../instruction_fetch/program_counter.v"

module load_store_R_I_instruction (instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst, zero_flag, immediate);

    parameter N = 32;

    input [N-1 : 0] instruction;
    input clk, rst, RegWrite, MemRead, MemWrite, MemtoReg, ALUSrc, RegDst;
    input [3:0] ALU_OP;
    output zero_flag;
    output [31:0] immediate;
    

    wire [4:0] read_reg_1, read_reg_2, write_reg;
    assign read_reg_1 = instruction[25:21];
    assign read_reg_2 = instruction[20:16];

    wire [31:0] alu_in;

    assign immediate = { {16{instruction[15]}}, instruction[15:0] };
    
    wire [N-1 : 0] data_out1, data_out2, result;
    wire [N-1 : 0] data_in;
    wire cout, slt, overflow;
    wire [31:0] writeAddress, writeData, readData, readAddress;

    
    Mux_2_1_5 m1(instruction[20:16], instruction[15:11], RegDst, write_reg);
    Mux_2_1_32 m2(data_out2, immediate, ALUSrc, alu_in);
    
    DataMemory D(writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);
    RegFile_32_32 RF(data_out1, data_out2, read_reg_1, read_reg_2, write_reg, data_in, RegWrite, rst, clk);
    
    ALU_32 alu(data_out1, alu_in, ALU_OP, result, cout, slt, overflow, zero_flag);
    Mux_2_1_32 m3(result, readData, MemtoReg, data_in);
    
    assign readAddress = result;
    assign writeData = data_out2; 
    assign writeAddress = result;
    
endmodule

module TestBench();

    wire [31:0] instruction;
    reg clk, rst;
    wire RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2;
    wire [3:0] ALU_OP;
    reg [5:0] alu_cu_in;
    wire [5:0] opcode, funct;
    wire zero_flag;
    wire [31:0] immediate;
 
    assign opcode = instruction[31:26];
    assign funct = instruction[5:0];

    always @(*)
    begin
        alu_cu_in[5:4] = {ALUOp1, ALUOp2};
        if (opcode == 6'b001000) begin
            alu_cu_in[3:0] = 4'b0000;
        end
        else if(opcode == 6'b001100) begin
            alu_cu_in[3:0] = 4'b0100;
        end
        else if(opcode == 6'b001101) begin
            alu_cu_in[3:0] = 4'b0101;
        end
        else begin
            alu_cu_in[3:0] = funct[3:0];
        end
            
    end


    Instruction_Fetch I(.rst(rst), .curr_instr(instruction), .zero_flag(zero_flag), .immediate(immediate), .Branch(Branch));
    Control_Unit cu(opcode, RegDst, ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp1, ALUOp2);
    ALU_CU alucu(alu_cu_in, ALU_OP);
    load_store_R_I_instruction L(instruction, clk, rst, ALU_OP, RegWrite, MemRead, MemWrite, MemToReg, ALUSrc, RegDst, zero_flag, immediate);

     /*Clock behaviour*/
    initial 
    begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Stop execution if all 1's instruction is encountered
    always @(*)
    begin
        if (instruction == 32'b11111111111111111111111111111111)
        begin
            $finish();
        end
    end

    initial
    begin
        #40;
        $monitor("\nCurrent Instruction: %32b at time %d", instruction, $time);
    end

    initial
    begin
        rst = 1;
        #40;
        rst = 0;
    end

endmodule