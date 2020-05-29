// Copyright (c) 2012,20 MiSTer-X 

module PKWARS_ROMS
(
	input					CLKx2,
	input					CLK,
	input					VCLK,

	output reg	[1:0]	PHASE,

	input	     [13:0]	BGCAD,
	output reg [31:0]	BGCDT,

	input	     [13:0]	SPCAD,
	output reg [31:0]	SPCDT,

	input		   [4:0]	PALAD,
	output		[7:0]	PALDT,

	input	     [15:0]	CPUAD,
	output      [7:0]	CPUDT,
	

	input					ROMCL,	// Downloaded ROM image
	input      [16:0]	ROMAD,
	input       [7:0]	ROMDT,
	input					ROMEN
);
wire        CRE = ~ROMAD[16];
wire [15:0] WAD = {ROMAD[15:14],ROMAD[12:0],ROMAD[13]};

`define EN_CHR0	(CRE & (WAD[1:0]==2'h0))
`define EN_CHR1	(CRE & (WAD[1:0]==2'h1))
`define EN_CHR2	(CRE & (WAD[1:0]==2'h2))
`define EN_CHR3	(CRE & (WAD[1:0]==2'h3))

`define EN_PRG0	(ROMAD[16:15]==2'b10  ) 					// $10000-$17FFF
`define EN_PRG1	(ROMAD[16:13]==4'b1100)						// $18000-$19FFF
`define EN_PALT	(ROMAD[16: 5]==12'b1_1010_0000_000)		// $1A000-$1A020


always @( negedge CLK ) PHASE <= PHASE+1;

reg sd;

wire [31:0] DT;
wire [13:0] AD = sd ? SPCAD : BGCAD;

DLROM #(14,8) CHR0(CLKx2,AD,DT[ 7: 0],ROMCL,WAD[15:2],ROMDT,ROMEN & `EN_CHR0);
DLROM #(14,8) CHR1(CLKx2,AD,DT[15: 8],ROMCL,WAD[15:2],ROMDT,ROMEN & `EN_CHR1);
DLROM #(14,8) CHR2(CLKx2,AD,DT[23:16],ROMCL,WAD[15:2],ROMDT,ROMEN & `EN_CHR2);
DLROM #(14,8) CHR3(CLKx2,AD,DT[31:24],ROMCL,WAD[15:2],ROMDT,ROMEN & `EN_CHR3);

always @( negedge CLKx2 ) begin
	if (sd) SPCDT <= DT;
	else    BGCDT <= DT;
	sd <= ~sd;
end

DLROM #(5,8) PAL(VCLK,PALAD,PALDT,ROMCL,ROMAD,ROMDT,ROMEN & `EN_PALT);

wire  [7:0] DT0,DT1;
DLROM #(15,8) PRG0(CLKx2,CPUAD,DT0,ROMCL,ROMAD,ROMDT,ROMEN & `EN_PRG0);
DLROM #(13,8) PRG1(CLKx2,CPUAD,DT1,ROMCL,ROMAD,ROMDT,ROMEN & `EN_PRG1);
assign CPUDT = (CPUAD[15:13]==3'b111) ? DT1 : DT0;

endmodule
