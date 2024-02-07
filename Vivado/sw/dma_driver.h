/*
 * dma_driver.h
 *
 *  Created on: 11 may. 2023
 *      Author: m.cubero
 */

#include "xaxidma.h"

#ifndef SRC_DMA_DRIVER_H_
#define SRC_DMA_DRIVER_H_

// Hardware-specific parameters
#define DMA_IS_CACHE_COHERENT  1 // Set to 1 to avoid overhead of software cache flushes if going through the ACP
#define RESET_TIMEOUT_COUNTER 10000


/************************** Device Struct ****************************/
typedef struct dma_struct
{
	XAxiDma dma_inst;
	int     dma_device_id;
	void*                     p_rcv_buf;
	int                       buf_length;
	int                       sample_size_bytes;
} dma_struct_t;

int initialize_dma(dma_struct_t *drv, int dma_device_id, int sample_size_bytes);
void dma_set_rcv_buf(dma_struct_t* drv, void* p_rcv_buf);
void* dma_get_rcv_buf(dma_struct_t* drv);
void dma_set_buf_length(dma_struct_t* drv, int buf_length);
int dma_get_buf_length(dma_struct_t* drv);
void dma_set_sample_size_bytes(dma_struct_t* drv, int sample_size_bytes);
int dma_get_sample_size_bytes(dma_struct_t* drv);
void dma_reset(dma_struct_t* drv);
int dma_rcv(dma_struct_t* drv);

#endif /* SRC_DMA_DRIVER_H_ */
