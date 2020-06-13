
/*
* Register file with 32 registers. 32b per register.
* 2 read ports : reg_id_r1, data_out1; reg_id_r2, data_out2
* 1 write port : reg_id_w, data_in
* default : read from reg_id_r1, reg_id_r2
* write will happen into reg_id_w when wr = 1
*/

module RegFile_32_32 (data_out1, data_out2, reg_id_r1, reg_id_r2, reg_id_w, data_in, wr, rst, clk);

    parameter N = 32;   // 32b register
    parameter R = 32;   // 32 registers
    // Regsiter address - 5b = log_2(R)
    parameter ASIZE = $clog2(R);

    input [N-1 : 0] data_in;
    input [ASIZE-1 : 0] reg_id_w;
    input wr;

    output reg [N-1 : 0] data_out1, data_out2;
    input [ASIZE-1 : 0] reg_id_r1, reg_id_r2;

    input rst, clk;

    reg [N-1 : 0] reg_file[R-1 : 0]; 

    integer i;

    /* Initializing register file */
    initial 
    begin
        #5;
        $readmemb("Data_Instructions/reg1.dat", reg_file);
    end

    /*Reset behaviour*/
    always @(rst)
        if(rst)
        begin
            // All registers cleared
            for(i=0; i<R; i=i+1)
                reg_file[i] = 0;
        end

    /*Write behaviour*/
    always @(posedge clk)
    begin
        if(!rst && wr)
        begin
            reg_file[reg_id_w] <= data_in;
        end
            
    end

    /*Read behaviour*/
    always @(posedge clk)
    begin
        if(!rst)
        begin
            data_out1 <= reg_file[reg_id_r1];
            data_out2 <= reg_file[reg_id_r2];
        end
    end

    /*Writing sample data into register file, for testing purpose.*/
    // initial
    // begin
    //     i = 0;
    //     #10;
    //     $display("\nWriting data into registers : \n");
    //     for(i=0; i<N/2; i=i+1)
    //     begin
    //         reg_file[i] = i;
    //         $display("%d written into register %d", i, i);
    //     end
    // end

    /*Printing contents of register file at regular intervals*/
    always 
    begin
        #40;
        $display("\nThese are the contents of the register file at time %d : ", $time);
        for(i=0; i<N; i=i+1)
        begin
            $display("Register %d : %d", i, reg_file[i]);
        end
    end

endmodule