#include <stdio.h>
#include <string.h>

#include "lwip/err.h"
#include "lwip/udp.h"
#include "xil_printf.h"

#include "xparameters.h"
#include "xstatus.h"

#include "sync.h"

#define FPGA_UDP_SERVER_PORT 7
#define PC_UDP_SERVER_PORT 1245

struct udp_pcb *pcb_client;

int udp_client_send(struct udp_pcb *pcb, void *data, int len);
static void udp_server_rx_callback(void *arg, struct udp_pcb *upcb, struct pbuf *p, struct ip_addr *addr, u16_t port);

extern sync_t axi_sync_instance;
extern uint8_t seconds_recv;

int start_udp_client_app() {
	err_t err;
	struct ip_addr ipaddr;

// create new UDP PCB structure
	pcb_client = udp_new();
	if (pcb_client == NULL) {
		xil_printf("Error creating PCB for the UDP server. Out of Memory\n\r");
		return -1;
	}
// bind local address and port. bind to port 0 to receive next
// available free port

	if ((err = udp_bind(pcb_client, IP_ADDR_ANY, FPGA_UDP_SERVER_PORT)) != ERR_OK) {
		xil_printf("error on udp_bind: %x\n\r", err);
		return -1;
	}
	xil_printf("[UDP client] binding OK\n\r");
// connect to the UDP server running on the PC:
	IP4_ADDR(&ipaddr, 172, 29, 24, 10); // PC remote host IP address
	err = udp_connect(pcb_client, &ipaddr, PC_UDP_SERVER_PORT);
	if (err != ERR_OK) {
		xil_printf("error on udp_connect: %x\n\r", err);
		return -1;
	}
	print("UDP connection OK\n\r");

	/* Set a receive callback for the upcb */
	udp_recv(pcb_client, udp_server_rx_callback, NULL);
	xil_printf("UDP client started @ port %d\n\r", FPGA_UDP_SERVER_PORT);
	return XST_SUCCESS;
}

int udp_client_send(struct udp_pcb *pcb, void *data, int len) {
	err_t err;
	struct pbuf *tx_pbuf;
	tx_pbuf = pbuf_alloc(PBUF_TRANSPORT, len, PBUF_RAM);
	if (!tx_pbuf) {
		xil_printf("error allocating pbuf to send\n\r");
		return -1;
	} else {
//		memcpy(tx_pbuf->payload, data, len);
		tx_pbuf->payload = data;
	}
	err = udp_send(pcb_client, tx_pbuf);
	if (err != ERR_OK) {
		xil_printf("Error on udp_send: %d\n\r", err);
		return -1;
	}
	pbuf_free(tx_pbuf);
	return 0;
}

static void udp_server_rx_callback(void *arg, struct udp_pcb *upcb, struct pbuf *p, struct ip_addr *addr, u16_t port) {
	uint32_t *data = p->payload;
	xil_printf("Seconds from epoch = %u seconds\n\r", *data);
	sync_load_timestamp(&axi_sync_instance, *data);
	seconds_recv=1;
	pbuf_free(p);
}

