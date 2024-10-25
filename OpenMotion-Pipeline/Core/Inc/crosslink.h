/*
 * crosslink.h
 *
 *  Created on: Aug 6, 2024
 *      Author: gvigelet
 */

#ifndef INC_CROSSLINK_H_
#define INC_CROSSLINK_H_
#include "main.h"
#include <stdbool.h>

void fpga_reset();
int fpga_send_activation();
void fpga_on();
void fpga_off();
int fpga_checkid();
int fpga_enter_sram_prog_mode();
int fpga_erase_sram();
int fpga_read_usercode();
int fpga_read_status();
int fpga_exit_prog_mode();

int fpga_program_sram(bool rom_bitstream, uint8_t* pData, uint32_t Data_Len);

int program_bitstream(void);

#endif /* INC_CROSSLINK_H_ */
