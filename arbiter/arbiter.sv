module arbiter #(
    parameter int num_master = 4
) (
    req,
    pri,
    grant,
    clk,
    rst
);

    input   logic                   clk;
    input   logic                   rst;
    input   logic [num_master-1:0]  req;
    input   logic [num_master-1:0]  pri;
    output  logic [num_master-1:0]  grant;

    logic [(2*num_master)-1:0]  pri_ext;
    logic [num_master-1:0]      found;
    logic [num_master-1:0]      skip;

    assign pri_ext = {pri,pri};
    
    // genvar for loop iteration
    genvar i;
    generate
        for (i = 0; i < num_master; i++) begin
        
            always_comb begin
                
                found[i]   = 0;
                skip[i]    = 0;
                
                // req1: request exists
                if (req[i]) begin

                    //
                    // req2: No request from blocking
                    //

                    // if i has max prio => leave skip to 0

                    // else
                    if (!pri[i]) begin
                        
                        // check if any other element has higher prio + req
                        for (int j = (i + 1); j < (num_master+i); j++) begin

                            if(!skip[i]) begin

                                // if has req and (the max prio elem is between i and j or the max prio elem is j)
                                if(req[i] && (found[i] || pri_ext[j])) begin

                                    // found req w/ higher prio => skip i
                                    skip[i] = 1;
                                end

                                if(pri_ext[j]) begin
                                    found[i] = 1;
                                end

                            end

                        end
                    end
                end
            end
            
            always_ff@(posedge clk) begin
                if(rst) begin
                    grant   <= '0;
                    found   <= '0;
                    skip    <= '0;
                    
                end else begin

                    if (req[i]) begin

                        if(!skip[i]) begin
                            grant[i] <= 1;
                        end else begin
                            grant[i] <= 0;
                        end
                    end else begin
                        grant[i] <= 0;
                    end
                end
            end
        end
    endgenerate

endmodule

