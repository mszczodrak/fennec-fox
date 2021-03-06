/*
 * Copyright (c) 2014, Columbia University.
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
  * Fennec Fox cc2420 adaptation
  *
  * @author: Marcin K Szczodrak
  */


#include <Fennec.h>

module cc2420P {
provides interface SplitControl;
provides interface RadioChannel;

provides interface AMSend[process_t process_id];
provides interface Receive[process_t process_id];
provides interface Receive as Snoop[process_t process_id];

provides interface PacketField<uint8_t> as PacketLinkQuality;
provides interface PacketField<uint8_t> as PacketTransmitPower;
provides interface PacketField<uint8_t> as PacketRSSI;

provides interface PacketTimeStamp<TRadio, uint32_t> as PacketTimeStampRadio;
provides interface PacketTimeStamp<TMilli, uint32_t> as PacketTimeStampMilli;
provides interface PacketTimeStamp<T32khz, uint32_t> as PacketTimeStamp32khz;

uses interface Param;
uses interface StdControl as AMQueueControl;
uses interface SplitControl as SubSplitControl;
uses interface SystemLowPowerListening;
uses interface LowPowerListening;

uses interface AMSend as SubAMSend[process_t process_id];
uses interface AMPacket;
uses interface Receive as SubReceive[process_t process_id];
uses interface Receive as SubSnoop[process_t process_id];

uses interface CC2420Packet;
uses interface CC2420Config;
uses interface PacketTimeSyncOffset as CC2420PacketTimeSyncOffset;

uses interface PacketTimeStamp<TRadio, uint32_t> as SubPacketTimeStampRadio;
uses interface PacketTimeStamp<TMilli, uint32_t> as SubPacketTimeStampMilli;
uses interface PacketTimeStamp<T32khz, uint32_t> as SubPacketTimeStamp32khz;

}

implementation {

uint8_t channel;
uint8_t power;
uint16_t sleepInterval;
uint16_t sleepDelay;
bool autoAck;
bool turned_on = FALSE;

bool pending_stop;
uint8_t pending_process_id;
message_t *pending_msg;
	
task void setChannel() {
	uint8_t new_channel;
	call Param.get(CHANNEL, &new_channel, sizeof(new_channel));
	
	if (call RadioChannel.getChannel() == new_channel) {
		return;
	}

	if (call RadioChannel.setChannel(new_channel) != SUCCESS) {
		post setChannel();
	}
}

task void setAutoAck() {
//	call Param.get(AUTOACK, &autoAck, sizeof(autoAck));
//	call CC2420Config.setAutoAck(autoAck, autoAck);
//	call CC2420Config.sync();
}

command error_t SplitControl.start() {
	pending_stop = FALSE;
	pending_msg = NULL;
	pending_process_id = UNKNOWN;
	return call SubSplitControl.start();
}

command error_t SplitControl.stop() {
	turned_on = FALSE;
	if (pending_msg != NULL) {
		pending_stop = TRUE;
		call SubAMSend.cancel[pending_process_id](pending_msg);
		return SUCCESS;
	} else {
		return call SubSplitControl.stop();
	}
}

event void SubSplitControl.startDone(error_t error) {
	if (error == SUCCESS) {
		call AMQueueControl.start();

		call Param.get(SLEEPINTERVAL, &sleepInterval, sizeof(sleepInterval));
		call Param.get(SLEEPDELAY, &sleepDelay, sizeof(sleepDelay));

        	call SystemLowPowerListening.setDefaultRemoteWakeupInterval(sleepInterval);
	        call SystemLowPowerListening.setDelayAfterReceive(sleepDelay);
        	call LowPowerListening.setLocalWakeupInterval(sleepInterval);
	}

	post setChannel();
	post setAutoAck();

	turned_on = TRUE;
	return signal SplitControl.startDone(error);
}

event void SubSplitControl.stopDone(error_t error) {
        call LowPowerListening.setLocalWakeupInterval(0);
	if (error == SUCCESS) {
		call AMQueueControl.stop();
	}
	return signal SplitControl.stopDone(error);
}

command error_t AMSend.send[am_id_t id](am_addr_t addr, message_t* msg, uint8_t len) {
	if (turned_on == FALSE) {
		return EOFF;
	}

	call Param.get(SLEEPINTERVAL, &sleepInterval, sizeof(sleepInterval));
	call Param.get(POWER, &power, sizeof(power));

	pending_msg = msg;
	pending_process_id = id;

	call LowPowerListening.setRemoteWakeupInterval(msg, sleepInterval);
	call PacketTransmitPower.set(msg, power);
	return call SubAMSend.send[id](addr, msg, len);
}

event void SubAMSend.sendDone[am_id_t id](message_t* msg, error_t error) {
	pending_msg = NULL;
	pending_process_id = UNKNOWN;

	signal AMSend.sendDone[id](msg, error);

	if (pending_stop == TRUE) {
		pending_stop = FALSE;
		call SubSplitControl.stop();
	}
}

command error_t AMSend.cancel[am_id_t id](message_t* msg) {
	return call SubAMSend.cancel[id](msg);
}

command uint8_t AMSend.maxPayloadLength[am_id_t id]() {
	return call SubAMSend.maxPayloadLength[id]();
}

command void* AMSend.getPayload[am_id_t id](message_t* msg, uint8_t len) {
	return call SubAMSend.getPayload[id](msg, len);
}

event message_t * SubReceive.receive[process_t id](message_t* msg, void* payload, uint8_t len) {
	if (!validProcessId(call AMPacket.type(msg))) {
		return msg;
	}
	return signal Receive.receive[LOW_PROC_ID(call AMPacket.type(msg))](msg, payload, len);
}

event message_t * SubSnoop.receive[process_t id](message_t* msg, void* payload, uint8_t len) {
	if (!validProcessId(call AMPacket.type(msg))) {
		return msg;
	}
	return signal Snoop.receive[LOW_PROC_ID(call AMPacket.type(msg))](msg, payload, len);
}

task void setChannelDone() {
	signal RadioChannel.setChannelDone();
}

command error_t RadioChannel.setChannel(uint8_t ch) {
	error_t err;
	call CC2420Config.setChannel( ch );
	err = call CC2420Config.sync();
	channel = ch;
	post setChannelDone();
	return err;
}

command uint8_t RadioChannel.getChannel() {
	channel = call CC2420Config.getChannel();
	return channel;
}

async command bool PacketLinkQuality.isSet(message_t* msg) {
	return TRUE;
}

async command uint8_t PacketLinkQuality.get(message_t* msg) {
	return call CC2420Packet.getLqi(msg);
}

async command void PacketLinkQuality.clear(message_t* msg) {

}

async command void PacketLinkQuality.set(message_t* msg, uint8_t value) {

}

async command bool PacketTransmitPower.isSet(message_t* msg) {
	return call PacketTransmitPower.get(msg) != 0;
}

async command uint8_t PacketTransmitPower.get(message_t* msg) {
	power = call CC2420Packet.getPower(msg);
	return power;
}

async command void PacketTransmitPower.clear(message_t* msg) {

}

async command void PacketTransmitPower.set(message_t* msg, uint8_t value) {
	return call CC2420Packet.setPower(msg, value);
}

async command bool PacketRSSI.isSet(message_t* msg) {
	return TRUE;
}

async command uint8_t PacketRSSI.get(message_t* msg) {
	return (uint8_t) call CC2420Packet.getRssi(msg);
}

async command void PacketRSSI.clear(message_t* msg) {

}

async command void PacketRSSI.set(message_t* msg, uint8_t value) {

}

event void CC2420Config.syncDone(error_t error) {}


default event message_t* Receive.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) {
	return msg;
}

default event message_t* Snoop.receive[am_id_t id](message_t* msg, void* payload, uint8_t len) {
	return msg;
}

default event void AMSend.sendDone[uint8_t id](message_t* msg, error_t err) {
}

event void Param.updated(uint8_t var_id, bool conflict) {

}

async command bool PacketTimeStampRadio.isValid(message_t* msg) {
	return call SubPacketTimeStamp32khz.isValid(msg);
}

async command uint32_t PacketTimeStampRadio.timestamp(message_t* msg) {
	return call SubPacketTimeStamp32khz.timestamp(msg);
}

async command void PacketTimeStampRadio.clear(message_t* msg) {
	return call SubPacketTimeStamp32khz.clear(msg);
}

async command void PacketTimeStampRadio.set(message_t* msg, uint32_t value) {
	call CC2420PacketTimeSyncOffset.set(msg);
	return call SubPacketTimeStamp32khz.set(msg, value);
}

async command bool PacketTimeStamp32khz.isValid(message_t* msg) {
	return call SubPacketTimeStamp32khz.isValid(msg);
}

async command uint32_t PacketTimeStamp32khz.timestamp(message_t* msg) {
	return call SubPacketTimeStamp32khz.timestamp(msg);
}

async command void PacketTimeStamp32khz.clear(message_t* msg) {
	return call SubPacketTimeStamp32khz.clear(msg);
}

async command void PacketTimeStamp32khz.set(message_t* msg, uint32_t value) {
	call CC2420PacketTimeSyncOffset.set(msg);
	return call SubPacketTimeStamp32khz.set(msg, value);
}


async command bool PacketTimeStampMilli.isValid(message_t* msg) {
	return call SubPacketTimeStampMilli.isValid(msg);
}

async command uint32_t PacketTimeStampMilli.timestamp(message_t* msg) {
	return call SubPacketTimeStampMilli.timestamp(msg);
}

async command void PacketTimeStampMilli.clear(message_t* msg) {
	return call SubPacketTimeStampMilli.clear(msg);
}

async command void PacketTimeStampMilli.set(message_t* msg, uint32_t value) {
	call CC2420PacketTimeSyncOffset.set(msg);
	return call SubPacketTimeStampMilli.set(msg, value);
}


}
