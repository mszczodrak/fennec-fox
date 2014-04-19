/*
 * Copyright (c) 2009, Columbia University.
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
  * RandomBeacon Test Application Module
  *
  * @author: Marcin K Szczodrak
  * @updated: 01/03/2014
  */


#include <Fennec.h>
#include <Timer.h>
#include "RandomBeacon.h"

generic module RandomBeaconP(process_t process) {
provides interface SplitControl;

uses interface RandomBeaconParams;

uses interface AMSend as SubAMSend;
uses interface Receive as SubReceive;
uses interface Receive as SubSnoop;
uses interface AMPacket as SubAMPacket;
uses interface Packet as SubPacket;
uses interface PacketAcknowledgements as SubPacketAcknowledgements;

uses interface PacketField<uint8_t> as SubPacketLinkQuality;
uses interface PacketField<uint8_t> as SubPacketTransmitPower;
uses interface PacketField<uint8_t> as SubPacketRSSI;

uses interface Leds;
uses interface Timer<TMilli>;
uses interface Random;

}

implementation {

/**
 Available Parameters:
	uint16_t delay,
	uint16_t delay_scale,
*/


message_t packet;
bool sendBusy = FALSE;

task void set_timer() {
	call Timer.startOneShot((call Random.rand32()) % 
		(call RandomBeaconParams.get_delay() * 
		call RandomBeaconParams.get_delay_scale()));
}


command error_t SplitControl.start() {
	//call Leds.led0On();
	//dbgs(F_APPLICATION, S_NONE, DBGS_MGMT_START, 0, 0);
	dbg("Application", "RandomBeacon SplitControl.start()");

	post set_timer();

	sendBusy = FALSE;
	signal SplitControl.startDone(SUCCESS);
	return SUCCESS;
}

command error_t SplitControl.stop() {
	call Timer.stop();
	dbg("Application", "RandomBeacon SplitControl.stop()");
	//dbgs(F_APPLICATION, S_NONE, DBGS_MGMT_STOP, 0, 0);
	signal SplitControl.stopDone(SUCCESS);
	return SUCCESS;
}

void sendMessage() {
	RandomBeaconMsg* msg = (RandomBeaconMsg*)call SubAMSend.getPayload(&packet,
							sizeof(RandomBeaconMsg));
	call Leds.led1Toggle();
	if (msg == NULL) {
		return;
	}

	msg->source = TOS_NODE_ID;
	msg->seqno = call Random.rand32();

	dbg("Application", "RandomBeacon sendMessage() seqno: %d source: %d", msg->seqno, msg->source); 
	dbgs(F_APPLICATION, S_NONE, DBGS_SEND_DATA, msg->seqno, msg->source);

	if (call SubAMSend.send(BROADCAST, &packet, 
					sizeof(RandomBeaconMsg)) != SUCCESS) {
	} else {
		dbg("Application", "RandomBeacon call SubAMSend.send(%d, 0x%1x, %d)",
					BROADCAST, &packet,
					sizeof(RandomBeaconMsg));
		sendBusy = TRUE;
		call Leds.set(msg->seqno);
	}
}

event void Timer.fired() {
	if (!sendBusy) {
		sendMessage();
	}
	post set_timer();
}

event void SubAMSend.sendDone(message_t *msg, error_t error) {
	dbg("Application", "RandomBeacon event SubAMSend.sendDone(0x%1x, %d)",
					msg, error);
	sendBusy = FALSE;
}


event message_t* SubReceive.receive(message_t *msg, void* payload, uint8_t len) {
	RandomBeaconMsg* cm = (RandomBeaconMsg*)payload;

	dbg("Application", "RandomBeacon event SubReceive.receive(0x%1x, 0x%1x, %d)", msg, payload, len); 
	dbg("Application", "RandomBeacon receive seqno: %d source: %d", cm->seqno, cm->source); 
	dbgs(F_APPLICATION, S_NONE, DBGS_RECEIVE_DATA, cm->seqno, cm->source);
	call Leds.set(cm->seqno);
	return msg;
}

event message_t* SubSnoop.receive(message_t *msg, void* payload, uint8_t len) {
	return msg;
}

}