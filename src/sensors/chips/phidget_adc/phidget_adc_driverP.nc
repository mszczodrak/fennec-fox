/*
 * Copyright (c) 2012, Columbia University.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *  - Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  - Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  - Neither the name of the Columbia University nor the
 *    names of its contributors may be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL COLUMBIA UNIVERSITY BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/**
  * Phidget ADC sensor driver
  *
  * @author: Marcin K Szczodrak
  * @updated: 01/08/2014
  */


#include <Fennec.h>
#include "phidget_adc_driver.h"

generic module phidget_adc_driverP() @safe() {
provides interface SensorCtrl;
provides interface SensorInfo;
provides interface AdcSetup;
provides interface Read<ff_sensor_data_t>;

uses interface Msp430Adc12SingleChannel;
uses interface Resource;
uses interface Read<uint16_t> as Battery;
uses interface Timer<TMilli> as Timer;
uses interface Leds;
}

implementation {

norace uint16_t raw_data = 0;
norace uint16_t battery = 0;
norace uint32_t sequence = 0;

uint32_t rate;

ff_sensor_data_t return_data;

msp430adc12_channel_config_t phidget_adc_config = {
	INPUT_CHANNEL_A7,           // input channel
	REFERENCE_AVcc_AVss,        // reference voltage
	REFVOLT_LEVEL_NONE,         // reference voltage level
	SHT_SOURCE_ACLK,            // clock source sample-hold-time
	SHT_CLOCK_DIV_1,            // clock divider sample-hold-time
	SAMPLE_HOLD_4_CYCLES,       // sample-hold-time
	SAMPCON_SOURCE_SMCLK,       // clock source sampcon signal
	SAMPCON_CLOCK_DIV_1         // clock divider sampcon
};

task void signal_readDone() {
	return_data.size = sizeof(raw_data);
	return_data.seq = ++sequence;
	return_data.raw = &raw_data;
	return_data.calibrated = &raw_data;
        return_data.type = call SensorInfo.getType();
        return_data.id = call SensorInfo.getId();
	signal Read.readDone(SUCCESS, return_data);
}

command error_t SensorCtrl.setRate(uint32_t new_rate) {
	rate = new_rate;
	call Timer.startPeriodic(rate);
	return SUCCESS;
}

command uint32_t SensorCtrl.getRate() {
	return rate;
}

command sensor_type_t SensorInfo.getType() {
	return F_SENSOR_UNKNOWN;
}

command sensor_id_t SensorInfo.getId() {
	return FS_GENERIC;
} 

command error_t AdcSetup.set_input_channel(uint8_t new_input_channel) {
	phidget_adc_config.inch = new_input_channel;  
	return SUCCESS;
}

command uint8_t AdcSetup.get_input_channel(){
	return phidget_adc_config.inch;
}

command error_t Read.read() {
	signal Timer.fired();
	return SUCCESS;
}

event void Timer.fired() {
	call Battery.read();
	call Resource.request();
}

event void Resource.granted() {
	call Msp430Adc12SingleChannel.configureSingle(&phidget_adc_config);
	call Msp430Adc12SingleChannel.getData();
}

async event error_t Msp430Adc12SingleChannel.singleDataReady(uint16_t data) {
	uint32_t s = data;
	s *= battery;
	s /= 4096;    
	raw_data = s;
	call Resource.release();
	post signal_readDone();
	return 0;
}

event void Battery.readDone(error_t error, uint16_t data){
	if (error == SUCCESS) {
		uint32_t b = data;
		b *= 3000;
		b /= 4096;
		battery = b;
	} 
}

async event uint16_t *Msp430Adc12SingleChannel.multipleDataReady(
			uint16_t *buffer, uint16_t numSamples){
	return 0;
}

default event void Read.readDone(error_t err, ff_sensor_data_t data) {}
}

