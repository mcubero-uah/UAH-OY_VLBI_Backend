/*
 * sync.h
 *
 *  Created on: 30 jun. 2023
 *      Author: miguel
 */

#ifndef SRC_SYNC_H_
#define SRC_SYNC_H_

/****************** Include Files ********************/
#include "sync_hw.h"
#include "xil_types.h"
#include "xstatus.h"
/************************** Device Struct ****************************/
typedef struct {
	 uint32_t base_addr;
} sync_t;

/************************** Function Prototypes ****************************/
int sync_set_rst(sync_t *drv, int reset_bit);
int sync_get_rst(sync_t *drv);
int sync_set_load(sync_t *drv, int load_bit);
int sync_get_load(sync_t *drv);
int sync_initialize(sync_t *drv, uint32_t base_addr);
int sync_load_timestamp(sync_t *drv, uint32_t timestamp);

#endif /* SRC_SYNC_H_ */
