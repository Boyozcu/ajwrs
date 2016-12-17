/*
 * ENS210.c
 *
 *  Created on: Dec 6, 2016
 *      Author: lycan
 */

#include "hal_data.h"
#include "ENS210.h"
#include "I2C.h"
#include "Timer.h"
#include <stdio.h>

const struct
{
    uint8_t PART_ID;
    uint8_t UID;
    uint8_t SYS_CTRL;
    uint8_t SYS_STAT;
    uint8_t SENS_RUN;
    uint8_t SENS_START;
    uint8_t SENS_STOP;
    uint8_t SENS_STAT;
    uint8_t T_VAL;
    uint8_t H_VAL;
} ENS210RegisterAddresses =
{ 0x00, // PART_ID
  0x04, // UID
  0x10, // SYS_CTRL
  0x11, // SYS_STAT
  0x21, // SENS_RUN
  0x22, // SENS_START
  0x23, // SENS_STOP
  0x24, // SENS_STAT
  0x30, // T_VAL
  0x33  // H_VAL
        };

ssp_err_t ENS210Initialize(void)
{
    return SSP_SUCCESS;
}

ssp_err_t ENS210Open(uint8_t address)
{
    ssp_err_t error;

    // Disable Low Power Mode
    error = ENS210SetSystemControl (address, 0x00);
    if (error != SSP_SUCCESS)
        return error;

    // Wait for sensor to be active
    uint8_t status = 0;
    while ((status & 0x01) == 0)
    {
        error = ENS210GetSystemStatus (address, &status);
        if (error != SSP_SUCCESS)
            return error;
        printf (".");
        TimerSleepMs (50);
    }

    // Enable Continuous Measurements
    error = ENS210SetSensorRunMode (address, 0x03);
    if (error != SSP_SUCCESS)
        return error;

    // Start R & H Measurements
    error = ENS210SetSensorStart (address, 0x03);
    if (error != SSP_SUCCESS)
        return error;

    return SSP_SUCCESS;
}

ssp_err_t ENS210SetSystemControl(uint8_t address, uint8_t const systemControl)
{
    return I2CWriteRegister (address, ENS210RegisterAddresses.SYS_CTRL, systemControl, false);
}

ssp_err_t ENS210GetSystemControl(uint8_t address, uint8_t * const systemControl)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SYS_CTRL, systemControl, 1, false);
}

ssp_err_t ENS210GetSystemStatus(uint8_t address, uint8_t * const systemStatus)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SYS_STAT, systemStatus, 1, false);
}

ssp_err_t ENS210SetSensorRunMode(uint8_t address, uint8_t const sensorRunMode)
{
    return I2CWriteRegister (address, ENS210RegisterAddresses.SENS_RUN, *((uint8_t *) &sensorRunMode), false);
}

ssp_err_t ENS210GetSensorRunMode(uint8_t address, uint8_t * const sensorRunMode)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SENS_RUN, sensorRunMode, 1, false);
}

ssp_err_t ENS210SetSensorStart(uint8_t address, uint8_t const sensorStart)
{
    return I2CWriteRegister (address, ENS210RegisterAddresses.SENS_START, *((uint8_t *) &sensorStart), false);
}
ssp_err_t ENS210GetSensorStart(uint8_t address, uint8_t * const sensorStart)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SENS_START, sensorStart, 1, false);
}

ssp_err_t ENS210SetSensorStop(uint8_t address, uint8_t const sensorStop)
{
    return I2CWriteRegister (address, ENS210RegisterAddresses.SENS_STOP, *((uint8_t *) &sensorStop), false);
}

ssp_err_t ENS210GetSensorStop(uint8_t address, uint8_t * const sensorStop)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SENS_STOP, sensorStop, 1, false);
}

ssp_err_t ENS210GetSensorStatus(uint8_t address, uint8_t * const sensorStatus)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.SENS_STOP, sensorStatus, 1, false);
}

ssp_err_t ENS210ChipId(uint8_t address, uint16_t * const chipId)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.PART_ID, (uint8_t *) chipId, 2, false);
}

ssp_err_t ENS210UniqueId(uint8_t address, uint8_t * const uniqueId)
{
    return I2CReadRegister (address, ENS210RegisterAddresses.UID, uniqueId, 8, false);
}

ssp_err_t ENS210UpdateSensors(uint8_t address, ENS210Data * const data)
{
    ssp_err_t error;

    uint8_t buffer[6] =
    { 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 };
    uint16_t rawTemp;
    uint16_t rawHumi;

    error = I2CWriteByte (address, ENS210RegisterAddresses.T_VAL, true);
    if (error != SSP_SUCCESS)
        return error;
    error = I2CRead (address, buffer, 6, false);
    if (error != SSP_SUCCESS)
        return error;

    // Cast Data
    rawTemp = (uint16_t) ((buffer[1] << 8) | buffer[2]);
    rawHumi = (uint16_t) ((buffer[4] << 8) | buffer[5]);

    data->Temperature = (float) ((rawTemp / 64.0) - 273.15);
    data->Humidity = (float) ((rawHumi / 512.0));

    return SSP_SUCCESS;
}
