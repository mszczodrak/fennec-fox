#!/usr/bin/python
# Marcin K Szczodrak
# Updated on 4/24/2014

import sys
indriya_log_length = 11


if len(sys.argv) != 2:
	print("\nusage: %s <indriya.dat log file>\n\n");
	sys.exit(1)

f = open(sys.argv[1], "r")

time_offset = -1 

print "{:>8} {:>3} {:>7} {:>6} {:>6} {:>6} {:>6} {:>6} {:>6}".format("sec", "ms", "mote", "ver", "id", "dbg", "d0", "d1", "d2")

for line in f.readlines():
	l = line.split()
	if len(l) != indriya_log_length:
		continue

	if not l[0].isdigit():
		continue

	try:
		time_stamp = int("%s"%(l[9]))
		mote_id = int("%s"%(l[8])) - 40000

		version = int("%s"%(l[0]))
		did = int("%s"%(l[1]))
		dbg = int("%s"%(l[2]))
		d0 = int("%s"%(l[3]))
		d1 = int("%s"%(l[4]))
		d2 = int("%s"%(l[5]))
	except:
		continue

	if (time_offset < 0):
		time_offset = time_stamp

	time_stamp = time_stamp - time_offset

	print "{:>8} {:03}".format(time_stamp/1000, time_stamp%1000),
	print "{:>7} ".format(mote_id),
	print "{:>5} ".format(version),
	print "{:>5} ".format(did),
	print "{:>5} ".format(dbg),
	print "{:>5} ".format(d0),
	print "{:>5} ".format(d1),
	print "{:>5} ".format(d2)

