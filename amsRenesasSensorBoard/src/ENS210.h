/*
 * ENS210.h
 *
 *  Created on: Dec 6, 2016
 *      Author: lycan
 */

#ifndef ENS210_H_
#define ENS210_H_

typedef struct _ENS210Data
{
    float Temperature;
    float Humidity;
} ENS210Data;

ssp_err_t ENS210Initialize(void);
ssp_err_t ENS210Open(uint8_t address);
ssp_err_t ENS210ChipId(uint8_t address, uint16_t * const chipId);
ssp_err_t ENS210UniqueId(uint8_t address, uint8_t * const uniqueId);
ssp_err_t ENS210UpdateSensors(uint8_t address, ENS210Data * const data);
ssp_err_t ENS210SetSystemControl(uint8_t address, uint8_t systemControl);
ssp_err_t ENS210GetSystemControl(uint8_t address, uint8_t * const systemControl);
ssp_err_t ENS210GetSystemStatus(uint8_t address, uint8_t * const systemStatus);
ssp_err_t ENS210SetSensorRunMode(uint8_t address, uint8_t const sensorRunMode);
ssp_err_t ENS210GetSensorRunMode(uint8_t address, uint8_t * const sensorRunMode);
ssp_err_t ENS210SetSensorStart(uint8_t address, uint8_t const sensorStart);
ssp_err_t ENS210GetSensorStart(uint8_t address, uint8_t * const sensorStart);
ssp_err_t ENS210SetSensorStop(uint8_t address, uint8_t const sensorStop);
ssp_err_t ENS210GetSensorStop(uint8_t address, uint8_t * const sensorStop);
ssp_err_t ENS210GetSensorStatus(uint8_t address, uint8_t * const sensorStatus);

#endif /* ENS210_H_ */
