/*
 * 0X02C1B.c
 *
 *  Created on: Oct 15, 2024
 *      Author: GeorgeVigelette
 */

#include "0X02C1B.h"

#include <stdio.h>

static int X02C1B_write(uint16_t reg, uint8_t val)
{
	unsigned char data[3] = { reg >> 8, reg & 0xff, val};

	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

    if(HAL_I2C_Master_Transmit(&hi2c1, (uint16_t)(X02C1B_ADDRESS << 1), data, 3, HAL_MAX_DELAY)!= HAL_OK)
	{
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
	}

    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

	return 0;
}

static int X02C1B_read(uint16_t reg, uint8_t *val)
{
	uint8_t buf[2] = { reg >> 8, reg & 0xff };

	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

    if(HAL_I2C_Master_Transmit(&hi2c1, (uint16_t)(X02C1B_ADDRESS << 1), buf, 2, HAL_MAX_DELAY)!= HAL_OK)
	{
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
	}

    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

    if(HAL_I2C_Master_Receive(&hi2c1, (uint16_t)(X02C1B_ADDRESS << 1), val, 1, HAL_MAX_DELAY)!= HAL_OK)
	{
        /* Error_Handler() function is called when error occurs. */
        Error_Handler();
	}

    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

	return 0;
}


static int X02C1B_write_array(const struct regval_list *regs, int array_size)
{
	int i, ret;

	for (i = 0; i < array_size; i++) {
		ret = X02C1B_write(regs[i].addr, regs[i].data);
		if (ret < 0)
			return ret;
	}

	return 0;
}


int X02C1B_detect()
{

	uint8_t read;
	int ret;

    HAL_StatusTypeDef status;


	status = HAL_I2C_IsDeviceReady(&hi2c1, X02C1B_ADDRESS << 1, 2, 200); // Address shift left by 1 for read/write bit
	if (status != HAL_OK) {

		printf("Device Not Ready\r\n");
		return -1;
	}

	// 0xA8 read

	ret = X02C1B_write(X02C1B_SW_RESET, 0x01);
	if (ret < 0)
	{
		printf("Failed to write 0X02C1B_SW_RESET\r\n");
		return ret;
	}

	ret = X02C1B_read(X02C1B_EC_A_REG03, &read);
	if (ret < 0)
	{
		printf("Failed to read 0X02C1B_REG got %x\r\n", read);
		return ret;
	}

	printf("REG VAL: %02X\r\n", read);
	return 0;
}
