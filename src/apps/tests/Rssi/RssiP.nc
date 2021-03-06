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
  * Fennec Fox Rssi Application module
  *
  * @author: Marcin K Szczodrak
  * @updated: 05/22/2011
  */


#include <Fennec.h>
#include "Rssi.h"

generic module RssiP(process_t process) {
provides interface SplitControl;

uses interface Param;

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
uses interface Random;
uses interface Timer<TMilli> as SendTimer;
uses interface Timer<TMilli> as LedTimer;

uses interface SerialDbgs;
}

implementation {

message_t packet;
bool busy;
uint32_t seqno;

uint16_t tx_delay;
float rssi_scale;
int8_t rssi_offset;
int8_t threshold_1;
int8_t threshold_2;

message_metadata_t* getMetadata(message_t *msg) {
	return (message_metadata_t*)msg->metadata;
}

task void reset_led_timer() {
	call Param.get(TX_DELAY, &tx_delay, sizeof(tx_delay));
	call LedTimer.startOneShot(2 * tx_delay);
}

task void send_timer() {
	call Param.get(TX_DELAY, &tx_delay, sizeof(tx_delay));
	call SendTimer.startOneShot( (call Random.rand16() % tx_delay) + 
			(tx_delay / 2) + 1);
}

command error_t SplitControl.start() {
	seqno = 0;
	post send_timer();
	busy = FALSE;
	post reset_led_timer();

	call Param.get(RSSI_SCALE, &rssi_scale, sizeof(rssi_scale));
	call Param.get(RSSI_OFFSET, &rssi_offset, sizeof(rssi_offset));
	call Param.get(THRESHOLD_1, &threshold_1, sizeof(threshold_1));
	call Param.get(THRESHOLD_2, &threshold_2, sizeof(threshold_2));

	signal SplitControl.startDone(SUCCESS);
	return SUCCESS;
}

command error_t SplitControl.stop() {
	signal SplitControl.stopDone(SUCCESS);
	return SUCCESS;
}

event void SubAMSend.sendDone(message_t *msg, error_t error) {
	busy = FALSE;

#ifdef __DBGS__APPLICATION__
	call SerialDbgs.dbgs(DBGS_SEND_DATA, error, seqno, BROADCAST);
#endif
}

event message_t* SubReceive.receive(message_t *msg, void* payload, uint8_t len) {
	int8_t rssi = (int8_t) call SubPacketRSSI.get(msg);
	int16_t rssi_calib = (rssi * rssi_scale) + rssi_offset;

#ifdef FENNEC_TOS_PRINTF
	int8_t lqi = (int8_t) call SubPacketLinkQuality.get(msg);
	printf("RSSI: %d  LQI: %d\n", rssi, lqi);
	printfflush();
#endif

#ifdef __DBGS__APPLICATION__
	RssiMsg *m = (RssiMsg*) payload;
	call SerialDbgs.dbgs(DBGS_RECEIVE_BEACON, call SubAMPacket.source(msg),
		//call SubPacketRSSI.get(msg), call SubPacketLinkQuality.get(msg));
		call SubPacketRSSI.get(msg), m->seq);
#endif

	signal LedTimer.fired();

#ifdef __USUAL_LEDS__
	call Leds.led0On();
#endif

	if ( rssi_calib  > threshold_1 ) {
#ifdef __USUAL_LEDS__
		call Leds.led1On();
#endif
	}

	if ( rssi_calib  > threshold_2 ) {
#ifdef __USUAL_LEDS__
		call Leds.led2On();
#endif
	}

	return msg;
}

event message_t* SubSnoop.receive(message_t *msg, void* payload, uint8_t len) {
	return msg;
}

event void SendTimer.fired() {
	RssiMsg *msg = (RssiMsg*) call SubAMSend.getPayload(&packet,
							sizeof(RssiMsg));
	if (msg != NULL && !busy) {
		busy = TRUE;
		msg->src = TOS_NODE_ID;
		msg->seq = ++seqno;
		if (call SubAMSend.send(BROADCAST, &packet, sizeof(RssiMsg)) != SUCCESS) {
			signal SubAMSend.sendDone(&packet, FAIL);
		}
	}

	post send_timer();
}

event void LedTimer.fired() {
#ifdef __USUAL_LEDS__
	call Leds.set(0);
#endif
	post reset_led_timer();
}

event void Param.updated(uint8_t var_id) {

}

}
