

module FIR_pipeline2 #(
    parameter   WIDTH_data =  24                      ,
                WIDTH_data_out = 48                   ,
                WIDTH_coeff = 16                      ,
                WIDTH_reg =   WIDTH_data + WIDTH_coeff,
                TAP =         16
) 
    (
    input logic                           clk,
    input logic                           reset_n,
    input logic signed [WIDTH_data-1:0]   data_in,
    output logic signed [WIDTH_data-1:0]  data_out
); 

// Araays --- 31 taps

logic signed [WIDTH_reg-1:0] delay      [TAP-1:0]; // array for data_in delay
logic signed [WIDTH_reg-1:0] pipeline   [TAP-1:0]; // array for data_in delay
logic signed [WIDTH_reg-1:0] mul        [TAP-1:0]; // array for result multiply 
logic signed [WIDTH_reg-1:0] add_out    [TAP-1:0]; // array for result addition
logic signed [WIDTH_coeff-1:0] h        [TAP-1:0];

// store coeffs value
initial begin 
    $readmemh ("E:/Lecture/DSPonFPGA/FIR/mem/orrder15_hex.txt", h);
end 

assign delay[0] = 0; // no delay 

genvar i; 
generate 
    for (i=0; i < TAP; i = i + 1) begin: multi_datain_coeff 
            multi mult (
            .a(data_in),
            .b(h[i]),
            .out(mul[i])
        );
        end
        endgenerate 

//
genvar p; 
generate 
    for (p = 0; p < TAP; p = p + 1) begin: pipeline_stage
            my_DFF_40 delay_e (
            .clk(clk),
            .rst_n(reset_n),
            .d_in(mul[p]),
            .q_out(pipeline[p])
        );
        end
        endgenerate 
// 
genvar k;
generate 
    for (k=0; k < TAP; k = k + 1) begin: adder
        assign add_out[k] = pipeline[k] + delay[k];
        end
    endgenerate 

//
genvar j;
generate 
    for (j=0; j < TAP - 1; j = j + 1) begin: delay_ztr1
        my_DFF_40 element (
            .rst_n(reset_n),
            .clk(clk),
            .d_in(add_out[j]),
            .q_out(delay[j+1])
        );
        end
        endgenerate
    // output kenh trai
    // assign data_out = add_out[TAP-1][WIDTH_reg-1:WIDTH_reg-24]; 
		assign data_out = add_out[TAP-1][39:16];

endmodule 