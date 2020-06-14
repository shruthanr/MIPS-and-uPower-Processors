module DataMemory (writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);

input [63:0] writeAddress;
input [63:0] writeData;
input [63:0] readAddress;
input MemRead, MemWrite;
output [63:0] readData;
input clk;
reg [63:0] DMemory[0:127];
reg[63:0] d_out;

initial begin
    $readmemb("Data_and_Instructions/mem.dat", DMemory, 0, 9);
end
/* Read */
always @(*)
begin
    if (MemRead) begin
            d_out = DMemory[readAddress];
    end
end
assign readData = d_out;


/* Write */
always @(posedge clk) 
begin
    if (MemWrite) begin 
        DMemory[writeAddress] = writeData;
    end
end
integer i;
always
    begin
        #40;
        $display("\nThese are the contents of the data memory at time %d : ", $time);
        for(i=0; i<10; i=i+1)
        begin
            $display("Loc %d : %d", i, DMemory[i]);
        end
    end

endmodule

