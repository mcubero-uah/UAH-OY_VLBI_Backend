/*
 * printing_ip.h
 *
 *  Created on: 16 jun. 2023
 *      Author: miguel
 */
#include "lwip/tcp.h"
#include "xil_printf.h"

#ifndef SRC_PRINTING_IP_H_
#define SRC_PRINTING_IP_H_

/************************** Function Prototypes*****************************/
void print_ip(char *msg, struct ip_addr *ip);
void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,struct ip_addr *gw);

#endif /* SRC_PRINTING_IP_H_ */
