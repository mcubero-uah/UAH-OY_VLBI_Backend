/*
 * sync_hw.h
 *
 *  Created on: 30 jun. 2023
 *      Author: miguel
 */

#ifndef SRC_SYNC_HW_H_
#define SRC_SYNC_HW_H_

// Register offsets:
#define SYNC_CTRL_REG_OFFSET 0
#define SYNC_TIMESTAMP_REG_OFFSET 4

// Register indexes:
#define SYNC_CTRL_REG_INDEX    	0
#define SYNC_TIMESTAMP_REG_INDEX  	1

// Register bit mask:
#define SYNC_CTRL_RST      		0x01
#define SYNC_CTRL_LOAD  		0x02

#endif /* SRC_SYNC_HW_H_ */
