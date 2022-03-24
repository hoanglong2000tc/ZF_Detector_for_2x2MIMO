module tb_ZF;
// Input testcase spec:
    parameter BID_WIDTH = 32;
    parameter TEST_NUM = 1000;






//////////////////////////////////////////////////////////////////////
    parameter H_width = BID_WIDTH*16;
    parameter y_width = BID_WIDTH*8;
    parameter link_to_H_binary  = "C:/Users/ROG STRIX/Desktop/projecy/memfile/H_binary.txt";
    parameter link_to_y_binary  = "C:/Users/ROG STRIX/Desktop/projecy/memfile/y_binary.txt";
    parameter link_to_n_binary  = "C:/Users/ROG STRIX/Desktop/projecy/memfile/n_binary.txt";
    parameter link_to_x_binary_hardware  = "C:/Users/ROG STRIX/Desktop/projecy/memfile/x_binary_hardware.txt";

    reg enable, clk, reset_n, accept_in;
    wire accept_out, ready_out;

    reg [H_width-1:0] H_matrix;
    reg [y_width-1:0] y, n;
    wire [y_width-1:0] X;

    ZF uut(
        enable, clk, reset_n, accept_in, accept_out, ready_out, H_matrix, y, n, X
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        reset_n = 0; @(negedge clk);
        reset_n = 1;
    end
    initial begin
        enable = 0; @(posedge clk);
        enable = 1;
        accept_in = 1;
    end

    reg [H_width-1:0] H_matrix_data [0:TEST_NUM - 1];
    reg [y_width-1:0] y_data [0:TEST_NUM - 1];
    reg [y_width-1:0] n_data [0:TEST_NUM - 1];
    reg [y_width-1:0] x_data [0:TEST_NUM - 1];
    initial $readmemb(link_to_H_binary, H_matrix_data);
    initial $readmemb(link_to_y_binary, y_data);
    initial $readmemb(link_to_n_binary, n_data);

    integer  i = 0, j = 0;
    always @(accept_out, ready_out) begin
        if(accept_out) begin
            H_matrix = H_matrix_data[i];
            y = y_data[i];
            n = n_data[i];
            i = i + 1;
        end
        if (ready_out) begin
            x_data[j] = X;
            j = j+1;
        end
        if(j == TEST_NUM) begin
            $writememb(link_to_x_binary_hardware, x_data);
            $stop;
        end
    end

endmodule

