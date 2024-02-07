/*
 * printing_ip.c
 *
 *  Created on: 16 jun. 2023
 *      Author: miguel
 */

#include "printing_ip.h"

/*****************************************************************************/
/**
 *
 * This function prints IP settings with a suitable format
 *
 * @param    msg is the string that is desired to be printed before the IP address.
 *
 * @param    ip  is a pointer to the ip_addr struct which contains the IP address
 *				to be printed.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void print_ip(char *msg, struct ip_addr *ip) {
	print(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip), ip4_addr3(ip),
			ip4_addr4(ip));
}

/*****************************************************************************/
/**
 *
 * This function prints the fixed IP addresses of the FPGA device, subnet mask,
 * and gateway
 *
 * @param    ip  is a pointer to the ip_addr struct which contains the device
 *				IP address
 *
 * @param    mask is a pointer to the ip_addr struct which contains the subnet
 *				 mask IP address
 *
 * @param    gw  is a pointer to the ip_addr struct which contains the gateway
 *				IP address
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,
		struct ip_addr *gw) {

	print_ip("Board IP: ", ip);
	print_ip("Netmask : ", mask);
	print_ip("Gateway : ", gw);
}

