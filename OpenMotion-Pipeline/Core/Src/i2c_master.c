/*
 * i2c_master.c
 *
 *  Created on: Mar 30, 2024
 *      Author: gvigelet
 */

#include "main.h"
#include "i2c_protocol.h"
#include "i2c_master.h"
#include "utils.h"
#include <stdio.h>
#include <string.h>

#define I2C_DEVICE hi2c1

uint8_t I2C_scan(uint8_t* addr_list, size_t list_size, bool display) {

	uint8_t found = 0;

    // Iterate through all possible 7-bit addresses
    for (uint8_t address = 0x00; address <= 0x7F; address++) {
        HAL_StatusTypeDef status;
        status = HAL_I2C_IsDeviceReady(&I2C_DEVICE, address << 1, 2, 50); // Address shift left by 1 for read/write bit
        if (status == HAL_OK) {
        	if(addr_list != NULL && found < list_size) {
        		addr_list[found] = address;
        	}
        	found++;
        	if(display)
        	{
        		printf("%2x ", address);
        	}
        }else{
        	if(display)
        	{
        		printf("-- ");
        	}
        }
        if (display && (address + 1) % 16 == 0)  printf("\r\n");
    }

	if(display)
	{
		printf("\r\n");
	    fflush(stdout);
	}

    return found;
}

uint8_t send_buffer_to_slave(uint8_t slave_addr, uint8_t* pBuffer, uint16_t buf_len)
{
	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&I2C_DEVICE) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return 1; // I2C is not in a ready state
    }

	// printf("===> Sending Packet %d Bytes\r\n", buf_len);
    if(HAL_I2C_Master_Transmit(&I2C_DEVICE, (uint16_t)(slave_addr << 1), pBuffer, buf_len, HAL_MAX_DELAY)!= HAL_OK)
	{
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
	}


	return 0;
}

uint8_t read_status_register_of_slave(uint8_t slave_addr, uint8_t* pBuffer, uint16_t max_len)
{
	uint8_t rx_len = sizeof(I2C_STATUS_Packet);
	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&I2C_DEVICE) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return 1; // I2C is not in a ready state
    }

	// printf("===> Receive Status Packet %d Bytes\r\n", rx_len);

#if 0

	if(HAL_I2C_Master_Receive(&I2C_DEVICE, (uint16_t)(slave_addr << 1), pBuffer, rx_len, HAL_MAX_DELAY)!= HAL_OK)
	{
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
	}

#else

    if(HAL_I2C_Mem_Read(&I2C_DEVICE, (uint16_t)(slave_addr << 1), 0x00, I2C_MEMADD_SIZE_8BIT, pBuffer, rx_len, HAL_MAX_DELAY)!= HAL_OK)
    {
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
    }

#endif

	return rx_len;
}

uint8_t read_data_register_of_slave(uint8_t slave_addr, uint8_t* pBuffer, size_t rx_len)
{
	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&I2C_DEVICE) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return 1; // I2C is not in a ready state
    }

	// printf("===> Receive Data Packet %d Bytes\r\n", rx_len);

    if(HAL_I2C_Mem_Read(&I2C_DEVICE, (uint16_t)(slave_addr << 1), 0x01, I2C_MEMADD_SIZE_8BIT, pBuffer, rx_len, HAL_MAX_DELAY)!= HAL_OK)
    {
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
    }

	return rx_len;
}

#if 0
void HAL_I2C_MasterTxCpltCallback(I2C_HandleTypeDef *I2cHandle)
{
	printf("TX Completed\r\n");
}

void HAL_I2C_MasterRxCpltCallback(I2C_HandleTypeDef *I2cHandle)
{
	printf("RX Completed\r\n");

}

void HAL_I2C_MemTxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	printf("HAL_I2C_MemTxCpltCallback\r\n");
}

void HAL_I2C_MemRxCpltCallback(I2C_HandleTypeDef *hi2c)
{
	printf("HAL_I2C_MemRxCpltCallback\r\n");
}
#endif

void reset_slaves()
{
    printf("Reset Slaves..\r\n");
}
