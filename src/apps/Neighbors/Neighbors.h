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
  * Fennec Fox Neighbors Application module
  *
  * @author: Marcin K Szczodrak
  * @updated: 05/22/2011
  */


#ifndef __Neighbors_APP_H_
#define __Neighbors_APP_H_

#include "SerialDbgs.h"

#define NEIGHBORHOOD_DATA 	20

typedef struct NeighborsData {
	am_addr_t	node;		/* neighbor address */
	uint16_t	first_seq;	/* seq when we first time we hear neighbor */
	uint16_t	last_seq;	/* seq when we last time we hear neighbor */
	uint32_t	timestamp;	/* last time we hear neighbor */
	uint16_t	rec;		/* number of receives */
	uint8_t		radio_tx;	/* the tx power that neighbor has about us */
	uint8_t		size; 	
	uint8_t		etx;
} NeighborsData;

typedef nx_struct NeighborsEntry {
	nx_am_addr_t	node;
	nx_uint8_t	etx;
	nx_uint8_t	radio_tx;
} NeighborsEntry;

typedef nx_struct NeighborsMsg {
	nx_am_addr_t	src;
	nx_uint8_t	tx;
	nx_uint16_t	seq;
	nx_uint8_t	size;
	NeighborsEntry data[NEIGHBORHOOD_DATA];
} NeighborsMsg;

#endif

