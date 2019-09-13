
// this demo runs on Terasic DE0-Nano Board (Altera Cyclone IV)
module top (
    // active-low, to reset the fake SD-card
    // On DE0-Nano, it is KEY0
    input  logic        rst_n,
    
    // these are Fake SD-card signals, connect them to a SD-host, such as a SDcard Reader
    // On DE0-Nano, it is GPIO0
    input               sdclk,
    inout               sdcmd,
    output logic [3:0]  sddat,

    // display SD card status on LED
    output logic [7:0]  led
);

logic        rdclk;
logic        rdreq;
logic [39:0] rdaddr;
logic [15:0] rddata;

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

endmodule
