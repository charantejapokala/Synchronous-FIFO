



//////////////////////////////////////////////////////////////////////////////////
// Create Date: 10/30/2025 03:49:47 PM
// Module Name: SYNC_FIFO
// Project Name: Synchronous FIFO
//////////////////////////////////////////////////////////////////////////////////









module SYNC_FIFO #(parameter fifo_depth = 8, parameter data_width = 32)
   (input  clk,                             // clock input for synchronous operations
    input  rst,                             // active-low reset to initialize pointers
    input  cs,                              // chip select enables FIFO operations
    input  wr_en,                           // write enable signal
    input  rd_en,                           // read enable signal
    input  [data_width - 1:0] d_in,         // data input to be stored into FIFO
    output reg [data_width-1:0] d_out,      // data output from FIFO
    output full,                            // flag indicating FIFO is full
    output empty);                          // flag indicating FIFO is empty
    



  localparam fifo_depth_log = $clog2(fifo_depth);   // taking fifo depth in decimal value using log function to represent no. of bits required to represent 8
  



  // declare a by-decimal array to store the data
  reg [data_width - 1:0] fifo[0:fifo_depth - 1];     // FIFO memory: fifo_depth entries, each of width data_width
  



  // wr/rd pointer have 1 extra bits at MSB

  reg [fifo_depth:0] wr_pointer;   // extra MSB used to detect wrap-around during write

  reg [fifo_depth:0] rd_pointer;   // extra MSB used to detect wrap-around during read
  




  // write block

  always @(posedge clk or negedge rst)
  begin
  if(!rst)
       begin
          wr_pointer <= 0;                    // on reset, write pointer resets to 0
       end
  else if(cs && wr_en && !full)
       begin
          // write data into FIFO memory at the index defined by lower bits of pointer
          fifo[wr_pointer[fifo_depth_log-1:0]] <= d_in;
          
          // increment pointer, including MSB, so wrapping is tracked
          wr_pointer <= wr_pointer + 1'b1;
       end
  end
  






  // read block

  always @(posedge clk or negedge rst)
  begin
  if(!rst)
       begin
          rd_pointer <= 0;                    // on reset, read pointer resets to 0
       end
  else if(cs && rd_en && !empty)
       begin
          // read data from FIFO at address pointed by lower pointer bits
          d_out <= fifo[rd_pointer[fifo_depth_log-1:0]];
          
          // increment pointer to move to next stored data
          rd_pointer <= rd_pointer + 1'b1;
       end
  end
  



  // Declare the empty and full logic
  
  assign empty = (wr_pointer == rd_pointer);        // Empty when both pointers are equal → No unread data present



  assign full = (rd_pointer == {~wr_pointer[fifo_depth_log], wr_pointer[fifo_depth_log-1:0]});
  /* 
     Full when:
     - Lower bits of write and read pointer match (same index)
     - MSB differs (write pointer has wrapped around once more than read pointer)

     This ensures FIFO does not overwrite unread data.
  */

endmodule
