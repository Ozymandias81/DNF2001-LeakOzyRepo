//******************************************************************************
// Name:      DDC.C
// Title:     Code for controlling DirectDraw
// Author(s): Jayeson Lee-Steere
// Created :  97/08/08
//******************************************************************************
// Precompiled header.
#pragma warning( disable:4201 )
#include <windows.h>
#include "Engine.h"
#include "UnRender.h"

#include "HookSgl.h"
#include "DDC.h"

#define DPC(a) //debugf a

//******************************************************************************
// NOTES:
//
// Much of this code was based on the source for FOXBEAR, Tower5 (Double buffered
// version) TUNNEL (or D3DAPP stuff) and a little from DDEX1.
//
// In particular the ways to create and control the DDRAW stuff and which
// windows messages might need to be handled and how to handle them.
//
// We currently don't allow target windows to be resized. There are 
// numerous issues, but the worst is that something (DirectX??) seems to 
// cause the system to die a horrible death when you repeatedly try and 
// allocate more video memory than is available. We could just always render
// to the front buffer, but we can only render if the window isn't clipped 
// which isn't very good either.
//******************************************************************************

// A pointer to the SGL status DWORD, which lets us know it the render has 
// completed or not
volatile LPDWORD pSglStatus;
// Hack - we need a pointer to the context for our callbacks
void *CallbackContext;

//******************************************************************************
// Functions internal to this file
//******************************************************************************
//******************************************************************************
// Fills a surface with black
//******************************************************************************
void UDDC::_DDCClearSurface(IDirectDrawSurface *Surface)
{
	DDBLTFX ddbltfx;

	ddbltfx.dwSize = sizeof( ddbltfx );
	ddbltfx.dwFillColor = 0;
	Surface->Blt(NULL,                   // dest rect
				 NULL,                   // src surface
				 NULL,                   // src rect
				 DDBLT_COLORFILL | DDBLT_WAIT,
				 &ddbltfx);
}

//******************************************************************************
// Restores the surfaces if they are lost
//******************************************************************************
BOOL UDDC::_DDCRestoreSurfacesIfLost()
{
    HRESULT ddrval;

	// Restore front buffer if lost
	if (FrontBuffer)
	{
		ddrval=FrontBuffer->IsLost();
		if (ddrval==DD_OK)
		{
			return TRUE;
		}
		else if (ddrval==DDERR_SURFACELOST)
		{
			ddrval=FrontBuffer->Restore();
			if (ddrval==DD_OK)
				return TRUE;
		}
		return FALSE;
	}
	// Restore back buffer if lost and running in a window
	if (BackBuffer && !bFullScreen)
	{
		ddrval=BackBuffer->IsLost();
		if (ddrval==DD_OK)
		{
			return TRUE;
		}
		else if (ddrval==DDERR_SURFACELOST)
		{
			ddrval=BackBuffer->Restore();
			if (ddrval==DD_OK)
				return TRUE;
		}
		return FALSE;
	}
	return TRUE;
}

//******************************************************************************
// callback functions
//******************************************************************************
//******************************************************************************
// This is the function called by SGL during an sgl_render call. It can be called 
// before the previous render has completed so this is not an appropriate time to 
// flip.
//******************************************************************************
int _DDCNextAddressProc(P_CALLBACK_ADDRESS_PARAMS pParamBlk)
{
	// Get pointer to the context. Perhaps later we'll have a better way of doing this
	UDDC *Context=(UDDC *)CallbackContext;
	DDSURFACEDESC SurfaceInfo;
    HRESULT ddrval;

	// If app is not active, abort render
//	if (Context->bAppActive==FALSE)
//	{
//		DPC((NAME_Log,"SGL: NextAddressProc: App is not active."));
//		return -1;
//	}

	// Restore surfaces if necessary
	if (Context->_DDCRestoreSurfacesIfLost()==FALSE)
	{
		DPC((NAME_Log,"SGL: NextAddressProc: Could not restore surfaces."));
		return -1;
	}
	
	Context->DDCFlip();

	// Lock the next render buffer to get address and stride
	// Because we flip later in the next callback (EOR Proc), not this one, we
	// use the BackBackBuffer which will be the back buffer after the flip
	ZeroMemory(&SurfaceInfo, sizeof(SurfaceInfo));
	SurfaceInfo.dwSize = sizeof(SurfaceInfo);
	SurfaceInfo.dwFlags = DDLOCK_SURFACEMEMORYPTR;	/* Request valid memory pointer */

#if 0
	ddrval=Context->BackBackBuffer->Lock( NULL,&SurfaceInfo,
								   DDLOCK_SURFACEMEMORYPTR | DDLOCK_WAIT | DDLOCK_WRITEONLY,
								   NULL);
#else
	ddrval=Context->BackBuffer->Lock( NULL,&SurfaceInfo,
								   DDLOCK_SURFACEMEMORYPTR | DDLOCK_WAIT | DDLOCK_WRITEONLY,
								   NULL);
#endif
	// If we failed to lock the surface abort this render
	if (ddrval!=DD_OK)
	{
		DPC((NAME_Log,"SGL: NextAddressProc: Failed to lock buffer"));
		return -1;
	}

	// All is good, so set return data and return with OK to continue rendering
	pParamBlk ->pMem = (void *)SurfaceInfo.lpSurface;
	pParamBlk ->wStride = (sgl_uint16)SurfaceInfo.lPitch;
	pParamBlk ->bBitsPerPixel = Context->RealBpp;
	
	// Unlock the buffer or set flag to indicate that it is locked
	if (!Context->iStrictLocks)
#if 0
		Context->BackBackBuffer->Unlock(NULL);
#else
		Context->BackBuffer->Unlock(NULL);
#endif
	else
		Context->bRenderTargetLocked=TRUE;

	// Set this so the flip routine knows in needs to flip
	Context->bFlipPending=TRUE;
	
//	DPC((NAME_Log,"SGL: NextAddressProc:  OK"));
	return 0;
}

//******************************************************************************
// This function is called when the previous render has completed 
//******************************************************************************
int _DDCEORProc(void)
{
//	CALLBACK_SURFACE_PARAMS SurfaceInfo;

	// Get pointer to the context. Perhaps later we'll have a better way of doing this
	//UDDC *Context=(UDDC *)CallbackContext;

//	DPC((NAME_Log,"SGL: EORProc"));

#if 0
	// Call 2D callback if one exists
	if (Context->Proc2D)
	{
		SurfaceInfo.pDDObject=Context->dd1;
		SurfaceInfo.p3DSurfaceObject=Context->BackBuffer;
//todo - need to fill in p3DSurfaceMemory, wBitsPerPixel and dwStride
		SurfaceInfo.wWidth=Context->TargetWidth;
		SurfaceInfo.wHeight=Context->TargetHeight;
		Context->Proc2D(&SurfaceInfo);
	}
#endif

	return 0; 
}

//******************************************************************************
// This is the hook of the existing window procedure
//******************************************************************************
LRESULT CALLBACK _DDCWindowProc(HWND hWnd,UINT uMsg,WPARAM wParam,LPARAM lParam)
{
	BOOL bOverrideReturnVal=FALSE;
	LRESULT ReturnVal=0;

	// Get pointer to the context. Perhaps later we'll have a better way of doing this
	UDDC *Context=(UDDC *)CallbackContext;
	
	switch (uMsg)
	{
		case WM_TIMER:
			// We create a timer so we can poll the status of the render and flip
			// if the rendering stops
			if (wParam==0x00250771)
			{
				if (Context->bFlipPending && Context->DDCIsRenderActive()==FALSE)
				{
					Context->FlipTimeoutCount++;
					if (Context->FlipTimeoutCount>1)
						Context->DDCFlip();
				}
				return 0;
			}
			break;
		case WM_MOVE:
			// Take note of the new window position
			GetClientRect(Context->TargetWindow,&Context->WindowRect);
			ClientToScreen(Context->TargetWindow,(LPPOINT)&Context->WindowRect);
			ClientToScreen(Context->TargetWindow,(LPPOINT)&Context->WindowRect+1);
			DPC((NAME_Log,"SGL: WM_MOVE %ix%i (%i,%i)(%i,%i)",
				Context->WindowRect.right-Context->WindowRect.left,
				Context->WindowRect.bottom-Context->WindowRect.top,
				Context->WindowRect.left,Context->WindowRect.top,
				Context->WindowRect.right,Context->WindowRect.bottom));
			break;
		case WM_SIZE:
			// Take note of the new window position. In theory we should
			// also resize our backbuffer and create a new SGL screen device.
			// This is full of problems so for the time being we block
			// sizing at the WM_SIZING message.
			GetClientRect(Context->TargetWindow,&Context->WindowRect);
			ClientToScreen(Context->TargetWindow,(LPPOINT)&Context->WindowRect);
			ClientToScreen(Context->TargetWindow,(LPPOINT)&Context->WindowRect+1);
			DPC((NAME_Log,"SGL: WM_SIZE %ix%i (%i,%i)(%i,%i)",
				Context->WindowRect.right-Context->WindowRect.left,
				Context->WindowRect.bottom-Context->WindowRect.top,
				Context->WindowRect.left,Context->WindowRect.top,
				Context->WindowRect.right,Context->WindowRect.bottom));
			// If in windowed mode, we can use this to see if we are
			// minimised or not (see of width=height=0)
			if (!Context->bFullScreen)
			{
				if (LOWORD(lParam)==0 && HIWORD(lParam)==0)
					Context->bAppActive=FALSE;
				else
					Context->bAppActive=TRUE;
			}
			break;
		case WM_SIZING:
			DPC((NAME_Log,"SGL: WM_SIZING"));
			// Prevent the window from sizing
			if (!Context->bFullScreen)
			{
				GetWindowRect(hWnd,(LPRECT)lParam);
				ReturnVal=TRUE;
				bOverrideReturnVal=TRUE;
			}			
			break;
		case WM_ACTIVATEAPP:
			DPC((NAME_Log,"SGL: WM_ACTIVATEAPP: %i",wParam));
			// If in fullscreen mode, take note of active status
			if (Context->bFullScreen)
			{
				if ((BOOL)wParam)
				{
					Context->bAppActive=TRUE;
					Sleep(500);
				}
				else
				{
					Context->bAppActive=FALSE;
					// If deactivating, wait for render to finish
					Context->DDCWaitForRenderToComplete(500);
				}
			}
			break;
		case WM_ACTIVATE:
			DPC((NAME_Log,"SGL: WM_ACTIVATE: %i",LOWORD(wParam)));
#if 0
			if (LOWORD(wParam)==WA_INACTIVE)
			{
				Sleep(500);
				Context->bAppActive=FALSE;
			}
			else if (HIWORD(wParam))	// TRUE indicates window is minimised??
			{
				Sleep(500);
				Context->bAppActive=TRUE;
			}
#endif
			break;
//		case WM_ENTERSIZEMOVE:
//todo - possibly wait for the render to finish if in windowed mode
//			DPC((NAME_Log,"SGL: WM_ENTERSIZEMOVE"));
//			break;
	}

	if (Context->bBlockMessages)
	{
		// Don't call the original procedure, just the default one.
		if( bOverrideReturnVal )
			DefWindowProc( hWnd, uMsg, wParam, lParam );
		else
			ReturnVal = DefWindowProc( hWnd, uMsg, wParam, lParam );
	}
	else
	{
		// Call original procedure
		if (bOverrideReturnVal)
			CallWindowProc((WNDPROC)Context->TargetWindowProc,hWnd,uMsg,wParam,lParam);
		else
			ReturnVal=CallWindowProc((WNDPROC)Context->TargetWindowProc,hWnd,uMsg,wParam,lParam);
	}
	return ReturnVal;
}

//******************************************************************************
// Global Functions
//******************************************************************************
//******************************************************************************
// Inits the DDC stuff and allocates a DirectDraw object
//******************************************************************************
int UDDC::DDCInit(PROC_2D_CALLBACK InProc2D)
{
    HRESULT ddrval;

	DPC((NAME_Log,"SGL: DDCInit"));

	// Load DirectDraw DLL.
	ddInstance = LoadLibrary(TEXT("ddraw.dll"));
	if(ddInstance==NULL)
	{
		DPC((NAME_Log,"SGL: DirectDraw not installed" ));
		return DDCERR_FAILED_TO_LOAD_DDRAW_DLL;
	}
	ddCreateFunc = (DD_CREATE_FUNC)GetProcAddress(ddInstance,"DirectDrawCreate");
	if(ddCreateFunc==NULL)
	{
		DPC((NAME_Log,"SGL: DirectDraw GetProcAddress failed"));
		return DDCERR_FAILED_TO_FIND_CREATE_FUNCTION;
	}
	
	// Init the Context
	SglScreenDevice=-1;

	// Put SGL in address mode
	sgl_use_address_mode(_DDCNextAddressProc,(sgl_uint32 **)&pSglStatus);
	// Enable end of render callback
	sgl_use_eor_callback(_DDCEORProc);

	// Create a DirectDraw object
	ddrval=ddCreateFunc(NULL,&dd1,NULL);

	// Get interface to DirectDraw2
	if (ddrval==DD_OK)
	{
		ddrval=dd1->QueryInterface( IID_IDirectDraw2, (void**)&dd );
	}

	// If no good, fail it
	if (ddrval!=DD_OK)
		return DDCERR_FAILED_TO_CREATE_DDRAW_OBJECT;

	// Save 2D callback address
	Proc2D=Proc2D;

	// Get the "StrickLocks" value
	sgl_get_ini_int(&iStrictLocks,0,"Defaults","StrictLocks");
#ifdef _DEBUG
	if (iStrictLocks)
	{
		DPC((NAME_Log,"SGL: StrictLocks enabled"));
	}
	else
	{
		DPC((NAME_Log,"SGL: StrictLocks not enabled"));
	}
#endif

	return DDCERR_OK;
}

//******************************************************************************
// Shuts down the DDC stuff and releases the DirectDraw object
//******************************************************************************
int UDDC::DDCShutdown()
{
	DPC((NAME_Log,"SGL: DDCShutdown"));

	// Do some checks and any necessary cleanups

	// Release SGL screen device if necessary
	if (SglScreenDevice>=0)
	{
		sgl_delete_device(SglScreenDevice);	
		SglScreenDevice=-1;
	}

	// Release clipper if necessary
	if(Clipper)
	{
		Clipper->Release();
		Clipper=NULL;
	}

#if 0
	// Release surfaces if necessary
	if (BackBackBuffer)
	{
        BackBackBuffer->Release();
		BackBackBuffer=NULL;
	}
#endif
	if (BackBuffer)
	{
        BackBuffer->Release();
		BackBuffer=NULL;
	}
	if (FrontBuffer)
	{
        FrontBuffer->Release();
		FrontBuffer=NULL;
	}
	
	// Kill timer if we have one
	if (bHaveTimer)
	{
		KillTimer(TargetWindow,0x00250771);
		bHaveTimer=FALSE;
	}
	
	// Put WindowProc back the way it was if necessary
	if (TargetWindowProc)
	{
		SetWindowLong(TargetWindow,GWL_WNDPROC,(LONG)TargetWindowProc);
		TargetWindowProc=NULL;
	}

	// Release the DirectDraw2 object
	if (dd)
	{
		dd->Release();
		dd=NULL;
	}

	// Release the DirectDraw object
	if (dd1!=NULL)
	{
		dd1->Release();
		dd1=NULL;
	}

	// Release DDRAW.DLL
	if (ddInstance)
	{
		FreeLibrary(ddInstance);
		ddInstance=NULL;
	}

	return DDCERR_OK;
}

//******************************************************************************
// Creates surfaces and a clipper if necessary so we have something to render to
//******************************************************************************
int UDDC::DDCCreateRenderingObject(HWND InTargetWindow,BOOL InFullScreen,
							 int FullScreenWidth,int FullScreenHeight,
							 int FullScreenBpp,int FullScreenNumBuffers)
{
	DWORD CooperativeLevel;
	DDSURFACEDESC ddsd;
	DDSCAPS ddscaps;
	DDPIXELFORMAT ddpixelformat;
	HRESULT ddrval;

	if (InFullScreen)
	{
		DPC((NAME_Log,"SGL: DDCCreateRenderingObject: Full screen %ix%ix%i, %i buffers",
			FullScreenWidth,FullScreenHeight,FullScreenBpp,FullScreenNumBuffers));
	}
	else
	{
		DPC((NAME_Log,"SGL: DDCCreateRenderingObject: Windowed"));
	}

	// If we already have one, get rid of it
	if (bHaveRenderingObject)
		DDCDestroyRenderingObject();

	// Set this so we can access the context from the callbacks
	CallbackContext=this;

	// Hook the window handler
	TargetWindow=InTargetWindow;
	TargetWindowProc=(WNDPROC)GetWindowLong(InTargetWindow,GWL_WNDPROC);
	SetWindowLong(InTargetWindow,GWL_WNDPROC,(LONG)_DDCWindowProc);
	bAppActive=TRUE;
	SetTimer(InTargetWindow,0x00250771,250,NULL);
	bHaveTimer=TRUE;

	// Disable passing on of Windows messages for the moment.
	bBlockMessages=TRUE;

	// Set cooperative level
	if (InFullScreen)
		CooperativeLevel=DDSCL_EXCLUSIVE | DDSCL_FULLSCREEN;
	else
		CooperativeLevel=DDSCL_NORMAL;
	if (dd->SetCooperativeLevel(InTargetWindow,CooperativeLevel)!=DD_OK)
	{
		DPC((NAME_Log,"SGL: Failed IDirectDraw2_SetCooperativeLevel (Fullscreen=%i)",InFullScreen));
		return DDCERR_FAILED_TO_SET_DDRAW_COOPERATIVE_LEVEL;
	}
	
	// Create the DirectDraw surfaces, and clipper if necessary
	memset(&ddsd,0,sizeof(ddsd));
	ddsd.dwSize=sizeof(ddsd);
	if (InFullScreen)
	{
		// For fullscreen mode
		// Adjust number of buffers to something reasonable
		if (FullScreenNumBuffers>3) 
			FullScreenNumBuffers=3;
		if (FullScreenNumBuffers<1)
			FullScreenNumBuffers=1;
		// Make sure Bpp is something we can handle
		if (FullScreenBpp>=32)
			FullScreenBpp=32;
		else if (FullScreenBpp>=24)
			FullScreenBpp=24;
		else
			FullScreenBpp=16;

		// Switch to the specified video mode
        ddrval=dd->SetDisplayMode(FullScreenWidth,FullScreenHeight,
								  FullScreenBpp,0,0);
		// If failed at 32 bpp, try 24
		if (ddrval!=DD_OK && FullScreenBpp==32)
		{
			FullScreenBpp=24;
			ddrval=dd->SetDisplayMode(FullScreenWidth,FullScreenHeight,
									  FullScreenBpp,0,0);
		}
		// If failed at 24 bpp, try 16
		if (ddrval!=DD_OK && FullScreenBpp==24)
		{
			FullScreenBpp=16;
			ddrval=dd->SetDisplayMode(FullScreenWidth,FullScreenHeight,
									  FullScreenBpp,0,0);
		}
		// If still failed, can't do that video mode
		if (ddrval!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Failed IDirectDraw2_SetDisplayMode @ %ix%ix%i",
				FullScreenWidth,FullScreenHeight,FullScreenBpp));
			return DDCERR_FAILED_TO_SET_DDRAW_VIDEO_MODE;
		}

		// First, try and allocate direct draw surface(s) as specified
		if (FullScreenNumBuffers>1)
		{
			ddsd.dwFlags = DDSD_CAPS | DDSD_BACKBUFFERCOUNT;
			ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE |
								  DDSCAPS_FLIP |
								  DDSCAPS_COMPLEX |
								  DDSCAPS_VIDEOMEMORY;
			ddsd.dwBackBufferCount=FullScreenNumBuffers-1;
		}
		else
		{
	        ddsd.dwFlags = DDSD_CAPS;
	        ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;
		}
        ddrval = dd->CreateSurface(&ddsd,&FrontBuffer,NULL);

		// If it failed and was triple buffering, try double buffering
		if (ddrval!=DD_OK && FullScreenNumBuffers==3)
		{
			FullScreenNumBuffers=2;
			ddsd.dwBackBufferCount=1;
			ddrval = dd->CreateSurface(&ddsd,&FrontBuffer,NULL);
		}
		// If it failed 32 bpp, try 24
		if (ddrval!=DD_OK && FullScreenBpp==32)
		{
			FullScreenBpp=24;
			ddrval=dd->SetDisplayMode(FullScreenWidth,FullScreenHeight,
									  FullScreenBpp,0,0);
			if (ddrval!=DD_OK)
			{
				DPC((NAME_Log,"SGL: Failed IDirectDraw2_SetDisplayMode @ %ix%ix%i",
					FullScreenWidth,FullScreenHeight,FullScreenBpp));
				return DDCERR_FAILED_TO_SET_DDRAW_VIDEO_MODE;
			}
			ddrval = dd->CreateSurface(&ddsd,&FrontBuffer,NULL);
		}
		// If it failed 24 bpp, try 16
		if (ddrval!=DD_OK && FullScreenBpp==24)
		{
			FullScreenBpp=16;
			ddrval=dd->SetDisplayMode(FullScreenWidth,FullScreenHeight,
									  FullScreenBpp,0,0);
			if (ddrval!=DD_OK)
			{
				DPC((NAME_Log,"SGL: Failed IDirectDraw2_SetDisplayMode @ %ix%ix%i",
					FullScreenWidth,FullScreenHeight,FullScreenBpp));
				return DDCERR_FAILED_TO_SET_DDRAW_VIDEO_MODE;
			}
			ddrval = dd->CreateSurface(&ddsd,&FrontBuffer,NULL);
		}
		// If it failed and was double buffering, try single buffered
		if (ddrval!=DD_OK && FullScreenNumBuffers==2)
		{
			FullScreenNumBuffers=1;
			ddsd.dwBackBufferCount=0;
	        ddsd.dwFlags = DDSD_CAPS;
	        ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;
			ddrval = dd->CreateSurface(&ddsd,&FrontBuffer,NULL);
		}
		// If it got to here and still failed, its all over
		if (ddrval!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Failed IDirectDraw2_CreateSurface @ %ix%ix%i",
				FullScreenWidth,FullScreenHeight,FullScreenBpp));
			return DDCERR_FAILED_TO_CREATE_DDRAW_SURFACE;
		}
		
		bFullScreen=TRUE;
		TargetWidth=FullScreenWidth;
		TargetHeight=FullScreenHeight;
		NumBuffers=FullScreenNumBuffers;

		// Ok, we have a surface so get attached surfaces
		switch (FullScreenNumBuffers)
		{
			case 3:
				// Get back buffer
				ddscaps.dwCaps = DDSCAPS_BACKBUFFER;
				ddrval=FrontBuffer->GetAttachedSurface(&ddscaps,
													   &BackBuffer);
#if 0
				// Get back back buffer
				if (ddrval==DD_OK)
				{
					ddrval=FrontBuffer->GetAttachedSurface(&ddscaps,
														   &BackBackBuffer);
				}
#endif
				break;
			case 2:
#if 0
				// Back back buffer is actually the front buffer
				FrontBuffer->AddRef();
				BackBackBuffer=FrontBuffer;
#endif
				// But we do have a real back buffer
				ddscaps.dwCaps = DDSCAPS_BACKBUFFER;
				ddrval=FrontBuffer->GetAttachedSurface(&ddscaps,
													 &BackBuffer);
				break;
			default:
				// Single buffer, so all buffers are the front buffer
				FrontBuffer->AddRef();
				BackBuffer=FrontBuffer;
#if 0
				FrontBuffer->AddRef();
				BackBackBuffer=FrontBuffer;
#endif
				break;
		}
		// Make sure we actually got the attached surfaces
		if (ddrval!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Failed IDirectDrawSurface2_GetAttachedSurface"));
			return DDCERR_FAILED_TO_GET_DDRAW_ATTACHED_SURFACE;
		}
		// Clear the buffers
		_DDCClearSurface(FrontBuffer);
		if (FullScreenNumBuffers>1)
			_DDCClearSurface(BackBuffer);
		
		DPC((NAME_Log,"SGL: Have full screen flipping surface: %ix%ix%i, %i buffers",
			FullScreenWidth,FullScreenHeight,FullScreenBpp,FullScreenNumBuffers));
	}
	else
	{
		// For windowed mode
		int Width,Height;
		RECT rcWindow;
        DWORD dwStyle;
		
		// Calculate the size of the window
		GetClientRect(TargetWindow,&rcWindow);
		Width=rcWindow.right-rcWindow.left;
		Height=rcWindow.bottom-rcWindow.top;
		
		// Get the front buffer surface
		ddsd.dwFlags = DDSD_CAPS;
        ddsd.ddsCaps.dwCaps = DDSCAPS_PRIMARYSURFACE;
        ddrval=dd->CreateSurface(&ddsd,&FrontBuffer,NULL);
		if (ddrval!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Failed IDirectDraw2_CreateSurface for primary surface"));
			return DDCERR_FAILED_TO_CREATE_DDRAW_SURFACE;
		}

		// Create the backbuffer surface
		ddsd.dwFlags = DDSD_CAPS | DDSD_HEIGHT |DDSD_WIDTH;
	    ddsd.ddsCaps.dwCaps = DDSCAPS_OFFSCREENPLAIN | DDSCAPS_VIDEOMEMORY;
		ddsd.dwWidth = Width;
		ddsd.dwHeight = Height;
	    ddrval=dd->CreateSurface(&ddsd,&BackBuffer,NULL);
		if (ddrval!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Failed IDirectDraw2_CreateSurface for offscreen surface @ %ix%i",
				Width,Height));
			return DDCERR_FAILED_TO_CREATE_DDRAW_SURFACE;
		}
#if 0
		// The back back buffer (the next one to be rendered to after
		// the back buffer) is the back buffer
		BackBuffer->AddRef();
		BackBackBuffer=BackBuffer;
#endif        
		// Create a clipper
		ddrval=dd->CreateClipper(0,&Clipper,NULL);
        if(ddrval!=DD_OK)
        {
			DPC((NAME_Log,"SGL: Failed IDirectDraw2_CreateClipper"));
            return DDCERR_FAILED_TO_CREATE_DDRAW_CLIPPER;
        }

        // Set the window for the clipper
		ddrval=Clipper->SetHWnd(0,TargetWindow);
        if(ddrval!=DD_OK)
        {
			DPC((NAME_Log,"SGL: Failed IDirectDrawClipper_SetHWnd"));
            return DDCERR_FAILED_TO_SET_DDRAW_CLIPPER_WINDOW;
        }

        ddrval=FrontBuffer->SetClipper(Clipper);
        if(ddrval!=DD_OK)
        {
			DPC((NAME_Log,"SGL: Failed IDirectDrawSurface2_SetClipper"));
            return DDCERR_FAILED_TO_SET_DDRAW_SURFACE_CLIPPER;
        }

		// Clear back buffer
		_DDCClearSurface(BackBuffer);

		// All ok, so save this stuff
		bFullScreen=FALSE;
		TargetWidth=Width;
		TargetHeight=Height;
		NumBuffers=2;
		GetClientRect(TargetWindow,&WindowRect);
        ClientToScreen(TargetWindow,(LPPOINT)&WindowRect);
        ClientToScreen(TargetWindow,(LPPOINT)&WindowRect+1);
		// Get rid of maximise button for the time being, since we don't
		// handle resizing
        dwStyle=GetWindowLong(TargetWindow,GWL_STYLE);
		if (dwStyle & WS_MAXIMIZEBOX)
		{
			dwStyle&=~WS_MAXIMIZEBOX;
			SetWindowLong(TargetWindow,GWL_STYLE,dwStyle);
			// Make sure we redraw the maximise box
			InvalidateRect(NULL,NULL,FALSE);
		}
	}

	// Get real BPP of rendering target
	ZeroMemory(&ddpixelformat, sizeof(ddpixelformat));
	ddpixelformat.dwSize = sizeof(ddpixelformat);
	ddrval=FrontBuffer->GetPixelFormat(&ddpixelformat);
	if (ddrval!=DD_OK)
	{
		DPC((NAME_Log,"SGL: Failed IDirectDrawSurface2_GetPixelFormat"));
		return DDCERR_FAILED_TO_GET_DDRAW_PIXEL_FORMAT;
	}
	// Default to zero
	RealBpp=0;
	// Figure it out from the returned data
	if (ddpixelformat.dwFlags & DDPF_RGB)
	{
		switch (ddpixelformat.dwRGBBitCount) /* 4 8 16 24 or 32 */
		{
			case 16:
				if (ddpixelformat.dwGBitMask & 0x0400)
					RealBpp = 16;	// 565
				else
					RealBpp = 15;	// Bit 15 not red implies 555
				break;
			case 24:
			case 32:
				RealBpp = ddpixelformat.dwRGBBitCount;
				break;
		}
	}
	// Make sure the pixel format was valid
	if (RealBpp==0)
	{
		DPC((NAME_Log,"SGL: Pixel format is invalid"));
		return DDCERR_PIXEL_FORMAT_IS_INVALID;
	}

//	Sleep(1000);

	// Call this so SGL knows the dimensions.
	SglScreenDevice=sgl_create_screen_device(0,TargetWidth,TargetHeight,sgl_device_16bit,FALSE);
	if (SglScreenDevice<0)
	{
		DPC((NAME_Log,"SGL: Failed to create SGL screen device, reason=%i",
			 GetSGLErrorString(SglScreenDevice)));
		DDCDestroyRenderingObject();
		return DDCERR_FAILED_TO_CREATE_SGL_SCREEN_DEVICE;
	}

	// Allow passing on of windows messages.
	bBlockMessages=FALSE;

	// Set flag to indicate that we have something to render to.
	bHaveRenderingObject=TRUE;
	return DDCERR_OK;
}

//******************************************************************************
// Releases the surfaces and if clippers if necessary
//******************************************************************************
int UDDC::DDCDestroyRenderingObject()
{
	DPC((NAME_Log,"SGL: DDCDestroyRenderingObject"));

	DDCWaitForRenderToComplete(500);

	// Disable passing on of Windows messages for the moment.
	bBlockMessages=TRUE;

	// Delete the SGL screen device
	if (SglScreenDevice>=0)
	{
		sgl_delete_device(SglScreenDevice);	
		SglScreenDevice=-1;
	}

	// Release clipper if necessary
	if(Clipper)
	{
		Clipper->Release();
		Clipper=NULL;
	}
#if 0
	// Release surfaces if necessary
	if (BackBackBuffer)
	{
        BackBackBuffer->Release();
		BackBackBuffer=NULL;
	}
#endif
	if (BackBuffer)
	{
        BackBuffer->Release();
		BackBuffer=NULL;
	}
	if (FrontBuffer)
	{
        FrontBuffer->Release();
		FrontBuffer=NULL;
	}

	// Kill off timer
	if (bHaveTimer)
	{
		KillTimer(TargetWindow,0x00250771);
		bHaveTimer=FALSE;
	}

	// Set co-operative level back to normal so we can set it again later
	dd->SetCooperativeLevel(TargetWindow,DDSCL_NORMAL);

	// Put WindowProc back the way it was
	if (TargetWindowProc)
	{
		SetWindowLong(TargetWindow,GWL_WNDPROC,(LONG)TargetWindowProc);
		TargetWindowProc=NULL;
	}

	// In theory the callbacks should not get called now unless something is wrong
	CallbackContext=NULL;

	// Clear any flags
	bHaveRenderingObject=FALSE;
	bAppActive=TRUE;

	// Allow passing on of windows messages.
	bBlockMessages=FALSE;

	return DDCERR_OK;
}

//******************************************************************************
// Returns some simple stuff about the current rendering object
//******************************************************************************
int UDDC::DDCGetRenderingObjectWidth()
{
	return(TargetWidth);
}

int UDDC::DDCGetRenderingObjectHeight()
{
	return(TargetHeight);
}

int UDDC::DDCGetRenderingObjectXOffset()
{
	if (bFullScreen)
		return 0;
	else
		return(WindowRect.left);
}

int UDDC::DDCGetRenderingObjectYOffset()
{
	if (bFullScreen)
		return 0;
	else
		return(WindowRect.top);
}

int UDDC::DDCGetRenderingObjectBpp()
{
	if (RealBpp==15)
		return 16;
	else
		return RealBpp;
}

int UDDC::DDCGetRenderingObjectRealBpp()
{
	return RealBpp;
}

int UDDC::DDCGetRenderingObjectNumBuffers()
{
	return(NumBuffers);
}

//******************************************************************************
// Gets the direct draw surface which represents the current front buffer
//******************************************************************************
IDirectDrawSurface *UDDC::DDCGetRenderingObjectFrontBuffer(BOOL bWaitForFlip)
{
	if (bWaitForFlip)
	{
		DDCWaitForRenderToComplete(500);
		DDCFlip();
	}
	return(FrontBuffer);
}

//******************************************************************************
// Gets the direct draw surface which contains valid data to use for a screenshot
// For full screen mode, this is the front buffer, for windowed, the back
//******************************************************************************
IDirectDrawSurface *UDDC::DDCGetRenderingObjectBufferForScreenshot(BOOL bWaitForFlip)
{
	if (bWaitForFlip)
	{
		DDCWaitForRenderToComplete(500);
		DDCFlip();
	}
	if (bFullScreen)
		return(FrontBuffer);
	else
		return(BackBuffer);
}

//******************************************************************************
// Sees if the render is active or not
//******************************************************************************
BOOL UDDC::DDCIsRenderActive()
{
	if (sgltri_isrendercomplete(&SglContext,0)==IRC_RENDER_NOT_COMPLETE)
		return TRUE;
	return FALSE;
}

//******************************************************************************
// Waits for the current render to complete if one is currently happening
// Timeout is in milliseconds
//******************************************************************************
void UDDC::DDCWaitForRenderToComplete(ULONG Timeout)
{
	ULONG Count;
	
	DPC((NAME_Log,"SGL: DDCWaitForRenderToComplete"));

	// Spin until SGL says render is complete
	for (Count=0;
		 sgltri_isrendercomplete(&SglContext,0)==IRC_RENDER_NOT_COMPLETE && Count<Timeout;
		 Count++) // This method of timing isn't very good
	{
		// Let others things do a bit while we wait
		Sleep(1);
	}
#ifdef _DEBUG
	if (Count>=Timeout)
	{
		DPC((NAME_Log,"SGL: Timeout waiting for render to complete."));
	}
#endif
}

//******************************************************************************
// Marks the start of the frame. Identical to sgltri_start of frame,
// but it lets us know when were are in the middle of a frame
//******************************************************************************
void UDDC::DDCStartOfFrame()
{
//	DPC((NAME_Log,"SGL: DDCStartOfFrame"));
	
	// Start the frame
	sgltri_startofframe(&SglContext);
	// Set this flag so we know if we are in a frame
	bInFrame=TRUE;
}

//******************************************************************************
// Starts the hardware rendering. Identical to sgltri_render, except that
// it lets us know when we are in the middle of the frame, as well
// as wait for the render to complete if strictlocks is enabled
//******************************************************************************
void UDDC::DDCRender()
{
//	DPC((NAME_Log,"SGL: DDCRender"));
	
	// Clear this flag so we know we aren't in a frame
	bInFrame=FALSE;
	// Start the render
	sgltri_render(&SglContext);
	// If StrictLocks is enabled, one of the callbacks would have
	// left the render buffer locked. In this case we must wait
	// for the render to complete, then unlock the buffer. 
	// This KILLS performance.
	if (bRenderTargetLocked)
	{
		DDCWaitForRenderToComplete(500);
		BackBuffer->Unlock(NULL);
		bRenderTargetLocked=FALSE;
		// Since the render is complete, we might as well do the flip now
		DDCFlip();
	}
}

//******************************************************************************
// Flips the backbuffer to the front, or in the case of windowed mode, 
// BLTS the backbuffer to the front.
//******************************************************************************
void UDDC::DDCFlip()
{
#if 0
	HDC hdc;
	char Buffer[512];
	static int Frame=0;
#endif
#if 0
    DDBLTFX     ddbltfx;
#endif

	// See if flip already done
	if (!bFlipPending)
		return;

	// Make sure we have something to flip
	if (!bHaveRenderingObject || !bAppActive)
		return;

	// Make sure buffers are valid
	if (BackBuffer==NULL || FrontBuffer==NULL)
		return;

	// Restore surfaces if necessary
	if (_DDCRestoreSurfacesIfLost()==FALSE)
		return;

	if (bFullScreen)
	{
		// For full screen
		if (NumBuffers>1)
		{
			if (FrontBuffer->Flip(NULL,DDFLIP_WAIT)!=DD_OK)
			{
				DPC((NAME_Log,"SGL: Flip: IDirectDrawSurface2_Flip failed"));
			}
			if (NumBuffers==2)
			{
				while (FrontBuffer->GetFlipStatus(DDGFS_ISFLIPDONE)==DDERR_WASSTILLDRAWING);
			}
		}
	}
	else
	{
		// For windowed - blt back buffer to front buffer
		if (FrontBuffer->Blt(&WindowRect,
							 BackBuffer,
							 NULL,
							 DDBLT_WAIT,
							 NULL)!=DD_OK)
		{
			DPC((NAME_Log,"SGL: Flip: IDirectDrawSurface2_Blt failed"));
		}
	}
	bFlipPending=FALSE;
	FlipTimeoutCount=0;
}
