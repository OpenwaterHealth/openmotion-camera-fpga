/*
 * OV5640.c
 *
 *  Created on: Feb 24, 2024
 *      Author: gvigelet
 */
#include "ov5640.h"
#include <stdio.h>


static struct regval_list OV5640_1080p15_YUV422[] = {
	{0x3008, 0x0042},
	{0x3103, 0x0003},
	{0x3017, 0x0000},
	{0x3018, 0x0000},
	{0x3034, 0x0018},
	{0x3035, 0x0011},
	{0x3036, 0x0054},
	{0x3037, 0x0013},
	{0x3108, 0x0001},
	{0x3820, 0x0047},
	{0x3821, 0x0000},
	{0x3814, 0x0011},
	{0x3815, 0x0011},
	{0x3800, 0x0001},
	{0x3801, 0x0050},
	{0x3802, 0x0001},
	{0x3803, 0x00B2},
	{0x3804, 0x0008},
	{0x3805, 0x00EF},
	{0x3806, 0x0005},
	{0x3807, 0x00F1},
	{0x3808, 0x0007},
	{0x3809, 0x0080},
	{0x380A, 0x0004},
	{0x380B, 0x0038},
	{0x380C, 0x0009},
	{0x380D, 0x00C4},
	{0x380E, 0x0004},
	{0x380F, 0x0060},
	{0x3810, 0x0000},
	{0x3811, 0x0010},
	{0x3812, 0x0000},
	{0x3813, 0x0004},
	{0x3618, 0x0004},
	{0x3612, 0x002B},
	{0x3708, 0x0064},
	{0x3709, 0x0012},
	{0x370C, 0x0000},
	{0x3A02, 0x0004},
	{0x3A03, 0x0060},
	{0x3A08, 0x0001},
	{0x3A09, 0x0050},
	{0x3A0A, 0x0001},
	{0x3A0B, 0x0018},
	{0x3A0E, 0x0003},
	{0x3A0D, 0x0004},
	{0x3A14, 0x0004},
	{0x3A15, 0x0060},
	{0x3002, 0x001C},
	{0x3006, 0x00C3},
	{0x300E, 0x0045},
	{0x302E, 0x0008},
	{0x4300, 0x0030},
	{0x501F, 0x0000},
	{0x4713, 0x0002},
	{0x4407, 0x0004},
	{0x460B, 0x0037},
	{0x460C, 0x0020},
	{0x4827, 0x0016},
	{0x3824, 0x0004},
	{0x3008, 0x0002},
	{0x0000, 0x0000},
	{0x0023, 0x0007},
	{0x0024, 0x0080},
	{0x0021, 0x0004},
	{0x0022, 0x0038},
	{0x0025, 0x0000},
};

static int OV5640_write(uint16_t reg, uint8_t val)
{
	unsigned char data[3] = { reg >> 8, reg & 0xff, val};

	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

    if(HAL_I2C_Master_Transmit(&hi2c1, (uint16_t)(OV5640_ADDRESS << 1), data, 3, HAL_MAX_DELAY)!= HAL_OK)
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

static int OV5640_read(uint16_t reg, uint8_t *val)
{
	uint8_t buf[2] = { reg >> 8, reg & 0xff };

	// Check if the I2C handle is valid
    if (HAL_I2C_GetState(&hi2c1) != HAL_I2C_STATE_READY) {
    	printf("===> ERROR I2C Not in ready state\r\n");
        return -1; // I2C is not in a ready state
    }

    if(HAL_I2C_Master_Transmit(&hi2c1, (uint16_t)(OV5640_ADDRESS << 1), buf, 2, HAL_MAX_DELAY)!= HAL_OK)
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

    if(HAL_I2C_Master_Receive(&hi2c1, (uint16_t)(OV5640_ADDRESS << 1), val, 1, HAL_MAX_DELAY)!= HAL_OK)
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


static int OV5640_write_array(const struct regval_list *regs, int array_size)
{
	int i, ret;

	for (i = 0; i < array_size; i++) {
		ret = OV5640_write(regs[i].addr, regs[i].data);
		if (ret < 0)
			return ret;
	}

	return 0;
}

int OV5640_stream_on()
{
	int ret;

	ret = OV5640_write(OV5640_REG_FRAME_OFF_NUMBER, 0x00);
	if (ret < 0)
		return ret;

	return OV5640_write(OV5640_REG_PAD_OUT, 0x00);
}

int OV5640_stream_off()
{
	int ret;

	ret = OV5640_write(OV5640_REG_FRAME_OFF_NUMBER, 0x0f);
	if (ret < 0)
		return ret;

	return OV5640_write(OV5640_REG_PAD_OUT, 0x01);
}

int OV5640_detect()
{
	uint8_t read;
	uint16_t chip_id;
	int ret;

    HAL_StatusTypeDef status;

	status = HAL_I2C_IsDeviceReady(&hi2c1, OV5640_ADDRESS << 1, 2, 200); // Address shift left by 1 for read/write bit
	if (status != HAL_OK) {

		printf("Device Not Ready\r\n");
		return -1;
	}

	ret = OV5640_write(OV5640_SW_RESET, 0x01);
	if (ret < 0)
	{
		printf("Failed to write OV5640_SW_RESET\r\n");
		return ret;
	}

	ret = OV5640_read(OV5640_REG_CHIPID_H, &read);
	if (ret < 0)
	{
		printf("Failed to read OV5640_REG_CHIPID_H got %x\r\n", read);
		return ret;
	}
	chip_id = read << 8;

	if (read != 0x56) {
		printf("ID High expected 0x56 got %x", read);
		return -1;
	}

	ret = OV5640_read(OV5640_REG_CHIPID_L, &read);
	if (ret < 0)
	{
		printf("Failed to read OV5640_REG_CHIPID_L got %x\r\n", read);
		return ret;
	}

	chip_id = chip_id | read;

	if (read != 0x40) {
		printf("ID Low expected 0x47 got %x", read);
		return -1;
	}

	printf("CHIP ID: %04X\r\n", chip_id);
	return 0;
}

int OV5640_write_register(uint16_t reg, uint8_t value)
{
	return 0;
}

int OV5640_read_register(uint16_t reg, uint8_t *value)
{
	return 0;
}

int OV5640_set_1080p_YUV()
{
	int ret = 0;

	ret = OV5640_write_array(OV5640_1080p15_YUV422, ARRAY_SIZE(OV5640_1080p15_YUV422));
	if(ret<0){
		printf("Failed to write 1080p YUV Registers\r\n");
	}
	return ret;
}

