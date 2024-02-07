/*
 * vdif_formatter_drv.h
 *
 *  Created on: 1 jul. 2023
 *      Author: miguel
 */

#ifndef SRC_VDIF_FORMATTER_DRV_H_
#define SRC_VDIF_FORMATTER_DRV_H_

/****************** Include Files ********************/
#include "vdif_formatter_drv_hw.h"
#include "xil_types.h"
#include "xstatus.h"

/************************** Device Struct ****************************/
typedef struct {
	 uint32_t base_addr;
	 uint8_t invalid_data;
     uint8_t legacy_mode;
     uint8_t unassigned;
     uint8_t ref_epoch;
     uint8_t vdif_version_number;
     uint8_t log2chns;
     uint32_t data_frame_length;
     uint8_t data_type;
     uint8_t bitspersample_minus_1;
     uint16_t thread_id;
     uint32_t station_id;
     uint8_t edv;
     uint32_t word4_ed;
     uint32_t word5_ed;
     uint32_t word6_ed;
     uint32_t word7_ed;
} vdif_formatter_t;

/************************** Function Prototypes ****************************/
int vdif_formatter_set_rst(vdif_formatter_t *drv, int reset_bit);
int vdif_formatter_get_rst(vdif_formatter_t *drv);

int vdif_formatter_initialize(vdif_formatter_t *drv, uint32_t base_addr);

int vdif_formatter_set_invalid_data(vdif_formatter_t *drv, uint8_t invalid_data);
uint8_t vdif_formatter_get_invalid_data(vdif_formatter_t *drv);

int vdif_formatter_set_legacy_mode(vdif_formatter_t *drv, uint8_t legacy_mode);
uint8_t vdif_formatter_get_legacy_mode(vdif_formatter_t *drv);

int vdif_formatter_set_unassigned(vdif_formatter_t *drv, uint8_t unassigned);
uint8_t vdif_formatter_get_unassigned(vdif_formatter_t *drv);

int vdif_formatter_set_ref_epoch(vdif_formatter_t *drv, uint8_t ref_epoch);
uint8_t vdif_formatter_get_ref_epoch(vdif_formatter_t *drv);

int vdif_formatter_set_vdif_version_number(vdif_formatter_t *drv, uint8_t vdif_version_number);
uint8_t vdif_formatter_get_vdif_version_number(vdif_formatter_t *drv);

int vdif_formatter_set_log2chns(vdif_formatter_t *drv, uint8_t log2chns);
uint8_t vdif_formatter_get_log2chns(vdif_formatter_t *drv);

int vdif_formatter_set_data_frame_length(vdif_formatter_t *drv, uint32_t data_frame_length);
uint32_t vdif_formatter_get_data_frame_length(vdif_formatter_t *drv);

int vdif_formatter_set_data_type(vdif_formatter_t *drv, uint8_t data_type);
uint8_t vdif_formatter_get_data_type(vdif_formatter_t *drv);

int vdif_formatter_set_bitspersample_minus_1(vdif_formatter_t *drv, uint8_t bitspersample_minus_1);
uint8_t vdif_formatter_get_bitspersample_minus_1(vdif_formatter_t *drv);

int vdif_formatter_set_thread_id(vdif_formatter_t *drv, uint16_t thread_id);
uint16_t vdif_formatter_get_thread_id(vdif_formatter_t *drv);

int vdif_formatter_set_station_id(vdif_formatter_t *drv, uint16_t station_id);
uint16_t vdif_formatter_get_station_id(vdif_formatter_t *drv);

int vdif_formatter_set_edv(vdif_formatter_t *drv, uint8_t edv);
uint8_t vdif_formatter_get_edv(vdif_formatter_t *drv);

int vdif_formatter_set_word4_ed(vdif_formatter_t *drv, uint32_t word4_ed);
uint32_t vdif_formatter_get_word4_ed(vdif_formatter_t *drv);

int vdif_formatter_set_word5_ed(vdif_formatter_t *drv, uint32_t word5_ed);
uint32_t vdif_formatter_get_word5_ed(vdif_formatter_t *drv);

int vdif_formatter_set_word6_ed(vdif_formatter_t *drv, uint32_t word6_ed);
uint32_t vdif_formatter_get_word6_ed(vdif_formatter_t *drv);

int vdif_formatter_set_word7_ed(vdif_formatter_t *drv, uint32_t word7_ed);
uint32_t vdif_formatter_get_word7_ed(vdif_formatter_t *drv);

#endif /* SRC_VDIF_FORMATTER_DRV_H_ */
