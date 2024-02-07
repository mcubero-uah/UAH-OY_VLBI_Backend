#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xil_io.h"
#include "netif/xadapter.h"
#include "lwip/udp.h"
#include "lwip/tcp.h"

#include "xscutimer.h"
#include "xscugic.h"

#include "platform.h"
#include "xil_printf.h"
#include "spi_3_wire_ctrl.h"
#include "vdif_formatter_drv.h"
#include "sync.h"
#include "printing_ip.h"
#include "dma_driver.h"
#include "xuartps.h"
#include "xuartps_hw.h"

/************************** Constant Definitions *****************************/
/*
 * The following constants map to the XPAR parameters created in the
 * xparameters.h file. They are only defined here such that a user can easily
 * change all the needed parameters in one place.
 */
#define TIMER_IRPT_INTR XPAR_SCUTIMER_INTR
#define PLATFORM_EMAC_BASEADDR XPAR_XEMACPS_0_BASEADDR
// GIC ID
#define GIC_DEVICE_ID XPAR_SCUGIC_SINGLE_DEVICE_ID

// GIC IRQ Handler
#define INTC_HANDLER XScuGic_InterruptHandler

// MEMORY
#define PS7_DDR1_BASEADDR 0x10010000
// AXI DMA
#define AXI_DMA_BASE_ADDRESS PS7_DDR1_BASEADDR
#define DATA_ADDRESS_2 AXI_DMA_BASE_ADDRESS + (0x20000) // + 16 kB

// DMA Interrupt ID
#define DMA_INTR_ID XPAR_FABRIC_AXI_DMA_0_S2MM_INTROUT_INTR

#define PACKET_LENGTH_BYTES 8192
#define PACKET_LENGTH_WORDS PACKET_LENGTH_BYTES/4

/**************************** Function prototypes *******************************/
int adc_cfg(void);

int start_udp_client_app();
int udp_client_send(struct udp_pcb *pcb, void *data, int len);

// missing declaration in lwIP
void lwip_init();
void tcp_fasttmr(void);
void tcp_slowtmr(void);

void platform_setup_timer(void);

static int ScuTimer_intr_config(XScuGic *GicInst, XScuTimer *TimerInstancePtr,
		u16 TimerIntrId);
static int AXI_DMA_intr_config(XScuGic *GicInst, XAxiDma* p_dma_inst,
		u16 DMA_IntrId);

static int GIC_Setup(XScuGic *GicInst);

void scutimer_enable(void);

int ConfigUartPs(u16 DeviceId, XUartPs *uart_inst);

void print_ip(char *msg, struct ip_addr *ip);
void print_ip_settings(struct ip_addr *ip, struct ip_addr *mask,
		struct ip_addr *gw);

/* IRQ Handling function */
void timer_callback(XScuTimer *TimerInstance);
static void s2mm_isr(void *CallbackRef);

/**************************** Global Definitions *******************************/
spi_ctrl_t sys_spi;

/* Instance of the General Interrupt Controller */
XScuGic GIC;

XUartPs Uart_Ps;

dma_struct_t dma_1;

// DMA status variables
int g_s2mm_done = 0;
int g_dma_err = 0;

/* lwip instances*/
static struct netif sys_netif;
struct netif *app_netif;

/* Instance of the ScuTimer structure*/
static XScuTimer TimerInstance;

/* Instances of custom peripherals structures*/
sync_t axi_sync_instance;
static vdif_formatter_t vdif_formatter_instance;

static int ResetRxCntr = 0;

extern struct udp_pcb *pcb_client;

uint8_t ref_epoch = 47; // If saved as main local variable (stack), AP Transaction Timeout!!

uint8_t seconds_recv = 0;

/**************************** Function Definitions *******************************/
int adc_cfg(void){
	int read_data;

    //Initialize 3-wire spi driver object at address 0
    spi_ctrl_initialize(&sys_spi,XPAR_AXI_SPI_3_WIRE_CTRL_0_S00_AXI_BASEADDR,0,3);

    //Check that SPI interface and ADC are working properly
//	spi_ctrl_set_command(&sys_spi,0x01); //ADC Address= CHIP_ID register;
//	read_data=spi_ctrl_read(&sys_spi,8);
//	xil_printf("Chip ID: %x \n",read_data);

	// Set test mode to checkerboard
//	spi_ctrl_set_command(&sys_spi,0x0D); //ADC Address= test mode register;
//	spi_ctrl_write(&sys_spi,0x04,8);
//	// Set test mode to default
	spi_ctrl_set_command(&sys_spi,0x0D); //ADC Address= test mode register;
	spi_ctrl_write(&sys_spi,0x00,8);

	// Set buffer currents to 0% (Recommended for fs<150 MSps and fin<100 MHz
	spi_ctrl_set_command(&sys_spi,0x36); //ADC Address= Buffer current select 1 register;
	spi_ctrl_write(&sys_spi,0x00,8);
	spi_ctrl_set_command(&sys_spi,0x107); //ADC Address= Buffer current select 2 register;
	spi_ctrl_write(&sys_spi,0x00,8);

	spi_ctrl_set_command(&sys_spi,0xFF); //ADC Address= Transfer register;
	spi_ctrl_write(&sys_spi,0x01,8);
	spi_ctrl_write(&sys_spi,0x00,8);

    return 0;

}


/*****************************************************************************/
/**
 *
 * This function initializes the desired UART device at 115200 baud
 *
 * @return	0 if success.
 * 			1 if error.
 *
 ******************************************************************************/
int ConfigUartPs(u16 DeviceId, XUartPs *uart_inst) {
	int Status;
	XUartPs_Config *Config;

	/*
	 * Initialize the UART driver so that it's ready to use
	 * Look up the configuration in the config table and then initialize it.
	 */
	Config = XUartPs_LookupConfig(DeviceId);
	if (NULL == Config) {
		return XST_FAILURE;
	}

	Status = XUartPs_CfgInitialize(uart_inst, Config, Config->BaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	XUartPs_SetBaudRate(uart_inst, 115200);

	return XST_SUCCESS;
}

/*****************************************************************************/
/**
 *
 * This function initializes the ScuTimer, load its count value for 250 milli
 * seconds timeout, and enable auto reload mode
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void platform_setup_timer(void) {
	int Status = XST_SUCCESS;
	XScuTimer_Config *ConfigPtr;
	int TimerLoadValue = 0;

	/* Initialize the Scu Private Timer driver */
	ConfigPtr = XScuTimer_LookupConfig(TIMER_DEVICE_ID);
	Status = XScuTimer_CfgInitialize(&TimerInstance, ConfigPtr,
			ConfigPtr->BaseAddr);
	if (Status != XST_SUCCESS) {
		xil_printf("In %s: Scutimer Cfg initialization failed...\r\n",
				__func__);
		return;
	}

	/* Perform a self-test to ensure that the hardware was built correctly */
	Status = XScuTimer_SelfTest(&TimerInstance);
	if (Status != XST_SUCCESS) {
		xil_printf("In %s: Scutimer Self test failed...\r\n", __func__);
		return;
	}

	/* Enable Auto reload mode */
	XScuTimer_EnableAutoReload(&TimerInstance);

	/* Set for 250 milli seconds timeout */
	TimerLoadValue = XPAR_CPU_CORTEXA9_0_CPU_CLK_FREQ_HZ / 8;

	/* Load the timer counter register */
	XScuTimer_LoadTimer(&TimerInstance, TimerLoadValue);
	return;
}

/*****************************************************************************/
/**
 *
 * This function sets up the interrupt system such that interrupts can occur
 * for the device.
 *
 * @param	GicInst is a pointer to the instance of XScuGic driver.
 * @param	TimerInstancePtr is a pointer to the instance of XScuTimer
 *		driver.
 *
 * @param	TimerIntrId is the Interrupt Id of the XScuTimer device.
 *
 * @return	XST_SUCCESS if successful, otherwise XST_FAILURE.
 *
 * @note	This function doesn�t enable the peripherals interrupts (FIFO and
 *  		ScuTimer)
 *
 ******************************************************************************/
static int GIC_Setup(XScuGic *GicInst) {
	int Status;

	XScuGic_Config *IntcConfig;

	// Initialize the interrupt controller.
	IntcConfig = XScuGic_LookupConfig(GIC_DEVICE_ID);
	if (NULL == IntcConfig) {
		return XST_FAILURE;
	}

	Status = XScuGic_CfgInitialize(GicInst, IntcConfig,
			IntcConfig->CpuBaseAddress);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}

	Status = XScuGic_SelfTest(GicInst);
	if (Status != XST_SUCCESS) {
		xil_printf("GIC config init failed \r\n");
		return XST_FAILURE;
	}

	/*Initialize the exception table. (For ARM Cortex-A53, Cortex-R5,
	 *			and Cortex-A9, the exception handlers are being initialized
	 *			statically and this function does not do anything.)*/
	//	Xil_ExceptionInit();
	// Register the interrupt controller handler with the exception table.
	Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) INTC_HANDLER, GicInst);

	return XST_SUCCESS;
}

static int ScuTimer_intr_config(XScuGic *GicInst, XScuTimer *TimerInstancePtr,
		u16 TimerIntrId) {
	int Status;

	// Connect the interrupt handler to the GIC.
	Status = XScuGic_Connect(GicInst, TimerIntrId,
			(Xil_ExceptionHandler) timer_callback, (void *) TimerInstancePtr);
	if (Status != XST_SUCCESS) {
		return Status;
	}
	// Set interrupt priorities and trigger type (Scu Timer is the higher priority
	// due to de needing of keep the socket working)
	XScuGic_SetPriorityTriggerType(GicInst, TimerIntrId, 0xA0, 0x3);

//	XScuGic_Enable(GicInst, TimerIntrId);
	XScuGic_EnableIntr(INTC_DIST_BASE_ADDR, TimerIntrId);

	return XST_SUCCESS;
}

static int AXI_DMA_intr_config(XScuGic *GicInst, XAxiDma* p_dma_inst,
		u16 DMA_IntrId) {
	int Status;

	// Connect the interrupt handler to the GIC.
	Status = XScuGic_Connect(GicInst, DMA_IntrId,
			(Xil_InterruptHandler) s2mm_isr, p_dma_inst);
	if (Status != XST_SUCCESS) {
		return Status;
	}
	// Set interrupt priorities and trigger type (Scu Timer is the higher priority
	// due to de needing of keep the socket working)
	XScuGic_SetPriorityTriggerType(GicInst, DMA_IntrId, 0xA8, 0x3);

	XScuGic_Enable(GicInst, DMA_IntrId);

	return XST_SUCCESS;

}
/*****************************************************************************/
/**
 *
 * This function enables exceptions, enable ScuTimer interrupt and start ScuTimer
 * count
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void scutimer_enable(void) {

	/* Enable ScuTimer Interrupt */
	XScuTimer_EnableInterrupt(&TimerInstance);
	/* Start ScuTimer count */
	XScuTimer_Start(&TimerInstance);

	return;
}

int main() {
	/*********** Local variables declaration ********************/
	int buffer_number = 0;
	int Status;
	struct ip_addr ipaddr, netmask, gateway;
	// the mac address of the board. this should be unique per board
	unsigned char mac_ethernet_address[] =
			{ 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	uint32_t *rcv_buf_1 = (uint32_t *) AXI_DMA_BASE_ADDRESS;
	uint32_t *rcv_buf_2 = (uint32_t *) DATA_ADDRESS_2;

	uint32_t packet_count = 0;

	int recv_bytes = 0;
	uint8_t set_period_flag = 0;
	uint8_t start_obs_flag = 0;
	uint32_t seconds_threshold = 1;
	uint32_t count_threshold = 1953; // 1 second
	char buffer_rx[28];
	const char help[6] = "help\r";
	const char set_obs_period[16] = "set_obs_period\r";
	const char start_observation[19] = "start_observation\r";

	/*********** Initialize UART ********************/
	ConfigUartPs(UART_DEVICE_ID, &Uart_Ps);

	/*********** Setup ADC ********************/
	adc_cfg();
    // xil_printf("Adc configuration finished\n");

	/*********** Setup VDIF Base Address ********************/
	vdif_formatter_initialize(&vdif_formatter_instance,
	XPAR_VDIF_FORMATTER_0_S_AXI_BASEADDR);
	/*********** Reset VDIF formatter and ADC interface (note that both operate with same reset!) ********************/
	vdif_formatter_set_rst(&vdif_formatter_instance, 1);

	/*********** Setup VDIF Headers (validation purposes) ********************/
	/* Word 0 */
	vdif_formatter_set_invalid_data(&vdif_formatter_instance, 0);
	vdif_formatter_set_legacy_mode(&vdif_formatter_instance, 0);
	/* Word 1 */
	vdif_formatter_set_unassigned(&vdif_formatter_instance, 0);
	vdif_formatter_set_ref_epoch(&vdif_formatter_instance, ref_epoch); // 1 July 2023
	/* Word 2 */
	vdif_formatter_set_vdif_version_number(&vdif_formatter_instance, 0);
	vdif_formatter_set_log2chns(&vdif_formatter_instance, 0);
	vdif_formatter_set_data_frame_length(&vdif_formatter_instance, 0x0400); //(Frame length inside - 8 kB- 0x0400)
	/* Word 3 */
	vdif_formatter_set_data_type(&vdif_formatter_instance, 0);
	vdif_formatter_set_bitspersample_minus_1(&vdif_formatter_instance, 1);
	vdif_formatter_set_thread_id(&vdif_formatter_instance, 0);
	vdif_formatter_set_station_id(&vdif_formatter_instance, 0x596A); // Yj (13 m)
	/* Word 4 */
	vdif_formatter_set_edv(&vdif_formatter_instance, 0);
	vdif_formatter_set_word4_ed(&vdif_formatter_instance, 0);
	/* Word 5 */
	vdif_formatter_set_word5_ed(&vdif_formatter_instance, 0);
	/* Word 6 */
	vdif_formatter_set_word6_ed(&vdif_formatter_instance, 0);
	/* Word 7 */
	vdif_formatter_set_word7_ed(&vdif_formatter_instance, 0);

	/*********** Setup seconds from epoch ********************/
	sync_initialize(&axi_sync_instance, XPAR_AXI_SYNC_0_S_AXI_BASEADDR);
	sync_set_rst(&axi_sync_instance, 0);
//	sync_load_timestamp(&axi_sync_instance, 0xCAFE);
	/*********** Setup DMA and interrupts ********************/
	initialize_dma(&dma_1, XPAR_AXIDMA_0_DEVICE_ID, sizeof(int));
	dma_set_buf_length(&dma_1, PACKET_LENGTH_WORDS);
	// Make sure the buffers are clear before we populate it (generally don't need to do this, but for proving the DMA working, we do it anyway)
	memset(rcv_buf_1, 0, PACKET_LENGTH_BYTES);
	memset(rcv_buf_2, 0, PACKET_LENGTH_BYTES);

//	/*********** UDP Client setup ********************/
	xil_printf("Running UDP client\n\r");
	/* Initialize Scu Timer */
	platform_setup_timer();
	/* Generic Interrupt Controller (GIC) setup */
	Status = GIC_Setup(&GIC);
	if (Status != XST_SUCCESS) {
		return XST_FAILURE;
	}
	ScuTimer_intr_config(&GIC, &TimerInstance, TIMER_IRPT_INTR);
	AXI_DMA_intr_config(&GIC, &dma_1.dma_inst, DMA_INTR_ID);

	/* initialize IP addresses to be used
	 * Note that the FPGA and the PC must be in the same subnetwork
	 */
	IP4_ADDR(&ipaddr, 172, 29, 24, 115);
	IP4_ADDR(&netmask, 255, 255, 252, 0);
	IP4_ADDR(&gateway, 172, 29, 24, 1);
	/* Print configured IP settings */
	print_ip_settings(&ipaddr, &netmask, &gateway);

	/* Initialize lwip modules*/
	lwip_init();

	/* Add network interface to the netif_list, and set it as default */
	app_netif = xemac_add(&sys_netif, &ipaddr, &netmask, &gateway,
			mac_ethernet_address,
			PLATFORM_EMAC_BASEADDR);

	if (app_netif == NULL) {
		xil_printf("Error adding N/W interface\n\r");
		return -1;
	}
	/* Set the network interface as the default network interface */
	netif_set_default(app_netif);

	/* Enable non-critical exceptions */
	Xil_ExceptionEnable();
	/* Enable ScuTimer interrupt and start ScuTimer count*/
	scutimer_enable();

	// specify that the network if is up
	netif_set_up(app_netif);

	// start the application:
	start_udp_client_app();

	// Setup seconds from epoch
	udp_client_send(pcb_client, &ref_epoch, sizeof(uint8_t));

	/*********** Starting the application ********************/
//	// Reset DMA to flush those 4 extra samples that are accepted before DMA configuration
//	dma_reset(&dma_1);
//	/*********** Release resets ********************/
//
//	vdif_formatter_set_rst(&vdif_formatter_instance, 0);
//	/*********** Start first DMA transfer ********************/
//	dma_set_rcv_buf(&dma_1, (void *) rcv_buf_1);
//	// Initialize control flags which get set by ISR
//	g_s2mm_done = 0;
//	g_dma_err = 0;
//	Status = dma_rcv(&dma_1);
//	print("Application started! \n");

	print("==========================================\n\r");
	print("VDIF Formatter v. 1.0.0\n\r");
	print("Author: mcubero m.cubero@uah.es\n\r");
	print("==========================================\n\r\n\r");
	print("Type set_obs_period to set the observation period in seconds (1 second by default)\n\r");
	print("Type only 3 digits positive numbers, for example: 004/035/345 \n\r");
	print("Type start_observation to start an observation\n\r");
	print("Type help to display again the commands explanation\n\r");
	memset(buffer_rx, 0, sizeof(buffer_rx));
	// receive and process packets
	while (1) {
		xemacif_input(app_netif);

		if (start_obs_flag == 1) {
			if (g_s2mm_done || g_dma_err) {
//				print("DMA transfer finished \n");
				// Check DMA for errors
				if (g_dma_err) {
					xil_printf(
							"ERROR! AXI DMA returned an error during the S2MM transfer.\n\r");
					return -1;
				} else {
					// Initialize control flags which get set by ISR
					g_s2mm_done = 0;
					g_dma_err = 0;

					if (buffer_number == 0) {
//					print("Transfer successfully finished! \n New data: \n");
//					for (int idx_2 = 0; idx_2 < 1; idx_2++) {
//						xil_printf("%x \n",rcv_buf_1[idx_2]);
//					}
						udp_client_send(pcb_client, rcv_buf_1,
						PACKET_LENGTH_BYTES);
//						print("Packet sent \n");
						/*********** Start DMA transfer to buffer 2********************/
						dma_set_rcv_buf(&dma_1, (void *) rcv_buf_2);
						Status = dma_rcv(&dma_1);
					} else {
						udp_client_send(pcb_client, rcv_buf_2,
						PACKET_LENGTH_BYTES);
//						print("Packet sent \n");
						/*********** Start DMA transfer to buffer 1********************/
						dma_set_rcv_buf(&dma_1, (void *) rcv_buf_1);
						Status = dma_rcv(&dma_1);
					}
					buffer_number = ~buffer_number;
					packet_count++;
					if (packet_count==count_threshold){
						start_obs_flag=0;
						/*********** Reset VDIF Formatter ********************/
						vdif_formatter_set_rst(&vdif_formatter_instance, 1);
						print("Observation finished!\n\r");
					}
				}
			}
		} else {
			if (seconds_recv){
			buffer_rx[recv_bytes] = XUartPs_RecvByte(XPAR_PS7_UART_1_BASEADDR);
			recv_bytes++;
			if (buffer_rx[recv_bytes - 1] == '\r') {
				print("\n\r");
				if (set_period_flag) {
						seconds_threshold = (buffer_rx[0] - 48) * 100
								+ (buffer_rx[1] - 48) * 10
								+ (buffer_rx[2] - 48);
						count_threshold=seconds_threshold*1953;

						if (seconds_threshold==0){
							print("Observation period must be at least 1 second \n\r");
						seconds_threshold=1;
						count_threshold=1953;
						}

						xil_printf("Set %u seconds \n\r", seconds_threshold);
						set_period_flag = 0;
				}
				else {
					if (strcmp(buffer_rx, help) == 0) {
						print(
								"Type set_obs_period to set the observation period in seconds (1 second by default)\n\r");
						print(
								"Type only 3 digits positive numbers, for example: 004/035/345 \n\r");
						print(
								"Type start_observation to start an observation\n\r");
						print(
								"Type help to display again the commands explanation\n\r");
					}
					if (strcmp(buffer_rx, set_obs_period) == 0) {
						print(
								"Type the desired observation seconds (up to 999): \n\r");
						set_period_flag = 1;
					}
					if (strcmp(buffer_rx, start_observation) == 0) {
						print(
								"Observation initiated. Please wait for it to finish...\n\r");
						start_obs_flag = 1;
						packet_count = 0;
						buffer_number=0;
						// Reset DMA to flush those 4 extra samples that are accepted before DMA configuration
						dma_reset(&dma_1);
						/*********** Release resets ********************/
						vdif_formatter_set_rst(&vdif_formatter_instance, 0);
						/*********** Start first DMA transfer ********************/
						dma_set_rcv_buf(&dma_1, (void *) rcv_buf_1);
						// Initialize control flags which get set by ISR
						g_s2mm_done = 0;
						g_dma_err = 0;
						Status = dma_rcv(&dma_1);
					}
				}
				recv_bytes = 0;
//				xil_printf(" %s \n\r", buffer_rx);
				memset(buffer_rx, 0, sizeof(buffer_rx));
			} else
				xil_printf("%c", buffer_rx[recv_bytes - 1]);
			}
		}

	}

	return 0;
}

/*****************************************************************************/
/**
 *
 * This function is the Interrupt handler for the Timer interrupt of the
 * Timer device. It is called on the expiration of the timer counter in
 * interrupt context.
 *
 * @param	TimerInstance is a pointer to the callback function.
 *
 * @return	None.
 *
 * @note		None.
 *
 ******************************************************************************/
void timer_callback(XScuTimer *TimerInstance) {
// we need to call tcp_fasttmr & tcp_slowtmr at intervals specified
// by lwIP. It is not important that the timing is absoluetly accurate.
	static int odd = 1;

	odd = !odd;

	ResetRxCntr++;

	tcp_fasttmr();
	if (odd) {
		tcp_slowtmr();
	}

// For providing an SW alternative for the SI #692601. Under heavy
// Rx traffic if at some point the Rx path becomes unresponsive, the
// following API call will ensures a SW reset of the Rx path. The
// API xemacpsif_resetrx_on_no_rxdata is called every 100 milliseconds.
// This ensures that if the above HW bug is hit, in the worst case,
// the Rx path cannot become unresponsive for more than 100
// milliseconds.

	if (ResetRxCntr >= RESET_RX_CNTR_LIMIT) {
		xemacpsif_resetrx_on_no_rxdata(app_netif);
		ResetRxCntr = 0;
	}

	XScuTimer_ClearInterruptStatus(TimerInstance);
}

static void s2mm_isr(void* CallbackRef) {

// Local variables
	u32 irq_status;
	int time_out;
	XAxiDma* p_dma_inst = (XAxiDma*) CallbackRef;

// Read pending interrupts
	irq_status = XAxiDma_IntrGetIrq(p_dma_inst, XAXIDMA_DEVICE_TO_DMA);

// Acknowledge pending interrupts
	XAxiDma_IntrAckIrq(p_dma_inst, irq_status, XAXIDMA_DEVICE_TO_DMA);

// If no interrupt is asserted, we do not do anything
	if (!(irq_status & XAXIDMA_IRQ_ALL_MASK))
		return;

// If error interrupt is asserted, raise error flag, reset the
// hardware to recover from the error, and return with no further
// processing.
	if ((irq_status & XAXIDMA_IRQ_ERROR_MASK)) {

		g_dma_err = 1;

		// Reset should never fail for transmit channel
		XAxiDma_Reset(p_dma_inst);

		time_out = RESET_TIMEOUT_COUNTER;
		while (time_out) {
			if (XAxiDma_ResetIsDone(p_dma_inst))
				break;

			time_out -= 1;
		}

		return;
	}

// Completion interrupt asserted
	if (irq_status & XAXIDMA_IRQ_IOC_MASK)
		g_s2mm_done = 1;

}

