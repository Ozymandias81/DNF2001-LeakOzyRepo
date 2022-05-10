//****************************************************************************
//**
//**    TIMEMAIN.CPP
//**    Timing
//**
//****************************************************************************
//============================================================================
//    HEADERS
//============================================================================
#define KRNINC_WIN32
#include "Kernel.h"
#include "TimeMain.h"

#include <mmsystem.h>
#pragma comment(lib, "winmm.lib")

//============================================================================
//    DEFINITIONS / ENUMERATIONS / SIMPLE TYPEDEFS
//============================================================================
//============================================================================
//    CLASSES / STRUCTURES
//============================================================================
//============================================================================
//    PRIVATE DATA
//============================================================================
static NBool time_PCTimerEnabled;
static NDword time_MMTimerStart;
static NSQword time_PCTimerStart;
static NSQword time_TicksPerSec;
static NDouble time_SecsPerTick;

static NFloat time_baseTime;
static NFloat time_frameCurTime;
static NFloat time_frameLastTime;
static NFloat time_frameDeltaTime;

//============================================================================
//    GLOBAL DATA
//============================================================================
//============================================================================
//    PRIVATE FUNCTIONS
//============================================================================
static NFloat TIME_GetCurrent()
{
	if (time_PCTimerEnabled)
	{
		NSQword curTime;
		QueryPerformanceCounter((LARGE_INTEGER*)&curTime);
		return((NFloat)(((NDouble)(curTime-time_PCTimerStart))*time_SecsPerTick));
	}
	else
	{
		return((NFloat)(((NDouble)(timeGetTime()-time_MMTimerStart))*time_SecsPerTick));
	}
}

//============================================================================
//    GLOBAL FUNCTIONS
//============================================================================
KRN_API void TIME_Init()
{
	if (!QueryPerformanceFrequency((LARGE_INTEGER*)&time_TicksPerSec))
	{
		// no performance counter timer available, use multimedia timer
		time_MMTimerStart = timeGetTime();
		time_SecsPerTick = 1.0/1000.0;
		time_PCTimerEnabled = 0;
	}
	else
	{
		// performance counter timer is available
		QueryPerformanceCounter((LARGE_INTEGER*)&time_PCTimerStart);
		time_SecsPerTick = (NDouble)(((NDouble)1.0)/((NDouble)time_TicksPerSec));
		time_PCTimerEnabled = 1;
	}
}

KRN_API void TIME_Shutdown()
{
}

KRN_API void TIME_Frame()
{
	time_frameCurTime = TIME_GetTimeRaw();
	time_frameDeltaTime = time_frameCurTime - time_frameLastTime;
	time_frameLastTime = time_frameCurTime;
}

KRN_API void TIME_Reset()
{
	time_baseTime = TIME_GetCurrent();
	time_frameLastTime = 0.0f;
	time_frameCurTime = 0.0f;
	time_frameDeltaTime = 0.0f;
}

KRN_API NFloat TIME_GetTimeRaw()
{
	return(TIME_GetCurrent() - time_baseTime);
}

KRN_API NFloat TIME_GetTimeFrame()
{
	return(time_frameCurTime);
}

KRN_API NFloat TIME_GetDeltaTimeFrame()
{
	return(time_frameDeltaTime);
}

//============================================================================
//    CLASS METHODS
//============================================================================

//****************************************************************************
//**
//**    END MODULE TIMEMAIN.CPP
//**
//****************************************************************************

