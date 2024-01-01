//
// N - Stages Carry Select Adder
// Theory - https://en.wikipedia.org/wiki/Carry-select_adder#Uniform-sized_adder
//

`include "full_adder.sv"

module carry_select_adder
#(parameter 
    DATA_WIDTH = 24
) (
    input [DATA_WIDTH - 1:0] a,
    input [DATA_WIDTH - 1:0] b,
    output logic [DATA_WIDTH:0] result
);

    localparam NUM_BITS         = DATA_WIDTH ;
    localparam NUM_STAGES       = 8;                              // Should be a factor of NUM_BITS
    localparam NUM_FA_PER_STAGE = NUM_BITS/NUM_STAGES;

    reg [NUM_BITS-1:0] carrys_c0, carrys_c1;
    reg [NUM_BITS-1:0] sums_c0, sums_c1, sums;
    reg [NUM_STAGES-1:0] stage_carrys;
    wire carry_out;

    // Instantiate Adders
    genvar i;
    generate
        for (i=0;i<NUM_BITS;i=i+1) begin
            if (i<NUM_FA_PER_STAGE) begin
                if (i==0)
                    full_adder inst_0(a[i], b[i],           1'b0, sums_c0[i], carrys_c0[i]);
                else
                    full_adder inst_0(a[i], b[i], carrys_c0[i-1], sums_c0[i], carrys_c0[i]);
            end
            else if (i%NUM_FA_PER_STAGE == 0) begin
                full_adder inst_0(a[i], b[i], 1'b0, sums_c0[i], carrys_c0[i]); //Cin=0
                full_adder inst_1(a[i], b[i], 1'b1, sums_c1[i], carrys_c1[i]); //Cin=1
            end
            else begin
                full_adder inst_0(a[i], b[i], carrys_c0[i-1], sums_c0[i], carrys_c0[i]); //Cin=0
                full_adder inst_1(a[i], b[i], carrys_c1[i-1], sums_c1[i], carrys_c1[i]); //Cin=1
            end
        end
    endgenerate

    // Muxes - Select sum and carrys
    always @(*) begin
        for (int k=0;k<NUM_BITS;k=k+NUM_FA_PER_STAGE) begin
            if (k==0) begin
                stage_carrys[0] = carrys_c0[NUM_FA_PER_STAGE-1];
            end
            else begin
                stage_carrys[k/NUM_FA_PER_STAGE] = stage_carrys[k/NUM_FA_PER_STAGE - 1] ? carrys_c1[k+NUM_FA_PER_STAGE-1] : carrys_c0[k+NUM_FA_PER_STAGE-1];
            end
            
            for (int l=0;l<NUM_FA_PER_STAGE;l++) begin
                if (k==0) begin
                    sums[k+l] = sums_c0[k+l];
                end
                else begin
                    sums[k+l] = stage_carrys[(k/NUM_FA_PER_STAGE)-1] ? sums_c1[k+l] : sums_c0[k+l];
                end
            end
        end
    end

    assign carry_out = stage_carrys[NUM_STAGES - 1] ? carrys_c1[NUM_BITS-1] : carrys_c0[NUM_BITS-1];
    assign result = {carry_out, sums};

endmodule