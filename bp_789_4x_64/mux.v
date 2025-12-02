
module mux(
    input A,
    input B,
    input sel,
    output out
    );
    
    assign out = sel ? (B) : A;
    
endmodule
