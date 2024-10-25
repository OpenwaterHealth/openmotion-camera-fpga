################################################################################
# Automatically-generated file. Do not edit!
# Toolchain: GNU Tools for STM32 (12.3.rel1)
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../Core/Src/0X02C1B.c \
../Core/Src/crosslink.c \
../Core/Src/freertos.c \
../Core/Src/i2c_master.c \
../Core/Src/i2c_protocol.c \
../Core/Src/if_commands.c \
../Core/Src/jsmn.c \
../Core/Src/logging.c \
../Core/Src/lwrb.c \
../Core/Src/main.c \
../Core/Src/ov5640.c \
../Core/Src/stm32h7xx_hal_msp.c \
../Core/Src/stm32h7xx_hal_timebase_tim.c \
../Core/Src/stm32h7xx_it.c \
../Core/Src/syscalls.c \
../Core/Src/sysmem.c \
../Core/Src/system_stm32h7xx.c \
../Core/Src/uart_comms.c \
../Core/Src/utils.c 

OBJS += \
./Core/Src/0X02C1B.o \
./Core/Src/crosslink.o \
./Core/Src/freertos.o \
./Core/Src/i2c_master.o \
./Core/Src/i2c_protocol.o \
./Core/Src/if_commands.o \
./Core/Src/jsmn.o \
./Core/Src/logging.o \
./Core/Src/lwrb.o \
./Core/Src/main.o \
./Core/Src/ov5640.o \
./Core/Src/stm32h7xx_hal_msp.o \
./Core/Src/stm32h7xx_hal_timebase_tim.o \
./Core/Src/stm32h7xx_it.o \
./Core/Src/syscalls.o \
./Core/Src/sysmem.o \
./Core/Src/system_stm32h7xx.o \
./Core/Src/uart_comms.o \
./Core/Src/utils.o 

C_DEPS += \
./Core/Src/0X02C1B.d \
./Core/Src/crosslink.d \
./Core/Src/freertos.d \
./Core/Src/i2c_master.d \
./Core/Src/i2c_protocol.d \
./Core/Src/if_commands.d \
./Core/Src/jsmn.d \
./Core/Src/logging.d \
./Core/Src/lwrb.d \
./Core/Src/main.d \
./Core/Src/ov5640.d \
./Core/Src/stm32h7xx_hal_msp.d \
./Core/Src/stm32h7xx_hal_timebase_tim.d \
./Core/Src/stm32h7xx_it.d \
./Core/Src/syscalls.d \
./Core/Src/sysmem.d \
./Core/Src/system_stm32h7xx.d \
./Core/Src/uart_comms.d \
./Core/Src/utils.d 


# Each subdirectory must supply rules for building sources it contributes
Core/Src/%.o Core/Src/%.su Core/Src/%.cyclo: ../Core/Src/%.c Core/Src/subdir.mk
	arm-none-eabi-gcc "$<" -mcpu=cortex-m7 -std=gnu11 -g3 -DDEBUG -DUSE_HAL_DRIVER -DSTM32H753xx -c -I../USB_DEVICE/App -I../USB_DEVICE/Target -I../Core/Inc -I../Drivers/STM32H7xx_HAL_Driver/Inc -I../Drivers/STM32H7xx_HAL_Driver/Inc/Legacy -I../Middlewares/ST/STM32_USB_Device_Library/Core/Inc -I../Middlewares/ST/STM32_USB_Device_Library/Class/CDC/Inc -I../Drivers/CMSIS/Device/ST/STM32H7xx/Include -I../Drivers/CMSIS/Include -I../Middlewares/Third_Party/FreeRTOS/Source/include -I../Middlewares/Third_Party/FreeRTOS/Source/CMSIS_RTOS_V2 -I../Middlewares/Third_Party/FreeRTOS/Source/portable/GCC/ARM_CM4F -I../LWIP/App -I../LWIP/Target -I../Middlewares/Third_Party/LwIP/src/include -I../Middlewares/Third_Party/LwIP/system -I../Drivers/BSP/Components/lan8742 -I../Middlewares/Third_Party/LwIP/src/include/netif/ppp -I../Middlewares/Third_Party/LwIP/src/include/lwip -I../Middlewares/Third_Party/LwIP/src/include/lwip/apps -I../Middlewares/Third_Party/LwIP/src/include/lwip/priv -I../Middlewares/Third_Party/LwIP/src/include/lwip/prot -I../Middlewares/Third_Party/LwIP/src/include/netif -I../Middlewares/Third_Party/LwIP/src/include/compat/posix -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/arpa -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/net -I../Middlewares/Third_Party/LwIP/src/include/compat/posix/sys -I../Middlewares/Third_Party/LwIP/src/include/compat/stdc -I../Middlewares/Third_Party/LwIP/system/arch -O0 -ffunction-sections -fdata-sections -Wall -fstack-usage -fcyclomatic-complexity -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" --specs=nano.specs -mfpu=fpv5-d16 -mfloat-abi=hard -mthumb -o "$@"

clean: clean-Core-2f-Src

clean-Core-2f-Src:
	-$(RM) ./Core/Src/0X02C1B.cyclo ./Core/Src/0X02C1B.d ./Core/Src/0X02C1B.o ./Core/Src/0X02C1B.su ./Core/Src/crosslink.cyclo ./Core/Src/crosslink.d ./Core/Src/crosslink.o ./Core/Src/crosslink.su ./Core/Src/freertos.cyclo ./Core/Src/freertos.d ./Core/Src/freertos.o ./Core/Src/freertos.su ./Core/Src/i2c_master.cyclo ./Core/Src/i2c_master.d ./Core/Src/i2c_master.o ./Core/Src/i2c_master.su ./Core/Src/i2c_protocol.cyclo ./Core/Src/i2c_protocol.d ./Core/Src/i2c_protocol.o ./Core/Src/i2c_protocol.su ./Core/Src/if_commands.cyclo ./Core/Src/if_commands.d ./Core/Src/if_commands.o ./Core/Src/if_commands.su ./Core/Src/jsmn.cyclo ./Core/Src/jsmn.d ./Core/Src/jsmn.o ./Core/Src/jsmn.su ./Core/Src/logging.cyclo ./Core/Src/logging.d ./Core/Src/logging.o ./Core/Src/logging.su ./Core/Src/lwrb.cyclo ./Core/Src/lwrb.d ./Core/Src/lwrb.o ./Core/Src/lwrb.su ./Core/Src/main.cyclo ./Core/Src/main.d ./Core/Src/main.o ./Core/Src/main.su ./Core/Src/ov5640.cyclo ./Core/Src/ov5640.d ./Core/Src/ov5640.o ./Core/Src/ov5640.su ./Core/Src/stm32h7xx_hal_msp.cyclo ./Core/Src/stm32h7xx_hal_msp.d ./Core/Src/stm32h7xx_hal_msp.o ./Core/Src/stm32h7xx_hal_msp.su ./Core/Src/stm32h7xx_hal_timebase_tim.cyclo ./Core/Src/stm32h7xx_hal_timebase_tim.d ./Core/Src/stm32h7xx_hal_timebase_tim.o ./Core/Src/stm32h7xx_hal_timebase_tim.su ./Core/Src/stm32h7xx_it.cyclo ./Core/Src/stm32h7xx_it.d ./Core/Src/stm32h7xx_it.o ./Core/Src/stm32h7xx_it.su ./Core/Src/syscalls.cyclo ./Core/Src/syscalls.d ./Core/Src/syscalls.o ./Core/Src/syscalls.su ./Core/Src/sysmem.cyclo ./Core/Src/sysmem.d ./Core/Src/sysmem.o ./Core/Src/sysmem.su ./Core/Src/system_stm32h7xx.cyclo ./Core/Src/system_stm32h7xx.d ./Core/Src/system_stm32h7xx.o ./Core/Src/system_stm32h7xx.su ./Core/Src/uart_comms.cyclo ./Core/Src/uart_comms.d ./Core/Src/uart_comms.o ./Core/Src/uart_comms.su ./Core/Src/utils.cyclo ./Core/Src/utils.d ./Core/Src/utils.o ./Core/Src/utils.su

.PHONY: clean-Core-2f-Src

