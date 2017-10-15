module ram_memory(
  input clk,
  input [11:0] addr,
  input [7:0] data_in,
  input we,
  output reg [7:0] data_out
);

  reg [7:0] store[0:4095] /* verilator public_flat */;

  initial
  begin
	$readmemh("boot.mem", store);
	store[0] <= 8'b00010000; // CLR R0
	store[1] <= 8'b00011000; // INC R0
	store[2] <= 8'b00000100; // MOV R1,R0
	store[3] <= 8'b00001001; // MOV R2,R1
	//store[4] <= 8'b10000000; // JMP 0x001
	//store[5] <= 8'b00000001; //
	//store[6] <= 8'b01111111; // HLT

	store[4] <= 8'b01111000; // CLR SEG
	store[5] <= 8'b01010001; // LOAD R0,[R1]
	store[6] <= 8'b00011010; // INC R2
	store[7] <= 8'b01100010; // STORE [R0],R2
	store[8] <= 8'b01010100; // LOAD R1,[R0]
	store[9] <= 8'b11111101; // OUT 0
	store[10] <= 8'b00000000; // 
	store[11] <= 8'b01111111; // HLT
  end

  always @(posedge clk)
	if (we)
	  store[addr[11:0]] <= data_in;
	else
	  data_out <= store[addr[11:0]];
endmodule
