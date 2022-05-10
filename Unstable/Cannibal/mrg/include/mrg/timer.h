/** MRG
 **
 ** (c)1997 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

//////////////////////////////////////////////////////////////////////////////
// timer.h
// ------------
// Header file for MrgTimer object - a class used to time processes

#pragma once

#include "mrg/types.h"

class MrgTimer
{
public:
	MrgTimer();

	// get the time elapsed
	MrgUint32	getElapsed(void) const;
	// reset the timer
	void		reset(void); 
	// pause the timer
	void		pause(void);
	// resume the timer
	void		resume(void);
	// running state
	MrgBoolean	isPaused(void) const { return mPaused; }
	MrgBoolean	isRunning(void) const { return (!mPaused); }

protected:
	MrgUint32	mStart;		// start time
	MrgBoolean	mPaused;		// are we paused?
	MrgUint32	mTime;		// elapsed time

	// get system ticks
	static MrgUint32	getTicks(void); 
};
