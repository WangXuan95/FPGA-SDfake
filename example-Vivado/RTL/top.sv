// uncomment this to enable UART debug info
//`define DEBUG_INFO

// A SD-card simulator example for Digilent Arty7 Board (Xilinx Artix7)
module top (
    // active-low, to reset the fake SD-card 
    // on Arty7, it is the red reset button
    input  logic        rst_n,
    
    // these are Fake SD-card signals, connect them to a SD-host, such as a SDcard Reader
    // on Arty7, it is on PMOD JD
    input               sdclk,
    inout               sdcmd,
    output logic [3:0]  sddat,
    
    // clk 50MHz for UART driver (Optional)
    input  logic        CLK100MHZ,
    
    // uart interface, print debug information (Optional)
    output logic        uart_tx,

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
        .UART_CLK_DIV ( 868        ), // 100MHz / 868 = 115200Hz
        .DATA_WIDTH   ( 40         ),
        .FIFO_ASIZE   ( 9          )
    ) uarttx_saxis_async_i (
        .rst_n        ( rst_n      ),
        
        .aclk         ( dbg_clk    ),
        .tvalid       ( dbg_wen    ),
        .tready       (            ),
        .tdata        ( dbg_wdata  ),
        
        .uart_clk     ( CLK100MHZ  ),
        .uart_tx      ( uart_tx    )
    );
`else
    assign uart_tx = 1'b1;
`endif

endmodule
