module DataMemory (writeAddress, writeData, readAddress, readData, MemWrite, MemRead, clk);

input [31:0] writeAddress;
input [31:0] writeData;
input [31:0] readAddress;
input MemRead, MemWrite;
output [31:0] readData;
input clk;
reg [31:0] DMemory[0:127];
reg[31:0] d_out;

initial begin
    $readmemb("mem.dat", DMemory, 0, 9);
end
/* Read */
always @(*)
begin
    if (MemRead) begin
        /*if (MemWrite && writeAddress==readAddress) 
            d_out = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        else */
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

