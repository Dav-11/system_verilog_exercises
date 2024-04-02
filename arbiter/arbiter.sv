module arbiter #(
    parameter int num_master = 4
) (req,pri,grant,clk);

    input   logic                   clk;
    input   logic [num_master-1:0]  req;
    input   logic [num_master-1:0]  pri;
    output  logic [num_master-1:0]  grant;

    logic [(2*num_master)-1:0]  pri_ext;
    logic [num_master-1:0]      found;
    logic [num_master-1:0]      skip;

    assign pri_ext = {pri,pri};

    always_comb begin
        
        grant   = '0;
        found   = '0;
        skip    = '0; 
    
        // genvar for loop iteration
        genvar i;
        generate
            for (int i = 0; i < num_master; i++) begin
                
                // req1: request exists
                if (request[i]) begin

                    //
                    // req2: No request from blocking
                    //

                    if (pri[i]) begin

                        // this has max priority -> ignore others
                        grant[i] = 1;
                    else
                        
                        // check if any other element has higher prio + req
                        for (int j = (i + 1); j < (num_master+i); j++) begin

                            // if has req and (the max prio elem is between i and j or the max prio elem is j)
                            if(req[i] && (found[i] || pri[j])) begin

                                // found req w/ higher prio => skip i
                                skip[i] = 1;
                                break;
                            end

                            if(pri[j]) begin
                                found[i] = 1;
                            end

                        end

                        if(!skip[i]) begin
                            grant[i] = 1;
                        end
                    end
                end
            end
        endgenerate
    end


