/*
 *  SENSIRION 11 SHT11 TEMPERATURE driver.
 *
 *  Copyright (C) 2010-2013 Marcin Szczodrak
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

/*
 * Application: SENSIRION 11 SHT11 TEMPERATURE
 * Author: Marcin Szczodrak
 * Date: 8/16/2009
 * Last Modified: 1/4/2013
 */

#include "sht11temp_0_driver.h"

generic configuration sht11temp_0_driverC() {
provides interface SensorCtrl;
provides interface SensorInfo;
provides interface Read<ff_sensor_data_t>;
}

implementation {

enum {
        CLIENT_ID = unique(UQ_SHT11TEMP),
};

components sht11temp_0_driverC_;
SensorInfo = sht11temp_0_driverC_.SensorInfo;
SensorCtrl = sht11temp_0_driverC_.SensorCtrl[CLIENT_ID];
Read = sht11temp_0_driverC_.Read[CLIENT_ID];

}

