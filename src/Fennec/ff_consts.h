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
  * Fennec Fox global constants
  *
  * @author: Marcin K Szczodrak
  * @updated: 09/08/2013
  */


#ifndef FF_CONSTANTS_H
#define FF_CONSTANTS_H

enum {
        OFF                     = 0,
        ON                      = 1,

	MAX_NUM_EVENTS		= 32,

	SEQ_RAND		= 20,
	SEQ_OFFSET		= 1,
	SEQ_OVERLAP		= 10,
	SEQ_MAX			= 0xFFDC,
	VARIABLE_HISTORY	= 11,

        UNKNOWN                 = 0xFF,
	NODE			= 0xFFFA,
        BRIDGE                  = 0xFFFA,
        BROADCAST               = 0xFFFF,

	F_MINIMUM_STATE_LEVEL	= 0,

	ANY			= 253,
        UNKNOWN_CONFIGURATION   = 0xFFF9,
        UNKNOWN_LAYER           = 255,
	UNKNOWN_ID		= 0xFFF0,

	SECOND_TO_MILLI		= 1024,
	MINUTE_TO_SECOND	= 60,
	HOUR_TO_MINUTE		= 60

};

#endif


