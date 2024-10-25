/*
 * common.h
 *
 *  Created on: Sep 30, 2024
 *      Author: GeorgeVigelette
 */

#ifndef INC_COMMON_H_
#define INC_COMMON_H_

#include <stdio.h>
#include <stdint.h>

#define MAX_BITSTREAM_SIZE 200 * 1024
#define COMMAND_MAX_SIZE 2048

typedef enum {
	OW_START_BYTE = 0xAA,
	OW_END_BYTE = 0xDD,
} USTX_ProtocolTypes;


typedef enum {
	OW_ACK = 0xE0,
	OW_NAK = 0xE1,
	OW_CMD = 0xE2,
	OW_RESP = 0xE3,
	OW_DATA = 0xE4,
	OW_JSON = 0xE5,
	OW_FPGA = 0xE6,
	OW_CAMERA = 0xE7,
	OW_I2C_PASSTHRU = 0xE9,
	OW_BAD_PARSE = 0xEC,
	OW_BAD_CRC = 0xED,
	OW_UNKNOWN = 0xEE,
	OW_ERROR = 0xEF,

} UartPacketTypes;

typedef enum {
	OW_CODE_SUCCESS = 0x00,
	OW_CODE_IDENT_ERROR = 0xFD,
	OW_CODE_DATA_ERROR = 0xFE,
	OW_CODE_ERROR = 0xFF,
} UstxErrorCodes;

typedef enum {
	OW_CMD_PING = 0x00,
	OW_CMD_PONG = 0x01,
	OW_CMD_VERSION = 0x02,
	OW_CMD_ECHO = 0x03,
	OW_CMD_TOGGLE_LED = 0x04,
	OW_CMD_HWID = 0x05,
	OW_CMD_NOP = 0x0E,
	OW_CMD_RESET = 0x0F,
} UstxGlobalCommands;

typedef enum {
	OW_FPGA_SCAN = 0x10,
	OW_FPGA_ON = 0x11,
	OW_FPGA_OFF = 0x12,
	OW_FPGA_ACTIVATE = 0x13,
	OW_FPGA_ID = 0x14,
	OW_FPGA_ENTER_SRAM_PROG = 0x15,
	OW_FPGA_EXIT_SRAM_PROG = 0x16,
	OW_FPGA_ERASE_SRAM = 0x17,
	OW_FPGA_PROG_SRAM = 0x18,
	OW_FPGA_BITSTREAM = 0x19,
	OW_FPGA_USERCODE = 0x1D,
	OW_FPGA_STATUS = 0x1E,
	OW_FPGA_RESET = 0x1F,
} MotionFPGACommands;

typedef enum {
	OW_CAMERA_SCAN = 0x20,
	OW_CAMERA_ON = 0x21,
	OW_CAMERA_OFF = 0x22,
	OW_CAMERA_SET_CONFIG = 0x29,
	OW_CAMERA_STATUS = 0x2E,
	OW_CAMERA_RESET = 0x2F,
} MotionCAMERACommands;

typedef struct  {
	uint16_t id;
	uint8_t packet_type;
	uint8_t command;
	uint8_t addr;
	uint8_t reserved;
	uint16_t data_len;
	uint8_t* data;
	uint16_t crc;
} UartPacket;

#endif /* INC_COMMON_H_ */
