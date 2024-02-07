/*
 * dma_driver.c
 *
 *  Created on: 11 may. 2023
 *      Author: m.cubero
 */

#include "dma_driver.h"

// Function prototypes

int initialize_dma(dma_struct_t *drv, int dma_device_id, int sample_size_bytes)
{
	drv->dma_device_id = dma_device_id;

	// Local variables
	int             status = 0;
	XAxiDma_Config* cfg_ptr;

	// Look up hardware configuration for device
	cfg_ptr = XAxiDma_LookupConfig(dma_device_id);
	if (!cfg_ptr)
	{
		xil_printf("ERROR! No hardware configuration found for AXI DMA with device id %d.\r\n", dma_device_id);
		return -1;
	}

	// Initialize driver
	status = XAxiDma_CfgInitialize(&drv->dma_inst, cfg_ptr);
	if (status != XST_SUCCESS)
	{
		xil_printf("ERROR! Initialization of AXI DMA failed with %d\r\n", status);
		return -1;
	}

	// Test for Scatter Gather
	if (XAxiDma_HasSg(&drv->dma_inst))
	{
		xil_printf("ERROR! Device configured as SG mode.\r\n");
		return -1;
	}

	// Reset DMA
	XAxiDma_Reset(&drv->dma_inst);
	while (!XAxiDma_ResetIsDone(&drv->dma_inst)) {}

	// Enable DMA interrupt
	XAxiDma_IntrEnable(&drv->dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);

	// Initialize buffer pointers
	dma_set_rcv_buf(drv, NULL);

	// Initialize buffer length
	dma_set_buf_length(drv, 1024);

	// Initialize sample size
	dma_set_sample_size_bytes(drv, sample_size_bytes);

	return 0;

}

//
// dma_set_rcv_buf - Set pointer to receive buffer to be used.
//
//  Arguments
//    - drv: 					Pointer to dma_struct_t object.
//    - p_rcv_buf:              Pointer to receive buffer to be used by the DMA.
//
void dma_set_rcv_buf(dma_struct_t* drv, void* p_rcv_buf)
{
	drv->p_rcv_buf = p_rcv_buf;
}

//
// dma_get_rcv_buf - Get a pointer to the receive buffer.
//.
//  Arguments
//    - drv:					Pointer to dma_struct_t object.
//
//  Return
//    - void*:                  Pointer to the receive buffer to be used by the DMA.
//

void* dma_get_rcv_buf(dma_struct_t* drv)
{
	return (drv->p_rcv_buf);
}

//
// dma_set_buf_length - Set the buffer length (in samples) to use for DMA transfers.
//
//    - drv:					Pointer to dma_struct_t object.
//    - buf_length:             Buffer length (in samples) to use for DMA transfers.
//


void dma_set_buf_length(dma_struct_t* drv, int buf_length)
{
	drv->buf_length = buf_length;
}

//
// dma_get_buf_length - Get the buffer length (in samples) to be used for DMA transfers.
//
//  Arguments
//    - drv: 					Pointer to dma_struct_t object.
//
//  Return
//    - int:                    Buffer length (in samples) to be transferred by the DMA.

int dma_get_buf_length(dma_struct_t* drv)
{
	return (drv->buf_length);
}

//
// dma_set_sample_size_bytes - Set the size (in bytes) of each sample (i.e. number
//                                   of bytes in tdata bus).
//
//  Arguments
//    - drv:					 Pointer to dma_struct_t object.
//    - sample_size_bytes:       Number of bytes per sample.
//

void dma_set_sample_size_bytes(dma_struct_t* drv, int sample_size_bytes)
{
	drv->sample_size_bytes = sample_size_bytes;
}

//
// dma_get_sample_size_bytes - Get the size (in bytes) of each sample (i.e. number
//                                   of bytes in tdata bus).
//
//  Arguments
//    - drv:					Pointer to dma_struct_t object.
//
//  Return
//    - int:                    Number of bytes per sample.
//

int dma_get_sample_size_bytes(dma_struct_t* drv)
{
	return (drv->sample_size_bytes);
}

//
// dma_reset - Reset the DMA engine.
//
//  Arguments
//    - drv: Pointer to dma_struct_t object.
//

void dma_reset(dma_struct_t* drv)
{
	XAxiDma_Reset(&drv->dma_inst);
}

int dma_rcv(dma_struct_t* drv)
{

		// Local variables
		int       status    = 0;
		const int num_bytes = (drv->buf_length)*(drv->sample_size_bytes);
		// Flush cache
		#if (!DMA_IS_CACHE_COHERENT)
		Xil_DCacheFlushRange((int)drv->p_rcv_buf, num_bytes);
		#endif

		// Enable interrupts
		XAxiDma_IntrEnable(&drv->dma_inst, (XAXIDMA_IRQ_IOC_MASK | XAXIDMA_IRQ_ERROR_MASK), XAXIDMA_DEVICE_TO_DMA);


		// Kick off S2MM transfer
		status = XAxiDma_SimpleTransfer
		(
			&drv->dma_inst,
			(UINTPTR)drv->p_rcv_buf,
			num_bytes,
			XAXIDMA_DEVICE_TO_DMA
		);

		if (status != XST_SUCCESS)
		{
			xil_printf("ERROR! Failed to kick off S2MM transfer!\n\r");
			return -1;
		}

		return 0;
}
