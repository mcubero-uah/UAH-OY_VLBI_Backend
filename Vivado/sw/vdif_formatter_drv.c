/*
 * vdif_formatter_drv.c
 *
 *  Created on: 1 jul. 2023
 *      Author: miguel
 */
/***************************** Include Files *******************************/
#include "vdif_formatter_drv.h"
/************************** Function Definitions ***************************/
/****************************************************************************/
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
int vdif_formatter_set_rst(vdif_formatter_t *drv, int reset_bit){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	if(reset_bit==1){
	reg[VDIF_CTRL_REG_INDEX] |= VDIF_CTRL_RST;
	}
	else if (reset_bit==0){
	reg[VDIF_CTRL_REG_INDEX] &= ~VDIF_CTRL_RST;
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
int vdif_formatter_get_rst(vdif_formatter_t *drv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
	int result;
	result=reg[VDIF_CTRL_REG_INDEX]&VDIF_CTRL_RST;
	return result;
}

/****************************************************************************/
/**
*
* Initialize the corresponding controller Core with the desired base address
*
* @param	base_addr. Base address of the corresponding vdif_formatter
* peripheral.
*
* @return		0.
******************************************************************************/
int vdif_formatter_initialize(vdif_formatter_t *drv, uint32_t base_addr){
	drv->base_addr = base_addr;
	return 0;
}

/****************************************************************************/
/**
*
* Set invalid data field of the VDIF header associated to the drv device
*
* @param	invalid_data. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_invalid_data(vdif_formatter_t *drv, uint8_t invalid_data){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->invalid_data = invalid_data;
    /* Clear field bit in register*/
	reg[VDIF_WORD0_REG_INDEX] = reg[VDIF_WORD0_REG_INDEX] &~ VDIF_WORD0_INVALID_DATA ;
    /* Shift input value to desired position*/
    temp = invalid_data << 31;
    /* Write new value*/
	reg[VDIF_WORD0_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current invalid data field of the VDIF header associated to the drv device
*
*
* @return		Current invalid data field.
*
******************************************************************************/
uint8_t vdif_formatter_get_invalid_data(vdif_formatter_t *drv){
	int result;
	result=drv->invalid_data;
	return result;
}

/****************************************************************************/
/**
*
* Set legacy mode field of the VDIF header associated to the drv device
*
* @param	legacy_mode. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_legacy_mode(vdif_formatter_t *drv, uint8_t legacy_mode){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->legacy_mode = legacy_mode;
    /* Clear field bit in register*/
	reg[VDIF_WORD0_REG_INDEX] = reg[VDIF_WORD0_REG_INDEX] &~ VDIF_WORD0_LEGACY_MODE ;
    /* Shift input value to desired position*/
    temp = legacy_mode << 30;
    /* Write new value*/
	reg[VDIF_WORD0_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current legacy mode field of the VDIF header associated to the drv device
*
*
* @return		Current legacy mode field.
*
******************************************************************************/
uint8_t vdif_formatter_get_legacy_mode(vdif_formatter_t *drv){
	int result;
	result=drv->legacy_mode;
	return result;
}

/****************************************************************************/
/**
*
* Set unassigned field of the VDIF header associated to the drv device
*
* @param	unassigned. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_unassigned(vdif_formatter_t *drv, uint8_t unassigned){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->unassigned = unassigned;
    /* Clear field bit in register*/
	reg[VDIF_WORD1_REG_INDEX] = reg[VDIF_WORD1_REG_INDEX] &~ VDIF_WORD1_UNASSIGNED ;
    /* Shift input value to desired position*/
    temp = unassigned << 30;
    /* Write new value*/
	reg[VDIF_WORD1_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current unassigned field of the VDIF header associated to the drv device
*
*
* @return		Current unassigned field.
*
******************************************************************************/
uint8_t vdif_formatter_get_unassigned(vdif_formatter_t *drv){
	int result;
	result=drv->unassigned;
	return result;
}

/****************************************************************************/
/**
*
* Set Ref Epoch field of the VDIF header associated to the drv device
*
* @param	ref_epoch. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_ref_epoch(vdif_formatter_t *drv, uint8_t ref_epoch){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->ref_epoch = ref_epoch;
    /* Clear field bit in register*/
	reg[VDIF_WORD1_REG_INDEX] = reg[VDIF_WORD1_REG_INDEX] &~ VDIF_WORD1_REF_EPOCH ;
    /* Shift input value to desired position*/
    temp = ref_epoch << 24;
    /* Write new value*/
	reg[VDIF_WORD1_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Ref Epoch field of the VDIF header associated to the drv device
*
*
* @return		Current Ref Epoch field.
*
******************************************************************************/
uint8_t vdif_formatter_get_ref_epoch(vdif_formatter_t *drv){
	int result;
	result=drv->ref_epoch;
	return result;
}

/****************************************************************************/
/**
*
* Set VDIF Version Number field of the VDIF header associated to the drv device
*
* @param	vdif_version_number. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_vdif_version_number(vdif_formatter_t *drv, uint8_t vdif_version_number){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->vdif_version_number = vdif_version_number;
    /* Clear field bit in register*/
	reg[VDIF_WORD2_REG_INDEX] = reg[VDIF_WORD2_REG_INDEX] &~ VDIF_WORD2_VDIF_VERSION_NUMBER ;
    /* Shift input value to desired position*/
    temp = vdif_version_number << 29;
    /* Write new value*/
	reg[VDIF_WORD2_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current VDIF Version Number field of the VDIF header associated to the drv device
*
*
* @return		Current VDIF Version Number field.
*
******************************************************************************/
uint8_t vdif_formatter_get_vdif_version_number(vdif_formatter_t *drv){
	int result;
	result=drv->vdif_version_number;
	return result;
}

/****************************************************************************/
/**
*
* Set log2chns field of the VDIF header associated to the drv device
*
* @param	log2chns. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_log2chns(vdif_formatter_t *drv, uint8_t log2chns){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->log2chns = log2chns;
    /* Clear field bit in register*/
	reg[VDIF_WORD2_REG_INDEX] = reg[VDIF_WORD2_REG_INDEX] &~ VDIF_WORD2_LOG2_CHNS ;
    /* Shift input value to desired position*/
    temp = log2chns << 24;
    /* Write new value*/
	reg[VDIF_WORD2_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current log2chns field of the VDIF header associated to the drv device
*
*
* @return		Current log2chns field.
*
******************************************************************************/
uint8_t vdif_formatter_get_log2chns(vdif_formatter_t *drv){
	int result;
	result=drv->log2chns;
	return result;
}

/****************************************************************************/
/**
*
* Set Data Frame Length field of the VDIF header associated to the drv device
*
* @param	log2chns. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_data_frame_length(vdif_formatter_t *drv, uint32_t data_frame_length){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->data_frame_length = data_frame_length;
    /* Clear field bit in register*/
	reg[VDIF_WORD2_REG_INDEX] = reg[VDIF_WORD2_REG_INDEX] &~ VDIF_WORD2_DATA_FRAME_LENGTH ;
    /* Write new value*/
	reg[VDIF_WORD2_REG_INDEX] |= data_frame_length;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Data Frame Length field of the VDIF header associated to the drv device
*
*
* @return		Current log2chns field.
*
******************************************************************************/
uint32_t vdif_formatter_get_data_frame_length(vdif_formatter_t *drv){
	int result;
	result=drv->data_frame_length;
	return result;
}

/****************************************************************************/
/**
*
* Set Data type field of the VDIF header associated to the drv device
*
* @param	data_type. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_data_type(vdif_formatter_t *drv, uint8_t data_type){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->data_type = data_type;
    /* Clear field bit in register*/
	reg[VDIF_WORD3_REG_INDEX] = reg[VDIF_WORD3_REG_INDEX] &~ VDIF_WORD3_DATA_TYPE ;
    /* Shift input value to desired position*/
    temp = data_type << 31;
    /* Write new value*/
	reg[VDIF_WORD3_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Data type field of the VDIF header associated to the drv device
*
*
* @return		Current log2chns field.
*
******************************************************************************/
uint8_t vdif_formatter_get_data_type(vdif_formatter_t *drv){
	int result;
	result=drv->data_type;
	return result;
}

/****************************************************************************/
/**
*
* Set #Bits/sample-1 field of the VDIF header associated to the drv device
*
* @param	bitspersample_minus_1. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_bitspersample_minus_1(vdif_formatter_t *drv, uint8_t bitspersample_minus_1){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->bitspersample_minus_1 = bitspersample_minus_1;
    /* Clear field bit in register*/
	reg[VDIF_WORD3_REG_INDEX] = reg[VDIF_WORD3_REG_INDEX] &~ VDIF_WORD3_BITSPERSAMPLE_MINUS_1 ;
    /* Shift input value to desired position*/
    temp = bitspersample_minus_1 << 26;
    /* Write new value*/
	reg[VDIF_WORD3_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current #Bits/sample-1 field of the VDIF header associated to the drv device
*
*
* @return		Current #Bits/sample-1 field.
*
******************************************************************************/
uint8_t vdif_formatter_get_bitspersample_minus_1(vdif_formatter_t *drv){
	int result;
	result=drv->bitspersample_minus_1;
	return result;
}

/****************************************************************************/
/**
*
* Set Thread ID field of the VDIF header associated to the drv device
*
* @param	thread_id. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_thread_id(vdif_formatter_t *drv, uint16_t thread_id){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->thread_id = thread_id;
    /* Clear field bit in register*/
	reg[VDIF_WORD3_REG_INDEX] = reg[VDIF_WORD3_REG_INDEX] &~ VDIF_WORD3_THREAD_ID;
    /* Shift input value to desired position*/
    temp = thread_id << 16;
    /* Write new value*/
	reg[VDIF_WORD3_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Thread ID field of the VDIF header associated to the drv device
*
*
* @return		Current Thread ID field.
*
******************************************************************************/
uint16_t vdif_formatter_get_thread_id(vdif_formatter_t *drv){
	int result;
	result=drv->thread_id;
	return result;
}

/****************************************************************************/
/**
*
* Set Station ID field of the VDIF header associated to the drv device
*
* @param	station_id. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_station_id(vdif_formatter_t *drv, uint16_t station_id){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->station_id = station_id;
    /* Clear field bit in register*/
	reg[VDIF_WORD3_REG_INDEX] = reg[VDIF_WORD3_REG_INDEX] &~ VDIF_WORD3_STATION_ID ;
    /* Write new value*/
	reg[VDIF_WORD3_REG_INDEX] |= station_id;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Station ID field of the VDIF header associated to the drv device
*
*
* @return		Current Station ID field.
*
******************************************************************************/
uint16_t vdif_formatter_get_station_id(vdif_formatter_t *drv){
	int result;
	result=drv->station_id;
	return result;
}

/****************************************************************************/
/**
*
* Set EDV field of the VDIF header associated to the drv device
*
* @param	edv. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_edv(vdif_formatter_t *drv, uint8_t edv){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    uint32_t temp;
    drv->edv = edv;
    /* Clear field bit in register*/
	reg[VDIF_WORD4_REG_INDEX] = reg[VDIF_WORD4_REG_INDEX] &~ VDIF_WORD4_EDV;
    /* Shift input value to desired position*/
    temp = edv << 24;
    /* Write new value*/
	reg[VDIF_WORD4_REG_INDEX] |= temp;
	return 0;
}

/****************************************************************************/
/**
*
* Get current EDV field of the VDIF header associated to the drv device
*
*
* @return		Current EDV field.
*
******************************************************************************/
uint8_t vdif_formatter_get_edv(vdif_formatter_t *drv){
	int result;
	result=drv->edv;
	return result;
}

/****************************************************************************/
/**
*
* Set Extended User Data field (Word 4) of the VDIF header associated to the drv device
*
* @param	word4_ed. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_word4_ed(vdif_formatter_t *drv, uint32_t word4_ed){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->word4_ed = word4_ed;
    /* Clear field bit in register*/
	reg[VDIF_WORD4_REG_INDEX] = reg[VDIF_WORD4_REG_INDEX] &~ VDIF_WORD4_ED ;
    /* Write new value*/
	reg[VDIF_WORD4_REG_INDEX] |= word4_ed;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Extended User Data field (Word 4) field of the VDIF header associated to the drv device
*
*
* @return		Current Extended User Data field (Word 4) field.
*
******************************************************************************/
uint32_t vdif_formatter_get_word4_ed(vdif_formatter_t *drv){
	int result;
	result=drv->word4_ed;
	return result;
}

/****************************************************************************/
/**
*
* Set Extended User Data field (Word 5) of the VDIF header associated to the drv device
*
* @param	word5_ed. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_word5_ed(vdif_formatter_t *drv, uint32_t word5_ed){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->word5_ed = word5_ed;
    /* Write new value*/
	reg[VDIF_WORD5_REG_INDEX] = word5_ed;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Extended User Data field (Word 5) field of the VDIF header associated to the drv device
*
*
* @return		Current Extended User Data field (Word 5) field.
*
******************************************************************************/
uint32_t vdif_formatter_get_word5_ed(vdif_formatter_t *drv){
	int result;
	result=drv->word5_ed;
	return result;
}

/****************************************************************************/
/**
*
* Set Extended User Data field (Word 6) of the VDIF header associated to the drv device
*
* @param	word6_ed. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_word6_ed(vdif_formatter_t *drv, uint32_t word6_ed){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->word6_ed = word6_ed;
    /* Write new value*/
	reg[VDIF_WORD6_REG_INDEX] = word6_ed;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Extended User Data field (Word 6) field of the VDIF header associated to the drv device
*
*
* @return		Current Extended User Data field (Word 6) field.
*
******************************************************************************/
uint32_t vdif_formatter_get_word6_ed(vdif_formatter_t *drv){
	int result;
	result=drv->word6_ed;
	return result;
}

/****************************************************************************/
/**
*
* Set Extended User Data field (Word 7) of the VDIF header associated to the drv device
*
* @param	word7_ed. New value of the field
*
* @return		0.
*
******************************************************************************/
int vdif_formatter_set_word7_ed(vdif_formatter_t *drv, uint32_t word7_ed){
	volatile uint32_t *reg = (volatile uint32_t *) drv->base_addr;
    drv->word7_ed = word7_ed;
    /* Write new value*/
	reg[VDIF_WORD7_REG_INDEX] = word7_ed;
	return 0;
}

/****************************************************************************/
/**
*
* Get current Extended User Data field (Word 7) field of the VDIF header associated to the drv device
*
*
* @return		Current Extended User Data field (Word 7) field.
*
******************************************************************************/
uint32_t vdif_formatter_get_word7_ed(vdif_formatter_t *drv){
	int result;
	result=drv->word7_ed;
	return result;
}
