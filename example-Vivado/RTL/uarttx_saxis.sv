module uarttx_saxis_async #(
    parameter UART_CLK_DIV  = 434,
    parameter DATA_WIDTH    = 64,
    parameter FIFO_ASIZE    = 8
)  (
    input  logic                  rst_n,
    
    input  logic                  aclk,
    input  logic                  tvalid,
    output logic                  tready,
    input  logic [DATA_WIDTH-1:0] tdata,
    
    input  logic                  uart_clk,
    output logic                  uart_tx
);

logic        uart_tvalid;
logic        uart_tready;
logic [39:0] uart_tdata;

stream_async_fifo #(   // tx async fifo
    .DSIZE        ( DATA_WIDTH   ),
    .ASIZE        ( FIFO_ASIZE   )
) tx_async_fifo_i (
    .rst_n        ( rst_n        ),
    
    .iclk         ( aclk         ),
    .itvalid      ( tvalid       ),
    .itready      ( tready       ),
    .itdata       ( tdata        ),

    .oclk         ( uart_clk     ),
    .otvalid      ( uart_tvalid  ),
    .otready      ( uart_tready  ),
    .otdata       ( uart_tdata   )
);

uarttx_saxis #(   // AXI-stream sink to UART-TX
    .CLK_DIV      ( UART_CLK_DIV ),
    .DATA_WIDTH   ( DATA_WIDTH   ),
    .FIFO_ASIZE   ( FIFO_ASIZE   )
) uarttx_saxis_i (
    .aresetn      ( rst_n        ),
    .aclk         ( uart_clk     ),
    
    .tvalid       ( uart_tvalid  ),
    .tlast        ( 1'b1         ),
    .tready       ( uart_tready  ),
    .tdata        ( uart_tdata   ),
    
    .uart_tx      ( uart_tx      )
);

endmodule








module uarttx_saxis #(
    parameter CLK_DIV    = 434,
    parameter DATA_WIDTH = 64,
    parameter FIFO_ASIZE = 8
) (
    // AXI-stream (slave) side
    input  logic aclk, aresetn,
    input  logic tvalid, tlast,
    output logic tready,
    input  logic [DATA_WIDTH-1:0] tdata,
    // UART TX signal
    output logic uart_tx
);
localparam TX_WIDTH = (DATA_WIDTH+3) / 4;

function automatic logic [7:0] hex2ascii(input [3:0] hex);
    return (hex<4'hA) ? (hex+"0") : (hex+("A"-8'hA)) ;
endfunction

initial uart_tx = 1'b1;

logic [FIFO_ASIZE-1:0] fifo_rpt='0, fifo_wpt='0;
wire  [FIFO_ASIZE-1:0] fifo_wpt_next = fifo_wpt+1;
logic [31:0] cyccnt=0, hexcnt=0, txcnt=0;
logic [ 7:0] txshift = '1;
logic fifo_tlast;
logic [DATA_WIDTH-1:0] fifo_data;
logic endofline = 1'b0;
logic [TX_WIDTH*4-1:0] data='0;
wire  emptyn = (fifo_rpt != fifo_wpt);
assign  tready = (fifo_rpt != fifo_wpt_next) & aresetn;

always @ (posedge aclk or negedge aresetn)
    if(~aresetn)
        fifo_wpt = '0;
    else begin
        if(tvalid & tready) fifo_wpt++;
    end

always @ (posedge aclk or negedge aresetn)
    if(~aresetn)
        cyccnt <= 0;
    else
        cyccnt <= (cyccnt<CLK_DIV-1) ? cyccnt+1 : 0;

always @ (posedge aclk or negedge aresetn)
    if(~aresetn) begin
        fifo_rpt   = '0;
        endofline <= 1'b0;
        data      <= '0;
        uart_tx   <= 1'b1;
        txshift   <= '1;
        txcnt      = 0;
        hexcnt     = 0;
    end else begin
        if( hexcnt>(1+TX_WIDTH) ) begin
            uart_tx   <= 1'b1;
            endofline <= fifo_tlast;
            data                 <= '0;
            data[DATA_WIDTH-1:0] <= fifo_data;
            hexcnt--;
        end else if(hexcnt>0 || txcnt>0) begin
            if(cyccnt==CLK_DIV-1) begin
                if(txcnt>0) begin
                    {txshift, uart_tx} <= {1'b1, txshift};
                    txcnt--;
                end else begin
                    uart_tx <= 1'b0;
                    hexcnt--;
                    if(hexcnt>0)
                        txshift <= hex2ascii(data[(hexcnt-1)*4+:4]);
                    else if(endofline)
                        txshift <= "\n";
                    else
                        txshift <=  " ";
                    txcnt = 11;
                end
            end
        end else if(emptyn) begin
            uart_tx <= 1'b1;
            hexcnt = 2 + TX_WIDTH;
            txcnt  = 0;
            fifo_rpt++;
        end
    end

ram_for_uart_tx #(
    .ADDR_LEN  ( FIFO_ASIZE             ),
    .DATA_LEN  ( DATA_WIDTH + 1         )
) ram_for_uart_tx_fifo_inst(
    .clk       ( aclk                   ),
    .wr_req    ( tvalid & tready        ),
    .wr_addr   ( fifo_wpt               ),
    .wr_data   ( {tlast, tdata}         ),
    .rd_addr   ( fifo_rpt               ),
    .rd_data   ( {fifo_tlast,fifo_data} )
);

endmodule






module ram_for_uart_tx #(
    parameter ADDR_LEN = 12,
    parameter DATA_LEN = 8
) (
    input  logic clk,
    input  logic wr_req,
    input  logic [ADDR_LEN-1:0] rd_addr, wr_addr,
    output logic [DATA_LEN-1:0] rd_data,
    input  logic [DATA_LEN-1:0] wr_data
);

localparam  RAM_SIZE = (1<<ADDR_LEN);

logic [DATA_LEN-1:0] ram [RAM_SIZE];

initial rd_data = 0;

always @ (posedge clk)
    rd_data <= ram[rd_addr];

always @ (posedge clk)
    if(wr_req)
        ram[wr_addr] <= wr_data;

endmodule




module stream_async_fifo #(
    parameter DSIZE = 1,
    parameter ASIZE = 7
)(
    input  logic               rst_n,
    
    input  logic               iclk,
    input  logic               itvalid,
    output logic               itready,
    input  logic [DSIZE*8-1:0] itdata,
    
    input  logic               oclk,
    input  logic               otready, 
    output logic               otvalid,
    output logic [DSIZE*8-1:0] otdata
);

initial itready = 1'b0;

logic               rreq;
logic               remptyn = 1'b0;
logic [DSIZE*8-1:0] rdata;

logic [ASIZE:0] rbin=0, rptr=0, wbin=0, wptr=0, rq1_wptr=0, rq2_wptr=0, wq1_rptr=0, wq2_rptr=0;

// Synchronizing the read pointer from read to write clock domain
always @(posedge iclk or negedge rst_n)
    if (~rst_n)
        {wq2_rptr,wq1_rptr} <= 0;
    else
        {wq2_rptr,wq1_rptr} <= {wq1_rptr, rptr};
            
// Handling the write requests
always @(posedge iclk or negedge rst_n)
    if(~rst_n) begin
        wbin = 0;
        wptr = 0;
        itready= 1'b0;
    end else begin
        if(itvalid &  itready) wbin++;
        wptr    = (wbin >> 1) ^ wbin;
        itready = (wptr != {~wq2_rptr[ASIZE:ASIZE-1],wq2_rptr[ASIZE-2:0]});
    end

// Synchronizing the write pointer from write to read clock domain
always @(posedge oclk or negedge rst_n)
    if (~rst_n) 
        {rq2_wptr,rq1_wptr} <= 0;
    else
        {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
    
always @(posedge oclk or negedge rst_n)
    if (~rst_n) begin
        rbin = 0;
        rptr = 0;
        remptyn = 1'b0;
    end else begin
        if(rreq & remptyn) rbin++;
        rptr = (rbin >> 1) ^ rbin;
        remptyn = (rptr != rq2_wptr);
    end

async_ram #(
    .DSIZE  ( DSIZE              ),
    .ASIZE  ( ASIZE              )
) ram_a_i (
    .wclk   ( iclk               ),
    .wen    ( itvalid &  itready ),
    .waddr  ( wbin[ASIZE-1:0]    ),
    .wdata  ( itdata             ),
    .rclk   ( oclk               ),
    .raddr  ( rbin[ASIZE-1:0]    ),
    .rdata  ( rdata              )
);

fifo2axis #(
    .DSIZE        ( DSIZE        )
) afifo2axis_i (
    .rst_n        ( rst_n        ),
    .clk          ( oclk         ),
    
    .i_req        ( rreq         ),
    .i_emptyn     ( remptyn      ),
    .i_data       ( rdata        ),
    
    .o_req        ( otready      ),
    .o_emptyn     ( otvalid      ),
    .o_data       ( otdata       )
);

endmodule








module fifo2axis #(
    parameter DSIZE = 1
) (
    input  logic               clk, rst_n,
    output logic               i_req,
    input  logic               i_emptyn,
    input  logic [DSIZE*8-1:0] i_data,
    input  logic               o_req,
    output logic               o_emptyn,
    output logic [DSIZE*8-1:0] o_data
);

logic dvalid=1'b0, valid=1'b0;
logic [DSIZE*8-1:0] datareg='0;

assign o_emptyn = (valid | dvalid);
assign i_req    = rst_n & i_emptyn & ( o_req | ~o_emptyn );
assign o_data   = dvalid ? i_data : datareg;

always @ (posedge clk)
    if(~rst_n) begin
        dvalid <= 1'b0;
        valid  <= 1'b0;
    end else begin
        dvalid <= i_req;
        if(dvalid)
            datareg <= i_data;
        if(o_req)
            valid <= 1'b0;
        else if(dvalid)
            valid <= 1'b1;
    end

endmodule







module async_ram #(
    parameter  DSIZE = 1,    // Memory data word width (in bytes)
    parameter  ASIZE = 4     // Number of mem address bits
)(
    input  logic               wclk,
    input  logic               wen,
    input  logic [ASIZE  -1:0] waddr,
    input  logic [DSIZE*8-1:0] wdata,
    input  logic               rclk,
    input  logic [ASIZE  -1:0] raddr,
    output logic [DSIZE*8-1:0] rdata
);
    
localparam DEPTH = 1<<ASIZE;
    
reg [DSIZE*8-1:0] mem [0:DEPTH-1];

initial rdata = '0;

always @(posedge rclk)
    rdata <= mem[raddr];

always @(posedge wclk)
    if (wen) 
        mem[waddr] <= wdata;

endmodule
