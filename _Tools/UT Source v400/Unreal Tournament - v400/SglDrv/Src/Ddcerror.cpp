//******************************************************************************
// Name:      DDCERROR.C
// Title:     Returns error strings for DDC errors
// Author(s): Jayeson Lee-Steere
// Created :  97/08/08
//******************************************************************************
#pragma warning( disable:4201 )
#include <windows.h>
#include "Engine.h"
#include "UnRender.h"

#include "HookSgl.h"
#include "DDC.h"

char *UDDC::DDCGetErrorMessage(int ErrorMessage)
{
	switch (ErrorMessage)
	{
		case DDCERR_OK:
			return("Failure accessing DirectDraw. (No Error???).");
		case DDCERR_FAILED_TO_CREATE_DDRAW_OBJECT:
			return("Failure accessing DirectDraw. (Failed to create DirectDraw object).");
		case DDCERR_FAILED_TO_SET_DDRAW_COOPERATIVE_LEVEL:
			return("Failure accessing DirectDraw. (Failed to set cooperative level).");
		case DDCERR_FAILED_TO_SET_DDRAW_VIDEO_MODE:
			return("Failure accessing DirectDraw. (Failed to set video mode).");
		case DDCERR_FAILED_TO_CREATE_DDRAW_SURFACE:
			return("Failure accessing DirectDraw. (Failed to create DirectDraw surface).\n\nThis error is most likely caused because your 2D video card is out of video memory. If you are trying to use an application which runs in a window, try reducing your desktop size to free up some memory.");
		case DDCERR_FAILED_TO_GET_DDRAW_ATTACHED_SURFACE:
			return("Failure accessing DirectDraw. (Failed to get attached surface).");
		case DDCERR_FAILED_TO_CREATE_DDRAW_CLIPPER:
			return("Failure accessing DirectDraw. (Failed to create DirectDraw clipper).");
		case DDCERR_FAILED_TO_SET_DDRAW_CLIPPER_WINDOW:
			return("Failure accessing DirectDraw. (Failed to set clipper window).");
		case DDCERR_FAILED_TO_SET_DDRAW_SURFACE_CLIPPER:
			return("Failure accessing DirectDraw. (Failed to set surface clipper).");
		case DDCERR_FAILED_TO_GET_DDRAW_PIXEL_FORMAT:
			return("Failure accessing DirectDraw. (Failed to get surface pixel format).");
		case DDCERR_PIXEL_FORMAT_IS_INVALID:
			return("The rendering target has an invalid pixel format.\n\nThe driver can only render at 15, 16, 24 and 32 bit color depths.");
		case DDCERR_FAILED_TO_CREATE_SGL_SCREEN_DEVICE:
			return("Failure accessing PowerSGL. (Failed to create SGL screen device).");
		case DDCERR_FAILED_TO_LOAD_DDRAW_DLL:
			return("Failed accessing DirectDraw. (Failed to load DDRAW.DLL).");
		case DDCERR_FAILED_TO_FIND_CREATE_FUNCTION:
			return("Failed accessing DirectDraw. (Failed to locate function \"DirectDrawCreate\" in DDRAW.DLL).");
		default:
			return("Failure accessing DirectDraw. (Exact reason unknown).");
	}
}
