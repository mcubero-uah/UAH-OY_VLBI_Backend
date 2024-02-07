/****************** Include Files ********************/
#include "spi_3_wire_ctrl_hw.h"
#include "xil_types.h"



/************************** Device Struct ****************************/
typedef struct {
	 uint32_t base_addr;
	 uint32_t addr_reg;
} spi_ctrl_t;

/************************** Function Prototypes ****************************/
int spi_ctrl_set_cpol(spi_ctrl_t *drv, int CPOL);
int spi_ctrl_get_cpol(spi_ctrl_t *drv);
int spi_ctrl_set_cpha(spi_ctrl_t *drv, int CPHA);
int spi_ctrl_get_cpha(spi_ctrl_t *drv);
int spi_ctrl_set_rst(spi_ctrl_t *drv, int reset_bit);
int spi_ctrl_get_enable(spi_ctrl_t *drv);
int spi_ctrl_get_busy(spi_ctrl_t *drv);
int spi_ctrl_set_addr(spi_ctrl_t *drv, int addr);
int spi_ctrl_set_clk_div(spi_ctrl_t *drv, int clk_div);
int spi_ctrl_initialize(spi_ctrl_t *drv, uint32_t base_addr,  int addr, int clk_div);
int spi_ctrl_set_command(spi_ctrl_t *drv, int command);
int spi_ctrl_write(spi_ctrl_t *drv, int data, int dwidth);
int spi_ctrl_read(spi_ctrl_t *drv, int dwidth);


