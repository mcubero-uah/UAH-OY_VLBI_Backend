/***************************** Include Files *******************************/
#include "spi_3_wire_ctrl.h"

/************************** Function Definitions ***************************/
/****************************************************************************/
/**
*
* @brief Set serial clock polarity in idle state
*
* @param	cpol is a the desired clock polarity: set 1 for High and 0 for
* 			low.
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_cpol(spi_ctrl_t *drv, int CPOL){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(CPOL==1){
	reg[SPI_CTRL_REG_INDEX] |= SPI_CTRL_CPOL;
	}
	else if (CPOL==0){
	reg[SPI_CTRL_REG_INDEX] &= ~SPI_CTRL_CPOL;
	}
	else;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Get serial clock polarity in idle state
*
*
* @return		Clock polarity value.
*
******************************************************************************/
int spi_ctrl_get_cpol(spi_ctrl_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=((reg[SPI_CTRL_REG_INDEX]&SPI_CTRL_CPOL)>>(3));
	return result;
}

/****************************************************************************/
/**
*
* @brief Set serial clock phase
*
* @param	CPHA is a the desired clock phase
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_cpha(spi_ctrl_t *drv, int CPHA){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(CPHA==1){
	reg[SPI_CTRL_REG_INDEX] |= SPI_CTRL_CPHA;
	}
	else if (CPHA==0){
	reg[SPI_CTRL_REG_INDEX] &= ~SPI_CTRL_CPHA;
	}
	else;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Get serial clock polarity in idle state
*
*
* @return		Clock phase value.
*
******************************************************************************/
int spi_ctrl_get_cpha(spi_ctrl_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=((reg[SPI_CTRL_REG_INDEX]&SPI_CTRL_CPHA)>>(4));
	return result;
}

/****************************************************************************/
/**
*
* @brief Set reset bit
*
* @param	reset_bit. Set it to 1 to reset the core and to 0 to disable the reset
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_rst(spi_ctrl_t *drv, int reset_bit){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(reset_bit==1){
	reg[SPI_CTRL_REG_INDEX] |= SPI_CTRL_RST;
	}
	else if (reset_bit==0){
	reg[SPI_CTRL_REG_INDEX] &= ~SPI_CTRL_RST;
	}
	else;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Get enable bit
*
*
* @return		Enable bit value.
*
******************************************************************************/
int spi_ctrl_get_enable(spi_ctrl_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=((reg[SPI_CTRL_REG_INDEX]&SPI_CTRL_ENABLE)>>(1));
	return result;
}


/****************************************************************************/
/**
*
* @brief Get busy bit
*
*
* @return		Busy bit value (1 if the controller is busy and 0 if not).
*
******************************************************************************/
int spi_ctrl_get_busy(spi_ctrl_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=((reg[SPI_CTRL_REG_INDEX]&SPI_CTRL_BUSY)>>(2));
	return result;
}

/****************************************************************************/
/**
*
* @brief Set the slave address with which the communication will be carried out. Note that
* the controller can be connected to several slaves at the same time
*
* @param	addr. Slave address
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_addr(spi_ctrl_t *drv, int addr){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	reg[SPI_ADDR_REG_INDEX] = addr;
	drv->addr_reg = reg[SPI_ADDR_REG_INDEX];
	return 0;
}

/****************************************************************************/
/**
*
* @brief Set the clock divider factor, taking in account that fsclk=fclk/(2*clk_div)
*
* @param	clk_div. Clock divider factor
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_clk_div(spi_ctrl_t *drv, int clk_div){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	reg[SPI_CLKDIV_REG_INDEX] = clk_div;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Initialize the corresponding Controller Core with the desired base address
* and with default configuration: CPHA=1, CPOL=1, disabled reset.
*
* @param	base_addr. Base address of the corresponding axi_spi_3_wire_ctrl
* peripheral.
*
* @param	addr. Corresponding slave address.
*
* @param	clk_div. Clock divider factor
*
* @return		0.
******************************************************************************/

int spi_ctrl_initialize(spi_ctrl_t *drv, uint32_t base_addr,  int addr, int clk_div){
	drv->base_addr = base_addr;
	spi_ctrl_set_cpol(drv, 1);
	spi_ctrl_set_cpha(drv, 1);
	spi_ctrl_set_addr(drv, addr);
	spi_ctrl_set_rst(drv, 0);
	spi_ctrl_set_clk_div(drv,clk_div);
	return 0;
}

/****************************************************************************/
/**
*
* @brief Set the command to be sent by the SPI controller. Take in account that the command width
* depends on the cmd_width parameter of the corresponding axi_spi_3_wire_ctrl
* peripheral. In case of command widths lower than 32 bits, just the least significant bits
* are written.
*
* @param	command. Command to be sent across the SPI controller
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_set_command(spi_ctrl_t *drv, int command){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	reg[SPI_COMMAND_REG_INDEX] = command;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Do a write access to a SPI controller. Take in account that the data width
* depends on the d_width parameter of the corresponding axi_spi_3_wire_ctrl
* peripheral. In case of data widths lower than 32 bits, just the least significant bits
* are written.
*
* @param	data. Data to be sent across the SPI controller
*
* @param	dwidth. Data width in bits
*
* @return		0.
*
******************************************************************************/
int spi_ctrl_write(spi_ctrl_t *drv, int data, int dwidth){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	reg[SPI_TXDATA_REG_INDEX] = data;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_RnW;
	switch (dwidth)
	{
	case 8:
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	break;

	case 16:
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] |=   SPI_COMMAND_W0;
	break;

	case 24:
	reg[SPI_COMMAND_REG_INDEX] |=   SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	break;

	case 32:
	reg[SPI_COMMAND_REG_INDEX] |=  SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] |=  SPI_COMMAND_W0;
	break;

	default: //8 bits by default
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	}
    //Start write cycle
    reg[SPI_CTRL_REG_INDEX] |=   SPI_CTRL_ENABLE;
	return 0;
}

/****************************************************************************/
/**
*
* @brief Do a read access to a SPI controller. Take in account that the data width
* depends on the d_width parameter of the corresponding axi_spi_3_wire_ctrl
* peripheral. In case of data widths lower than 32 bits, just the least significant bits
* are effective.
*
* @return		result.
*
******************************************************************************/
int spi_ctrl_read(spi_ctrl_t *drv, int dwidth){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;

    reg[SPI_COMMAND_REG_INDEX] |=  SPI_COMMAND_RnW;

	switch (dwidth)
	{
	case 8:
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	break;

	case 16:
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] |=   SPI_COMMAND_W0;
	break;

	case 24:
	reg[SPI_COMMAND_REG_INDEX] |=   SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	break;

	case 32:
	reg[SPI_COMMAND_REG_INDEX] |=  SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] |=  SPI_COMMAND_W0;
	break;

	default: //8 bits by default
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W1;
	reg[SPI_COMMAND_REG_INDEX] &=  ~SPI_COMMAND_W0;
	}

    //Start read cycle
    reg[SPI_CTRL_REG_INDEX] |=   SPI_CTRL_ENABLE;

    //Wait until transition has finished (Controller in busy state and enable signal not active)
    while(spi_ctrl_get_busy(drv) && ~spi_ctrl_get_enable(drv));
    //Read the corresponding data
	result=(reg[SPI_RXDATA_REG_INDEX]);
	return result;
}


