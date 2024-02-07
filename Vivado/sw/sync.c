/*
 * sync.c
 *
 *  Created on: 30 jun. 2023
 *      Author: miguel
 */
/***************************** Include Files *******************************/
#include "sync.h"

/************************** Function Definitions ***************************/
/****************************************************************************/
/****************************************************************************/
/**
*
* Set reset bit
*
* @param	reset_bit. Set it to 1 to enable the core reset
* and to 0 to disable the reset
*
* @return		0.
*
******************************************************************************/
int sync_set_rst(sync_t *drv, int reset_bit){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(reset_bit==1){
	reg[SYNC_CTRL_REG_INDEX] |= SYNC_CTRL_RST;
	}
	else if (reset_bit==0){
	reg[SYNC_CTRL_REG_INDEX] &= ~SYNC_CTRL_RST;
	}
	else;
	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* Get reset bit
*
*
* @return		Reset bit state.
*
******************************************************************************/
int sync_get_rst(sync_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=reg[SYNC_CTRL_REG_INDEX]&SYNC_CTRL_RST;
	return result;
}

/****************************************************************************/
/**
*
* Set load bit
*
* @param	load_bit. Set it to 1 to enable the core load
* and to 0 to disable the load
*
* @return		0.
*
******************************************************************************/
int sync_set_load(sync_t *drv, int load_bit){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(load_bit==1){
	reg[SYNC_CTRL_REG_INDEX] |= SYNC_CTRL_LOAD;
	}
	else if (load_bit==0){
	reg[SYNC_CTRL_REG_INDEX] &= ~SYNC_CTRL_LOAD;
	}
	else;
	return XST_SUCCESS;
}

/****************************************************************************/
/**
*
* Get load bit
*
*
* @return		Load bit state.
*
******************************************************************************/
int sync_get_load(sync_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=((reg[SYNC_CTRL_REG_INDEX]&SYNC_CTRL_LOAD)>>(1));
	return result;
}

/****************************************************************************/
/**
*
* Initialize the corresponding Controller Core with the desired base address
*
* @param	base_addr. Base address of the corresponding axi_sync
* peripheral.
*
* @return		0.
******************************************************************************/
int sync_initialize(sync_t *drv, uint32_t base_addr){
	drv->base_addr = base_addr;
	return 0;
}

/****************************************************************************/
/**
*
* Load the timestamp (seconds from epoch) to the desired axi_sync device
*
* @param	timestamp. Seconds from epoch number. Is a 30 bits number, so
* the maximum value is 1073700000 seconds
*
* @return		0 if OK.
* 				1 if introduced timestamp was not supported
******************************************************************************/
int sync_load_timestamp(sync_t *drv, uint32_t timestamp){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if (timestamp & 0xC0000000)
		return XST_FAILURE;
	else{
		reg[SYNC_TIMESTAMP_REG_INDEX] = timestamp;
		sync_set_load(drv, 1);
		sync_set_load(drv, 0);
		return XST_SUCCESS;
	}

}
