


//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/30/2025 05:12:32 PM
// Module Name: tb_SYNC_FIFO
// Description:    Testbench for synchronous FIFO
// Dependencies:   Requires SYNC_FIFO module
//////////////////////////////////////////////////////////////////////////////////






`timescale 1ns / 1ps

module tb_SYNC_FIFO();

parameter fifo_depth = 8;
parameter data_width = 32;

// DUT interface signals


reg cs,clk,rst,wr_en,rd_en;
reg [data_width - 1:0]d_in;            // Data to be written into FIFO
wire [data_width - 1:0]d_out;          // Data read from FIFO
wire full,empty;                       // FIFO status flags
integer i;                              // Loop counter for test scenarios



// Instantiate FIFO DUT with required parameters
SYNC_FIFO #(.fifo_depth(fifo_depth),
            .data_width(data_width)) dut(
              .d_in(d_in),
              .clk(clk),
              .rst(rst),
              .cs(cs),
              .wr_en(wr_en),
              .rd_en(rd_en),
              .d_out(d_out),
              .full(full),
              .empty(empty));


// Clock generation: toggles every 5 ns → 10 ns period → 100 MHz clock
initial begin
  clk = 1'b0;
end
always #5 clk = ~clk;






// Task to perform write operation into FIFO

task wr_data(input[data_width - 1:0]data_in);
      begin
          @(posedge clk);            // Wait for next positive clock edge
          
          cs = 1;                    // Enable FIFO
          wr_en = 1;                 // Assert write enable
          d_in = data_in;            // Drive input data
          
          // $monitor prints whenever monitored variable changes, showing write activity
          $monitor($time," wr_data d_in = %0d",data_in);
          
          @(posedge clk);            // One clock later, complete write
          
          cs = 1;
          wr_en = 0;                 // De-assert write enable
      end
endtask






// Task to read a single data word from FIFO

task rd_data();
      begin
          @(posedge clk);            // Wait for clock
          
          cs = 1;
          rd_en = 1;                 // Assert read enable
          
          @(posedge clk);            // Data becomes available on next clock
          
          // Display read data
          $display ($time, " read_data d_out = %0d", d_out);
          
          cs = 1;
          rd_en = 0;                 // De-assert read enable
      end
endtask



// Testbench stimulus: Applies three test scenarios


initial begin
      
      #1;
      
      // Initial state: all control signals low, reset asserted
      rst = 0;
      rd_en = 0;
      wr_en = 0;
      
      @(posedge clk)
      rst = 1;                       // Release reset at next clock edge
      
      // ==================== SCENARIO 1 ====================
      $monitor($time, "\n SCENARIO 1");
      
      // Write 3 values and read 3 values
      wr_data(1);
      wr_data(10);
      wr_data(100);                  // FIFO now has 3 elements

      rd_data();
      rd_data();
      rd_data();                     // After 3 reads, FIFO becomes empty
      
      // ==================== SCENARIO 2 ====================
      $monitor($time, "\n SCENARIO 2");
      
      // Repeated write-read pairs to test continuous operation
      for(i=0;i<fifo_depth; i = i+1)
           begin
               wr_data(2**i);        // Write 2 power of i for every write
               rd_data();            // Immediately read it back
           end
           
      // ==================== SCENARIO 3 ====================
      $monitor($time, "\n SCENARIO 3");
      
      // Fill FIFO completely: write 8 different values
      for(i=0;i<fifo_depth; i = i+1)
           begin
               wr_data(2**i);        // Write 1,2,4,8,... 128
           end
      
      // Empty FIFO completely: read back 8 values
      for(i=0;i<fifo_depth;i=i+1)
            begin
               rd_data();
            end
            
      #40 $finish;                   // End simulation
end


// Waveform dump for GTKWave or other viewers


initial begin
    $dumpfile("SYNC_FIFO.vcd");       // Create VCD file
    $dumpvars;                        // Dump all variables
end

endmodule