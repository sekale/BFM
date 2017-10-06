`include "apbTasks.sv"
`include "definesPkg.sv"
import definesPkg::* ;				// Wildcard Import

`timescale 1ns/10ps

module apb_slave
#(
  addrWidth = 32,
  dataWidth = 32
)
(
  input                        clk,
  input                        rst_n,
  input        [addrWidth-1:0] paddr,
  input                        pwrite,
  input                        psel,
  input                        penable,
  input        [dataWidth-1:0] pwdata,
  output logic [dataWidth-1:0] prdata
);

logic [dataWidth-1:0] mem [256];

logic [1:0] apb_st;
const logic [1:0] SETUP = 0;
const logic [1:0] W_ENABLE = 1;
const logic [1:0] R_ENABLE = 2;

// SETUP -> ENABLE
always @(negedge rst_n or posedge clk) begin
  if (rst_n == 0) begin
    apb_st <= 0;
    prdata <= 0;
  end

  else begin
    case (apb_st)
      SETUP : begin
        // clear the prdata
        prdata <= 0;

        // Move to ENABLE when the psel is asserted
        if (psel && !penable) begin
          if (pwrite) begin
            apb_st <= W_ENABLE;
          end

          else begin
            apb_st <= R_ENABLE;
          end
        end
      end

      W_ENABLE : begin
        // write pwdata to memory
        if (psel && penable && pwrite) begin
          mem[paddr] <= pwdata;
        end

        // return to SETUP
        apb_st <= SETUP;
      end

      R_ENABLE : begin
        // read prdata from memory
        if (psel && penable && !pwrite) begin
          prdata <= mem[paddr];
        end

        // return to SETUP
        apb_st <= SETUP;
      end
    endcase
  end
end 
endmodule


module test;

	logic pclk;
	logic [7:0] addr;
	logic [31:0] data, rData;
	logic [31:0] idleCycles;
	logic rstN;

	apb_if apbBus(.apbClk(pclk), .rst(rstN));

	apb_slave   DUT( .clk(pclk),
  					.rst_n(rstN),
  					.paddr(apbBus.PADDR),
  					.pwrite(apbBus.PWRITE),
  					.psel(apbBus.PSEL),
  					.penable(apbBus.PENABLE),
  					.pwdata(apbBus.PWDATA),
  					.prdata(apbBus.PRDATA)
				);

	//typedef virtual apb_if #(32, 32).tb apbTb;
	//apbTb apbMaster;
	//apbMaster = apbTb(apb_t);
	//apbMaster = apb_t;
	//typedef virtual amba3_apb_if #(32, 32).apbtrans apbMaster;
	//apbMaster = apb_if_inst;

	//generate clock
	initial
	begin
		pclk = 1'b0;
		forever pclk = #(10 / 2) ~pclk;
	end

	//generate reset
	initial
	begin
		rstN = 1'b1;
		repeat (5) @(posedge pclk);
		rstN = 1'b0;
		repeat (5) @(posedge pclk);
		rstN = 1'b1;
	end

	initial 	
	begin
		//initialize the APB bus for transactions
		apbBus.initialize();
		apbBus.idleTicks(100);

		addr = 'h32;
		data = 'h16;
		//call tasks to write first and then read from the DUT
		apbBus.writeData(2, 16);
		repeat(5) @(posedge pclk);
		apbBus.readData(2, rData);
		repeat(5) @(posedge pclk);
		apbBus.writeData(4, 32);
		repeat(5) @(posedge pclk);
		apbBus.readData(4, rData);
		repeat(5) @(posedge pclk);
		apbBus.writeData(8, 16);
		repeat(5) @(posedge pclk);
		apbBus.readData(8, rData);

		assert(data == rData) $display("\nWrite then read test passed");

	end
endmodule