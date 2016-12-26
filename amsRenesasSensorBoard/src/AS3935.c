/*
 * AS3935.c
 *
 *  Created on: Dec 6, 2016
 *      Author: lycan
 */


#include "hal_data.h"
#include "I2C.h"
#include "AS3935.h"

ssp_err_t AS3935Initialize(void)
{
    return SSP_SUCCESS;
}

ssp_err_t AS3935UpdateSensors(i2c_master_instance_t * const i2c, uint8_t address, AS3935Data * const data)
{
    ssp_err_t error;

    error = I2CWriteByte(i2c, address, 0x00, false);
    if (error != SSP_SUCCESS)
        return error;

    error = I2CRead(i2c, address, (uint8_t *)data, 9, false);
    if (error != SSP_SUCCESS)
        return error;

    error = I2CWriteByte(i2c, address, 0x3A, false);
    if (error != SSP_SUCCESS)
        return error;

    error = I2CRead(i2c, address, (uint8_t *)(data + 9), 2, false);
    if (error != SSP_SUCCESS)
        return error;

    return SSP_SUCCESS;
}
