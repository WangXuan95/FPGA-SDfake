// uncomment this to enable UART debug info
//`define DEBUG_INFO

module top (
    // active-low, to reset the fake SD-card
    input  logic        rst_n,
    // these are Fake SD-card signals, connect them to a SD-host, such as a SDcard Reader
    input               sdclk,
    inout               sdcmd,
    inout  [3:0]        sddat,
`ifdef DEBUG_INFO
    // clk 50MHz for UART driver (Optional)
    input  logic        clk50m,
    // uart interface, print debug information (Optional)
    output logic        uart_tx,
`endif
    // display SD card status on LED
    output logic [7:0]  led
);

logic        rdclk;
logic        rdreq;
logic [39:0] rdaddr;
logic [15:0] rddata;

`ifdef DEBUG_INFO
logic        dbg_clk;
logic        dbg_wen;
logic [39:0] dbg_wdata;
`endif

// ---------------------------------------------------------------------------------------------
//    Fake SDcard Controller
// ---------------------------------------------------------------------------------------------
SDFake sd_fake_inst(
    .rst_n       ( rst_n      ),
    
    .sdclk       ( sdclk      ),
    .sdcmd       ( sdcmd      ),
    .sddat       ( sddat      ),
    
    .rdclk       ( rdclk      ),
    .rdreq       ( rdreq      ),
    .rdaddr      ( rdaddr     ),
    .rddata      ( rddata     ),
    
`ifdef DEBUG_INFO
    .dbg_clk     ( dbg_clk    ),
    .dbg_wen     ( dbg_wen    ),
    .dbg_wdata   ( dbg_wdata  ),
`endif

    .status_led  ( led        )  // show Fake SDcard status on LED
);


// ---------------------------------------------------------------------------------------------
//     A rom implemented by FPGA BRAM which provide a simple FAT32 SDcard content
// ---------------------------------------------------------------------------------------------
SDContent sd_content_i(
    .rdclk       ( rdclk      ),
    .rdreq       ( rdreq      ),
    .rdaddr      ( rdaddr     ),
    .rddata      ( rddata     )
);


`ifdef DEBUG_INFO
    // ---------------------------------------------------------------------------------------------
    //    send debug info to UART (Optional)
    // ---------------------------------------------------------------------------------------------
    uarttx_saxis_async #(
        .UART_CLK_DIV ( 434        ),
        .DATA_WIDTH   ( 40         ),
        .FIFO_ASIZE   ( 9          )
    ) uarttx_saxis_async_i (
        .rst_n        ( rst_n      ),
        
        .aclk         ( dbg_clk    ),
        .tvalid       ( dbg_wen    ),
        .tready       (            ),
        .tdata        ( dbg_wdata  ),
        
        .uart_clk     ( clk50m     ),
        .uart_tx      ( uart_tx    )
    );
`endif

endmodule
