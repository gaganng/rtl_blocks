module full_adder (
    input a,
    input b,
    input cin,
    output logic sum,
    output logic cout
);

    assign sum = a ^ b ^ cin;
    assign cout = a&(b^cin) | b&cin;

endmodule