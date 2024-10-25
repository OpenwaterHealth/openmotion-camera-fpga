/*
 * if_commands.c
 *
 *  Created on: Sep 30, 2024
 *      Author: GeorgeVigelette
 */

#include "main.h"
#include "if_commands.h"
#include "common.h"
#include "jsmn.h"
#include "crosslink.h"
#include "i2c_master.h"
#include "i2c_protocol.h"
#include "ov5640.h"

#include <stdio.h>
#include <string.h>

extern uint8_t FIRMWARE_VERSION_DATA[3];
static uint32_t id_words[3] = {0};

static void process_basic_command(UartPacket *uartResp, UartPacket cmd)
{
	switch (cmd.command)
	{
	case OW_CMD_NOP:
		uartResp->command = OW_CMD_NOP;
		break;
	case OW_CMD_PING:
		uartResp->command = OW_CMD_PONG;
		break;
	case OW_CMD_PONG:
		uartResp->command = OW_CMD_PING;
		break;
	case OW_CMD_VERSION:
		uartResp->command = OW_CMD_VERSION;
		uartResp->data_len = sizeof(FIRMWARE_VERSION_DATA);
		uartResp->data = FIRMWARE_VERSION_DATA;
		break;
	case OW_CMD_HWID:
		uartResp->command = OW_CMD_HWID;
		id_words[0] = HAL_GetUIDw0();
		id_words[1] = HAL_GetUIDw1();
		id_words[2] = HAL_GetUIDw2();
		uartResp->data_len = 16;
		uartResp->data = (uint8_t *)&id_words;
		break;
	case OW_CMD_ECHO:
		// exact copy
		uartResp->id = cmd.id;
		uartResp->packet_type = cmd.packet_type;
		uartResp->command = cmd.command;
		uartResp->data_len = cmd.data_len;
		uartResp->data = cmd.data;
		break;
	case OW_CMD_TOGGLE_LED:
		uartResp->id = cmd.id;
		uartResp->packet_type = cmd.packet_type;
		uartResp->command = cmd.command;
		HAL_GPIO_TogglePin(LD2_GPIO_Port, LD2_Pin);
		break;
	default:
		uartResp->data_len = 0;
		uartResp->packet_type = OW_UNKNOWN;
		// uartResp.data = (uint8_t*)&cmd.tag;
		break;
	}
}

extern uint8_t bitstream_buffer[];
uint8_t* ptrBitstream;
uint32_t Bitstream_Length;
static void process_fpga_commands(UartPacket *uartResp, UartPacket cmd)
{
	switch (cmd.command)
	{
	case OW_FPGA_ON:
		uartResp->command = OW_FPGA_ON;
		fpga_on();
		break;
	case OW_FPGA_OFF:
		uartResp->command = OW_FPGA_OFF;
		fpga_off();
		break;
	case OW_FPGA_ACTIVATE:
		uartResp->command = OW_FPGA_ACTIVATE;
		fpga_send_activation();
		break;
	case OW_FPGA_ID:
		uartResp->command = OW_FPGA_ID;
#if 0
		id_words[0] = HAL_GetUIDw0();
		id_words[1] = HAL_GetUIDw1();
		id_words[2] = HAL_GetUIDw2();
		uartResp->data_len = 16;
		uartResp->data = (uint8_t *)&id_words;
#endif
		fpga_checkid();
		break;
	case OW_FPGA_ENTER_SRAM_PROG:
		uartResp->command = OW_FPGA_ENTER_SRAM_PROG;
		fpga_enter_sram_prog_mode();
		break;
	case OW_FPGA_EXIT_SRAM_PROG:
		uartResp->command = OW_FPGA_EXIT_SRAM_PROG;
		fpga_exit_prog_mode();
		break;
	case OW_FPGA_ERASE_SRAM:
		uartResp->command = OW_FPGA_ERASE_SRAM;
		fpga_erase_sram();
		break;
	case OW_FPGA_PROG_SRAM:
		uartResp->command = OW_FPGA_PROG_SRAM;
		fpga_program_sram(true, 0, 0);
		break;
	case OW_FPGA_USERCODE:
		uartResp->command = OW_FPGA_USERCODE;
		fpga_read_usercode(false);
		break;
	case OW_FPGA_BITSTREAM:
		uartResp->command = OW_FPGA_BITSTREAM;
		//printf("ADDR: %d Length: %d \r\n", cmd.addr, cmd.data_len);
		if(cmd.reserved == 0){
			// printf("Received BLOCK: %d\r\n", cmd.addr);
			if(cmd.addr == 0)
			{
				uint8_t writeArr[4];
				writeArr[0] = 0x7A; writeArr[1] = 0x00; writeArr[2] = 0x00; writeArr[3] = 0x00;
				memset(bitstream_buffer, 0, MAX_BITSTREAM_SIZE);
				ptrBitstream = bitstream_buffer;
				Bitstream_Length = 0;
				memcpy(ptrBitstream, writeArr, 4);  // Copy command data
				ptrBitstream += 4;
				Bitstream_Length+=4;
			}

			memcpy(ptrBitstream, cmd.data, cmd.data_len);  // Copy data
			ptrBitstream += cmd.data_len;
			Bitstream_Length+=cmd.data_len;
		}else{
			printf("Programming BITSTREAM\r\n");
			fpga_program_sram(false, bitstream_buffer, Bitstream_Length);
		}
		break;
	case OW_FPGA_STATUS:
		uartResp->command = OW_FPGA_STATUS;
		fpga_read_status();
		break;
	case OW_FPGA_RESET:
		uartResp->command = OW_FPGA_RESET;
		fpga_reset();
		break;
	case OW_FPGA_SCAN:
	default:
		uartResp->data_len = 0;
		uartResp->packet_type = OW_UNKNOWN;
		// uartResp.data = (uint8_t*)&cmd.tag;
		break;
	}
}


static void process_camera_commands(UartPacket *uartResp, UartPacket cmd)
{
	switch (cmd.command)
	{
	case OW_CAMERA_SCAN:
		uartResp->command = OW_CAMERA_SCAN;
		printf("Reading Camera ID\r\n");
		OV5640_detect();
		break;
	case OW_CAMERA_ON:
	case OW_CAMERA_SET_CONFIG:
		uartResp->command = OW_CAMERA_SET_CONFIG;
		printf("Configuring sensor for 1080P YUV\r\n");
		OV5640_set_1080p_YUV();
		break;
	case OW_CAMERA_OFF:
	case OW_CAMERA_STATUS:
	case OW_CAMERA_RESET:
	default:
		uartResp->data_len = 0;
		uartResp->packet_type = OW_UNKNOWN;
		// uartResp.data = (uint8_t*)&cmd.tag;
		break;
	}

}

static void JSON_ProcessCommand(UartPacket *uartResp, UartPacket cmd)
{
	// json parser
    jsmn_parser parser;
    parser.size = sizeof(parser);
    jsmn_init(&parser, NULL);
    jsmntok_t t[16];
    jsmnerr_t ret = jsmn_parse(&parser, (char *)cmd.data, cmd.data_len, t,
				 sizeof(t) / sizeof(t[0]), NULL);
    printf("Found %d Tokens\r\n", ret);
	switch (cmd.command)
	{
	case OW_CMD_NOP:
		uartResp->command = OW_CMD_NOP;
		break;
	case OW_CMD_ECHO:
		// exact copy
		uartResp->id = cmd.id;
		uartResp->packet_type = cmd.packet_type;
		uartResp->command = cmd.command;
		uartResp->data_len = cmd.data_len;
		uartResp->data = cmd.data;
		break;
	default:
		uartResp->data_len = 0;
		uartResp->packet_type = OW_UNKNOWN;
		break;
	}
}

static void print_uart_packet(const UartPacket* packet) {
    printf("ID: 0x%04X\r\n", packet->id);
    printf("Packet Type: 0x%02X\r\n", packet->packet_type);
    printf("Command: 0x%02X\r\n", packet->command);
    printf("Data Length: %d\r\n", packet->data_len);
    printf("CRC: 0x%04X\r\n", packet->crc);
    printf("Data: ");
    for (int i = 0; i < packet->data_len; i++) {
        printf("0x%02X ", packet->data[i]);
    }
    printf("\r\n");
}

UartPacket process_if_command(UartPacket cmd)
{
	UartPacket uartResp;
	I2C_TX_Packet i2c_packet;

	uartResp.id = cmd.id;
	uartResp.packet_type = OW_RESP;
	uartResp.data_len = 0;
	uartResp.data = 0;
	switch (cmd.packet_type)
	{
	case OW_JSON:
		JSON_ProcessCommand(&uartResp, cmd);
		break;
	case OW_CMD:
		process_basic_command(&uartResp, cmd);
		break;
	case OW_FPGA:
		process_fpga_commands(&uartResp, cmd);
		break;
	case OW_CAMERA:
		process_camera_commands(&uartResp, cmd);
		break;
	case OW_I2C_PASSTHRU:

		print_uart_packet(&cmd);

        // printBuffer(cmd.data, 10);
		i2c_packet_fromBuffer(cmd.data, &i2c_packet);
		// i2c_tx_packet_print(&i2c_packet);

		HAL_Delay(20);
		send_buffer_to_slave(cmd.command, cmd.data, 10);

		break;
	default:
		uartResp.data_len = 0;
		uartResp.packet_type = OW_UNKNOWN;
		// uartResp.data = (uint8_t*)&cmd.tag;
		break;
	}

	return uartResp;

}
