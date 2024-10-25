/*
 * OV5640.h
 *
 *  Created on: Feb 24, 2024
 *      Author: gvigelet
 */

#ifndef INC_OV5640_H_
#define INC_OV5640_H_

#include "main.h"
/*
 * From the datasheet, "20ms after PWDN goes low or 20ms after RESETB goes
 * high if reset is inserted after PWDN goes high, host can access sensor's
 * SCCB to initialize sensor."
 */
#define PWDN_ACTIVE_DELAY_MS	20

#define OV5640_ADDRESS			0x3C //0x36

#define OV5640_SW_STANDBY		0x0100
#define OV5640_SW_RESET			0x0103
#define OV5640_REG_CHIPID_H		0x300a
#define OV5640_REG_CHIPID_L		0x300b
#define OV5640_REG_PAD_OUT		0x300d
#define OV5640_REG_EXP_HI		0x3500
#define OV5640_REG_EXP_MID		0x3501
#define OV5640_REG_EXP_LO		0x3502
#define OV5640_REG_AEC_AGC		0x3503
#define OV5640_REG_GAIN_HI		0x350a
#define OV5640_REG_GAIN_LO		0x350b
#define OV5640_REG_VTS_HI		0x380e
#define OV5640_REG_VTS_LO		0x380f
#define OV5640_REG_FRAME_OFF_NUMBER	0x4202
#define OV5640_REG_MIPI_CTRL00		0x4800
#define OV5640_REG_AWB			0x5001
#define OV5640_REG_ISPCTRL3D		0x503d

/* min/typical/max system clock (xclk) frequencies */
#define OV5640_XCLK_MIN  6000000
#define OV5640_XCLK_MAX 54000000

/* OV5640 native and active pixel array size */
#define OV5640_NATIVE_WIDTH			2624U
#define OV5640_NATIVE_HEIGHT		1964U

#define OV5640_PIXEL_ARRAY_LEFT		16U
#define OV5640_PIXEL_ARRAY_TOP		14U
#define OV5640_PIXEL_ARRAY_WIDTH	2592U
#define OV5640_PIXEL_ARRAY_HEIGHT	1944U

#define OV5640_VBLANK_MIN		24U
#define OV5640_VTS_MAX			3375U

#define OV5640_EXPOSURE_MIN		4
#define OV5640_EXPOSURE_STEP		1
#define OV5640_EXPOSURE_DEFAULT		1000
#define OV5640_EXPOSURE_MAX		65535

#define ARRAY_SIZE(array) \
    (sizeof(array) / sizeof(*array))

struct regval_list {
	uint16_t addr;
	uint8_t data;
};

static const char * const OV5640_test_pattern_menu[] = {
	"Disabled",
	"Color Bars",
	"Color Squares",
	"Random Data",
};


static const uint8_t OV5640_test_pattern_val[] = {
	0x00,	/* Disabled */
	0x80,	/* Color Bars */
	0x82,	/* Color Squares */
	0x81,	/* Random Data */
};

int OV5640_detect();
int OV5640_stream_on();
int OV5640_stream_off();
int OV5640_set_1080p_YUV();
int OV5640_write_register(uint16_t reg, uint8_t value);
int OV5640_read_register(uint16_t reg, uint8_t *value);


#endif /* INC_OV5640_H_ */
