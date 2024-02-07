/*
 * vdif_formatter_drv_hw.h
 *
 *  Created on: 1 jul. 2023
 *      Author: miguel
 */

#ifndef SRC_VDIF_FORMATTER_DRV_HW_H_
#define SRC_VDIF_FORMATTER_DRV_HW_H_

// Register offsets:
#define VDIF_CTRL_REG_OFFSET 0
#define VDIF_WORD0_REG_OFFSET 4
#define VDIF_WORD1_REG_OFFSET 8
#define VDIF_WORD2_REG_OFFSET 12
#define VDIF_WORD3_REG_OFFSET 16
#define VDIF_WORD4_REG_OFFSET 20
#define VDIF_WORD5_REG_OFFSET 24
#define VDIF_WORD6_REG_OFFSET 28
#define VDIF_WORD7_REG_OFFSET 32

// Register indexes:
#define VDIF_CTRL_REG_INDEX    	0
#define VDIF_WORD0_REG_INDEX  	1
#define VDIF_WORD1_REG_INDEX  	2
#define VDIF_WORD2_REG_INDEX  	3
#define VDIF_WORD3_REG_INDEX  	4
#define VDIF_WORD4_REG_INDEX  	5
#define VDIF_WORD5_REG_INDEX  	6
#define VDIF_WORD6_REG_INDEX  	7
#define VDIF_WORD7_REG_INDEX  	8

// Register bit mask:
#define VDIF_CTRL_RST      		            0x01
#define VDIF_WORD0_INVALID_DATA      		(0x01 << 31)
#define VDIF_WORD0_LEGACY_MODE      		(0x01 << 30)
#define VDIF_WORD1_UNASSIGNED         		(0x03 << 30)
#define VDIF_WORD1_REF_EPOCH         		(0x3F << 24)
#define VDIF_WORD2_VDIF_VERSION_NUMBER      (0x07 << 29)
#define VDIF_WORD2_LOG2_CHNS                (0x1F << 24)
#define VDIF_WORD2_DATA_FRAME_LENGTH        0xFFFFFF
#define VDIF_WORD3_DATA_TYPE                (0x01 << 31)
#define VDIF_WORD3_BITSPERSAMPLE_MINUS_1    (0x1F << 26)
#define VDIF_WORD3_THREAD_ID                (0x03FF << 16)
#define VDIF_WORD3_STATION_ID               0xFFFF
#define VDIF_WORD4_EDV                      (0x0FF << 24)
#define VDIF_WORD4_ED                       0xFFFFFF


#endif /* SRC_VDIF_FORMATTER_DRV_HW_H_ */
