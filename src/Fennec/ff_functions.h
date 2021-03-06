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
  * Fennec Fox global functions
  *
  * @author: Marcin K Szczodrak
  * @updated: 09/08/2013
  */


#ifndef FF_FUNCTIONS_H
#define FF_FUNCTIONS_H

#include <Fennec.h>
#include "ff_structs.h"

/*   0          byte          1 
 *   |  PROC_ID   |  DATA_ID  |      
 */
#define LOW_PROC_ID(x) (x >> 4)
#define LOW_DATA_ID(x) (x & 0x0F)

#define min(a, b) (((a) < (b)) ? (a) : (b))
#define max(a, b) (((a) > (b)) ? (a) : (b))

#define _MILLI_2_32KHZ(x) ((x) << 5)
#define _32KHZ_2_MILLI(x) ((x) >> 5)

uint32_t gcdr (uint32_t a, uint32_t b )@C() {
        if ( a==0 ) return b;
        return gcdr ( b%a, a );
}

bool validProcessId(nx_uint8_t msg_type);
nx_uint8_t setFennecType(nx_uint8_t id);

#ifdef FENNEC_LOGGER
void insertLog(uint16_t from, uint16_t message);
void cleanLog();
void printLog();
#endif

#endif
