#!/bin/bash

# Directory where to store the measurements
OUTDIR="../results-measurements"

# Maximum number of entries to be extracted from the original file
NUM_EVENTS=1000000

# Number of restart tests
NUM_EVENTS_RESTART=1000
NUM_RESTART=1000

NONIID_RESTART_DATA="jent-raw-noise-restart"
NONIID_DATA="jent-raw-noise"
IID_DATA="jent-conditioned.data"

# If this variable is set to any value, the timer-less entropy source
# is forced and tested
FORCE_NOTIME_NOISE_SOURCE=""

initialization()
{
	if [ ! -d $OUTDIR ]
	then
		mkdir $OUTDIR
		if [ $? -ne 0 ]
		then
			echo "Creation of $OUTDIR failed"
			exit 1
		fi
	fi

	trap "make -s -f Makefile.lfsroutput clean; make -s -f Makefile.hashtime clean; exit" 0 1 2 3 15
}

lfsroutput()
{
	echo "Obtaining $NUM_EVENTS blocks of output from Jitter RNG"

	make -s -f Makefile.lfsroutput

	./jitterentropy-lfsroutput $NUM_EVENTS $FORCE_NOTIME_NOISE_SOURCE > $OUTDIR/$IID_DATA

	make -s -f Makefile.lfsroutput clean
}

raw_entropy_restart()
{
	echo "Obtaining $NUM_RESTART raw entropy measurement with $NUM_EVENTS_RESTART restarts from Jitter RNG"

	make -s -f Makefile.hashtime

	./jitterentropy-hashtime $NUM_EVENTS_RESTART $NUM_RESTART $OUTDIR/$NONIID_RESTART_DATA $FORCE_NOTIME_NOISE_SOURCE

	make -s -f Makefile.hashtime clean
}

raw_entropy()
{
	echo "Obtaining $NUM_EVENTS raw entropy measurement from Jitter RNG"

	make -s -f Makefile.hashtime

	./jitterentropy-hashtime $NUM_EVENTS 1 $OUTDIR/$NONIID_DATA $FORCE_NOTIME_NOISE_SOURCE

	make -s -f Makefile.hashtime clean
}

initialization
lfsroutput
raw_entropy
raw_entropy_restart
