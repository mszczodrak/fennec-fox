// $Id: Msp430DcoCalibC.nc 2375 2013-04-19 08:35:27Z walserc $
/* "Copyright (c) 2000-2003 The Regents of the University of California.
 * All rights reserved.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose, without fee, and without written agreement
 * is hereby granted, provided that the above copyright notice, the following
 * two paragraphs and the author appear in all copies of this software.
 *
 * IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY FOR
 * DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES ARISING OUT
 * OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY
 * OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
 * INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE.  THE SOFTWARE PROVIDED HEREUNDER IS
 * ON AN "AS IS" BASIS, AND THE UNIVERSITY OF CALIFORNIA HAS NO OBLIGATION TO
 * PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS."
 */

/**
 * @author Cory Sharp <cssharp@eecs.berkeley.edu>
 */

configuration Msp430DcoCalibC
{
	provides interface StdControl;
}
implementation
{
  components Msp430DcoCalibP, Msp430TimerC;
  
  StdControl = Msp430DcoCalibP;

  Msp430DcoCalibP.TimerMicro -> Msp430TimerC.TimerA;
  Msp430DcoCalibP.Timer32khz -> Msp430TimerC.TimerB;
  
  components NoLedsC as LedsC;
  Msp430DcoCalibP.Leds -> LedsC;
  
  components McuSleepC;
  McuSleepC.McuPowerOverride -> Msp430DcoCalibP;

}

