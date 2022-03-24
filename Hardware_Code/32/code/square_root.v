module square_root (
    input clk,
    input reset_n, 
    input start,
    input [31:0] rad,
    output [31:0] root,
    output done
    );

    wire check_test_res;
    wire check_count;
    wire load;
    wire shift1;
    wire shift2;
    wire inc_count;

    square_root_controller           
    square_root_controller_instance(   
        .clk                    (clk                    ),
        .reset_n                (reset_n                ),
        .start                  (start               ),
        .check_test_res   (check_test_res     ),
        .check_count     (check_count      ),
        .done           (done ),
        .load     (load     ),
        .shift1      (shift1      ),
        .shift2      (shift2      ),
        .inc_count    (inc_count      )
    );

    square_root_datapath           
    square_root_datapath_instance(   
        .clk                    (clk                    ),
        .reset_n                (reset_n                ),
        .rad                (rad               ),
        .check_test_res   (check_test_res     ),
        .check_count     (check_count      ),
        .load     (load     ),
        .shift1      (shift1      ),
        .shift2      (shift2      ),
        .inc_count    (inc_count      ),
        .root (root)
    );




endmodule

//-----------------------------------------------
module square_root_controller (
    input clk, 
    input reset_n,
    input start, 
    input check_test_res, check_count,
    output reg done,
    output reg load, shift1, shift2, inc_count 
    );

    localparam IDLE     = 0;
    localparam COMPUTE  = 1;
    localparam END    = 2;

    reg [1:0] current_state, next_state;


    always @ (*) begin
        load        = 0;
        shift1      = 0; 
        shift2      = 0;
        inc_count   = 0;
        done        = 0;
        case(current_state)
        IDLE: begin
            if (start) begin
                load        = 1;
                next_state  = COMPUTE;
            end else begin
                next_state  = IDLE;
            end
        end

        COMPUTE: begin
            if (check_test_res) shift1 = 1;
            else shift2 = 1;
            inc_count = 1;
            next_state = check_count ? END : COMPUTE;
        end

        END: begin
            done        = 1;
            next_state  = IDLE;
        end

        default: begin 
                next_state = IDLE;
        end
        endcase
    end


    always @(posedge clk or negedge reset_n)
    begin
        if (!reset_n)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end
endmodule


//-----------------------------------------------
module square_root_datapath (
    input clk, 
    input reset_n,
    input [31:0] rad,
    input load, shift1, shift2, inc_count,
    output check_test_res, check_count,
    output [31:0] root
    );

    reg [31:0] x;
    reg [31:0] q;
    reg [33:0] ac;
    reg [4:0] count;

    wire [33:0] test_res;


    assign test_res = ac - {q, 2'b01};
    assign check_test_res = (test_res[33] == 0);
    assign check_count = (count == 27);
    assign root = q;

    always @ (posedge clk, negedge reset_n)
    begin
        if (~reset_n) begin
            x <= 0;
            q <= 0; 
            ac <= 0;
            count <= 0;
        end 
        else begin
                if(load) begin
                    {ac, x} <= {{32{1'b0}}, rad, 2'b0};
                    count <= 0;
                    q <= 0;
                end 
                if(shift1) begin
                    {ac, x} <= {test_res[31:0], x, 2'b0};
                    q <= {q[30:0], 1'b1};
                end 
                if(shift2) begin
                    {ac, x} <= {ac[31:0], x, 2'b0};
                    q <= q << 1;
                end 
                if (inc_count) begin
                    count <= count + 1;
                end 
        end
    end  
endmodule