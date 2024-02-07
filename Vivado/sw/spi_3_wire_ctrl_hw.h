#ifndef SPI_3_WIRE_CTRL_HW
#define SPI_3_WIRE_CTRL_HW

// Register offsets:
#define SPI_CTRL_REG_OFFSET 0
#define SPI_COMMAND_REG_OFFSET 4
#define SPI_RXDATA_REG_OFFSET 8
#define SPI_TXDATA_REG_OFFSET 12
#define SPI_ADDR_REG_OFFSET 16
#define SPI_CLKDIV_REG_OFFSET 20

// Register indexes:
#define SPI_CTRL_REG_INDEX    	0
#define SPI_COMMAND_REG_INDEX  	1
#define SPI_RXDATA_REG_INDEX    2
#define SPI_TXDATA_REG_INDEX    3
#define SPI_ADDR_REG_INDEX      4
#define SPI_CLKDIV_REG_INDEX    5

// Register bit mask:
#define SPI_CTRL_RST      		0x01
#define SPI_CTRL_ENABLE  		0x02
#define SPI_CTRL_BUSY    		0x04
#define SPI_CTRL_CPOL   		0x08
#define SPI_CTRL_CPHA   		0x10

#define SPI_COMMAND_RnW           0x8000
#define SPI_COMMAND_W1            0x4000
#define SPI_COMMAND_W0            0x2000

#endif // SPI_3_WIRE_CTRL_HW
