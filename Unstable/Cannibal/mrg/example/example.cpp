/**
 ** MRG
 **
 ** (c)1997-1998 Sven Technologies, Inc.
 **
 ** All rights regarding distribution, reproduction, reuse, or modification,
 ** in part or in whole, of source code, or supporting data files, are totally
 ** reserved and limited by Sven Technologies, Inc.
 **
 **/

////////////////////////////////////////////////////////////////////////////
// example.cpp
// -------
// Example of MRG

#pragma warning (disable: 4305 )

// windows includes
#include <windows.h>
#include <gl\gl.h>
#include <gl\glu.h>
#include <math.h>
#include "resource.h"
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// mrg includes
#include "mrg/model.h"
#include "mrg/matrix.h"
#include "mrg/rotation.h"
#include "mrg/manager.h"

// easy macros
#define MAX(x,y)	(((x) < (y)) ? (y) : (x))

#ifdef _MSC_VER
// Disable VC++ ridiculous warnings about "type conversion: possible loss of data"
// it would be nice to get warnings where data loss may actually occur, but VC++
// warns in many cases (e.g. int -> float) where data loss is impossible
#pragma warning( disable : 4244 )
#endif //_MSC_VER

// Mighty Mighty Models
MrgCoord3D *gModelVelocity = NULL;
MrgModel *gCurrentModel = NULL;

// Our Manager
MrgManager gManager;

// Global palette
HPALETTE hPalette = NULL;

// Application name and instance storeage
static LPCTSTR lpszAppName = "MRG Example";
static HINSTANCE hInstance;

// Graphic data
static MrgRotation sRotation;	// rotation in examining mode
static MrgRotation sOrigRot;	// original rotation when spining examiner
static POINT sDimension;		// window dimension
static MrgCoord3D sOffset;		// position in walking mode
static float sRotY = 0.0f;		// rotation in walking mode
static MrgCoord3D sWorld;		// size of world for walking mode
static MrgBoolean sTracking;	// tracking mode
static MrgCoord3D sCenter;		// center of object in examiner
static POINT sPtDown, sPtCurrent; // mouse click locations
static GLuint sFloorList=0;	// floor of walk mode display list

// Camera data
static const float	kMinNear = 0.00001;	// near plane
static const float	kMinFar = 0.01;		// far plane
static const float	kSqrt3 =	 1.732050807569;	// sqrt(3)

// Other data
static MrgBoolean sShiftDown = FALSE;	// shift key is down
static MrgBoolean sCtrlDown = FALSE;	// control key is down
static float		sFrameRate=12.0f;		// frame rate target

// constants
static const MrgUint32	kTarget=2000;			// starting polygon target
static const float TBfactor = 1.0f;	// trackball sensitivity in examiner mode
static const float	kAmbientLight[4] = { 0.3f, 0.3f, 0.3f, 1.0f }; // RGBA light source
static const GLuint kFontBase = 1000;	// display lists for fonts
static const float kWhiteMaterial[] = { 1.0f, 1.0f, 1.0f, 1.0f };	// RGBA white
static const float kRotFac = 0.0001f; // walk mode rotation sensitivity
static const float kOffsetFac = 0.00001f; // walk mode truck sensitivity
static const float kLimitFac = 0.1f;	// walk mode extension outside of world
static const float kGridSpacing = 10.0f; // floor grid spacing
static const float kGridXMaterial[] = { 0.0f, 1.0f, 0.0f, 1.0f }; // floor color along X
static const float kGridZMaterial[] = { 0.0f, 0.0f, 1.0f, 1.0f }; // floor color along Z
static const float kGridWidth = 5.0f; // floor grid line widths
static const float kVelocityFac = 1.0f; // velocity adjustment
static const float kMinVelocity = 0.0001f; // minimum velocity

// options
static MrgBoolean sShowCount = FALSE;	// showing world poly count
static MrgBoolean sWireframe = FALSE;	// showing model(s) in wireframe
static MrgBoolean sWalkAbout = FALSE;	// walk or examiner mode
static MrgBoolean sAnimate = FALSE;		// animating?
static MrgUint8	sMgrOptions = MRG_VISIBLE | MRG_AVAILABLE | MRG_DISTANCE;
static MrgBoolean	sVariable = TRUE;		// variable polygons
static MrgBoolean sUseFrameRate = FALSE;		// using target frame rate

// Function declarations
LRESULT CALLBACK WndProc( HWND hWnd,UINT message,WPARAM wParam,LPARAM lParam);
BOOL CALLBACK AboutDlgProc (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);
BOOL CALLBACK FrameRateDlgProc (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam);
void SetDCPixelFormat(HDC hDC);
void getPerspParams(MrgCoord3D& center,float& pNear,float& pFar);
void mouseDown(HWND, POINT where);
void mouseMove(HWND, POINT where);
void mouseUp(HWND, POINT where);
void computeRotation(void);
void initStuff(void);
void textOut(const MrgCoord3D& pos, const char* string);
void textOut(POINT pos, const char* string);
void computeMovement(void);
void startTimer(HWND,MrgBoolean startIt);
void drawFloor(void);
void addModel(MrgModel* model);
MrgCoord3D getNewPosition(void);
MrgCoord3D getNewVelocity(void);
void updatePositions(MrgBoolean updateVisAndDistance);
void setPolys(MrgSint16 change);
void updateCamera(MrgBoolean updatePolys);

// Renderer
extern void RenderModel(const MrgModel& model);
// Model
extern MrgModel* LoadMRGmodel(const char* filename);

// ---------------------------------------------------------------------------
// * ChangeSize
// ---------------------------------------------------------------------------
// Window Resize
void ChangeSize(GLsizei w, GLsizei h)
{
	
	// Prevent a divide by zero
	if(h == 0)
		h = 1;

	// remember
	sDimension.x = w;
	sDimension.y = h;

	// Set Viewport to window dimensions
    glViewport(0, 0, w, h);
	gManager.setScreenData(MrgCoord2Di(w,h));

	// set up perspective
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	// get viewport aspect ratio
	float aspect = (float) w / (float) h;

	float	cNear,cFar;

	// get perspective parameters
	MrgCoord3D center;
	float pNear,pFar;
	getPerspParams(center,pNear,pFar);
	cNear = pNear / 2;
	if (cNear < kMinNear)
		cNear = kMinNear;
	cFar = pFar * 2;
	if (cFar < kMinFar)
		cFar = kMinFar;
	gluPerspective(60.0f,aspect,cNear,cFar);

	// back to modelview
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	// set up camera position
	glTranslatef(-center[0],-center[1],-(center[2] + (pNear + pFar) / 2));
	// set up lights
	glLightfv(GL_LIGHT0,GL_AMBIENT,kAmbientLight);
	glEnable(GL_LIGHT0);

}


// ---------------------------------------------------------------------------
// * SetupRC
// ---------------------------------------------------------------------------
// Set up the OpenGL viewport for rendering.
void SetupRC()
{
	// enable stuff
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
	glEnable(GL_CULL_FACE);

	// let OpenGL normalize for us
	glEnable(GL_NORMALIZE);

	// set defaults
	glFrontFace(GL_CCW);
	glClearColor(0.0f,0.0f,0.0f,1.0f);

	// set default color to medium grey
	glColor3ub(128,128,128);

	// bind material properties to color
	glColorMaterial(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE);
	glEnable(GL_COLOR_MATERIAL);	
}


// ---------------------------------------------------------------------------
// * RenderScene
// ---------------------------------------------------------------------------
// Called to draw scene
void RenderScene(HDC hDC)
{
	// Clear the window and the depth buffer
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	// lines
	glPolygonMode(GL_FRONT_AND_BACK,sWireframe ? GL_LINE : GL_FILL);


	// save matrix state
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();

	// walking or examining?
	if (sWalkAbout)
	{	
		glRotatef(sRotY,0.0f,-1.0f,0.0f);
		glTranslatef(-sOffset[0],-sOffset[1],-sOffset[2]);
		// draw the floor
		if (sFloorList)
		{
			// from display list
			glCallList(sFloorList);
		}
		else
		{
			// try to make display lists
			sFloorList = glGenLists(1);
			if (sFloorList)
				glNewList(sFloorList,GL_COMPILE_AND_EXECUTE);
			drawFloor();
			if (sFloorList)
				glEndList();
		}

		
		// render models
		MrgUint16 i;
		for (i=0; i < gManager.getNumModels(); i++)
		{
			// only render if visible
			MrgBoolean visible=TRUE;
			gManager.isVisibleAt(i,visible);
			if (!visible)
				continue;

			// put in place
			glPushMatrix();
			MrgCoord3D pos(0.0f,0.0f,0.0f);
			gManager.getPositionAt(i,pos);
			glTranslatef(pos[0],pos[1],pos[2]);
			// write count
			if (sShowCount)
			{
				char string[20];
				MrgUint32 count;
				if (gManager.getPolyCountAt(i,count) == MRG_SUCCESS)
				{
					sprintf(string,"%u",count);
					// happen to 'know' that 1.0 is high enough
					textOut(MrgCoord3D(0.0f,1.0f,0.0f),string);
				}
			}
			// render
			MrgModel *model;
			if (gManager.getModelAt(i,model) == MRG_SUCCESS)
				RenderModel(*model);
			glPopMatrix();
		}
		
		// write poly count
		if (sShowCount)
		{
			char string[50];
			POINT pos;
			pos.x = pos.y = 0;
			if (sVariable)
				sprintf(string,"%u/%u",gManager.getPolyCount(),gManager.getPolyCountTarget());
			else
				sprintf(string,"%u",gManager.getPolyCount());
			textOut(pos,string);
		}

		// show frame rate
		if (sAnimate && sUseFrameRate && (sFrameRate > 0.0f))
		{
			// tell about frame
			gManager.frame();

			// create & justify string
			char string[50];
			sprintf(string,"%.2f/%.2f", gManager.getFrameRate(),sFrameRate);
			POINT pos;
			pos.x = sDimension.x/2;
			pos.y = 0;
			// draw string
			textOut(pos,string);
		}
	}
	else
	{
		// EXAMINER mode
		// apply spin rotation
		float deg;
		MrgCoord3D axis;

		// rotate it
		sRotation.getValue(axis,deg);
		if (deg)
		{
			glTranslatef(sCenter[0],sCenter[1],sCenter[2]);
			glRotatef(deg,axis[0],axis[1],axis[2]);
			glTranslatef(-sCenter[0],-sCenter[1],-sCenter[2]);
		}

		// render first model only
		if (gCurrentModel)
			RenderModel(*gCurrentModel);
		
		// write poly count
		if (sShowCount)
		{
			char string[20];
			POINT pos;
			pos.x = pos.y = 0;
			MrgUint32 count = gCurrentModel ? gCurrentModel->getNumFaces()	: 0;
			sprintf(string,"%u",count);
			textOut(pos,string);
		}
	}


	// Restore transformations
	glPopMatrix();


	// Flush drawing commands
	glFlush();
}

// ---------------------------------------------------------------------------
// * SetDCPixelFormat
// ---------------------------------------------------------------------------
// Select the pixel format for a given device context
void SetDCPixelFormat(HDC hDC)
{
	int nPixelFormat;

	static PIXELFORMATDESCRIPTOR pfd = {
		sizeof(PIXELFORMATDESCRIPTOR),  // Size of this structure
		1,                                                              // Version of this structure    
		PFD_DRAW_TO_WINDOW |                    // Draw to Window (not to bitmap)
		PFD_SUPPORT_OPENGL |					// Support OpenGL calls in window
		PFD_DOUBLEBUFFER,                       // Double buffered
		PFD_TYPE_RGBA,                          // RGBA Color mode
		24,                                     // Want 24bit color 
		0,0,0,0,0,0,                            // Not used to select mode
		0,0,                                    // Not used to select mode
		0,0,0,0,0,                              // Not used to select mode
		32,                                     // Size of depth buffer
		0,                                      // Not used to select mode
		0,                                      // Not used to select mode
		PFD_MAIN_PLANE,                         // Draw in main plane
		0,                                      // Not used to select mode
		0,0,0 };                                // Not used to select mode

	// Choose a pixel format that best matches that described in pfd
	nPixelFormat = ChoosePixelFormat(hDC, &pfd);

	// Set the pixel format for the device context
	SetPixelFormat(hDC, nPixelFormat, &pfd);
}


// ---------------------------------------------------------------------------
// * GetOpenGLPalette
// ---------------------------------------------------------------------------
// If necessary, creates a 3-3-2 palette for the device context listed.
HPALETTE GetOpenGLPalette(HDC hDC)
{
	HPALETTE hRetPal = NULL;	// Handle to palette to be created
	PIXELFORMATDESCRIPTOR pfd;	// Pixel Format Descriptor
	LOGPALETTE *pPal;			// Pointer to memory for logical palette
	int nPixelFormat;			// Pixel format index
	int nColors;				// Number of entries in palette
	int i;						// Counting variable
	BYTE RedRange,GreenRange,BlueRange;
								// Range for each color entry (7,7,and 3)


	// Get the pixel format index and retrieve the pixel format description
	nPixelFormat = GetPixelFormat(hDC);
	DescribePixelFormat(hDC, nPixelFormat, sizeof(PIXELFORMATDESCRIPTOR), &pfd);

	// Does this pixel format require a palette?  If not, do not create a
	// palette and just return NULL
	if(!(pfd.dwFlags & PFD_NEED_PALETTE))
		return NULL;

	// Number of entries in palette.  8 bits yeilds 256 entries
	nColors = 1 << pfd.cColorBits;	

	// Allocate space for a logical palette structure plus all the palette entries
	pPal = (LOGPALETTE*)malloc(sizeof(LOGPALETTE) +nColors*sizeof(PALETTEENTRY));

	// Fill in palette header 
	pPal->palVersion = 0x300;		// Windows 3.0
	pPal->palNumEntries = nColors; // table size

	// Build mask of all 1's.  This creates a number represented by having
	// the low order x bits set, where x = pfd.cRedBits, pfd.cGreenBits, and
	// pfd.cBlueBits.  
	RedRange = (1 << pfd.cRedBits) -1;
	GreenRange = (1 << pfd.cGreenBits) - 1;
	BlueRange = (1 << pfd.cBlueBits) -1;

	// Loop through all the palette entries
	for(i = 0; i < nColors; i++)
		{
		// Fill in the 8-bit equivalents for each component
		pPal->palPalEntry[i].peRed = (i >> pfd.cRedShift) & RedRange;
		pPal->palPalEntry[i].peRed = (unsigned char)(
			(double) pPal->palPalEntry[i].peRed * 255.0 / RedRange);

		pPal->palPalEntry[i].peGreen = (i >> pfd.cGreenShift) & GreenRange;
		pPal->palPalEntry[i].peGreen = (unsigned char)(
			(double)pPal->palPalEntry[i].peGreen * 255.0 / GreenRange);

		pPal->palPalEntry[i].peBlue = (i >> pfd.cBlueShift) & BlueRange;
		pPal->palPalEntry[i].peBlue = (unsigned char)(
			(double)pPal->palPalEntry[i].peBlue * 255.0 / BlueRange);

		pPal->palPalEntry[i].peFlags = (unsigned char) NULL;
		}
		

	// Create the palette
	hRetPal = CreatePalette(pPal);

	// Go ahead and select and realize the palette for this device context
	SelectPalette(hDC,hRetPal,FALSE);
	RealizePalette(hDC);

	// Free the memory used for the logical palette structure
	free(pPal);

	// Return the handle to the new palette
	return hRetPal;
}

// ---------------------------------------------------------------------------
// * WinMain
// ---------------------------------------------------------------------------
// Entry point of all Windows programs
int APIENTRY WinMain(   HINSTANCE       hInst,
						HINSTANCE       hPrevInstance,
						LPSTR           lpCmdLine,
						int                     nCmdShow)
{
	MSG             msg;            // Windows message structure
	WNDCLASS        wc;             // Windows class structure
	HWND            hWnd;           // Storeage for window handle

	hInstance = hInst;

	// Register Window style
	wc.style                = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
	wc.lpfnWndProc          = (WNDPROC) WndProc;
	wc.cbClsExtra           = 0;
	wc.cbWndExtra           = 0;
	wc.hInstance            = hInstance;
	wc.hIcon                = NULL;
	wc.hCursor              = LoadCursor(NULL, IDC_ARROW);
	
	// No need for background brush for OpenGL window
	wc.hbrBackground        = NULL;         
	
	wc.lpszMenuName         = MAKEINTRESOURCE(IDR_MENU);
	wc.lpszClassName        = lpszAppName;

	// Register the window class
	if(RegisterClass(&wc) == 0)
		return FALSE;


	// Create the main application window
	hWnd = CreateWindow(
				lpszAppName,
				lpszAppName,
				
				// OpenGL requires WS_CLIPCHILDREN and WS_CLIPSIBLINGS
				WS_OVERLAPPEDWINDOW | WS_CLIPCHILDREN | WS_CLIPSIBLINGS,
	
				// Window position and size
				50, 50,
				400, 400,
				NULL,
				NULL,
				hInstance,
				NULL);

	// If window was not created, quit
	if(hWnd == NULL)
		return FALSE;


	// Display the window
	ShowWindow(hWnd,SW_SHOW);
	UpdateWindow(hWnd);

	// Process application messages until the application closes
	while( GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}

	return msg.wParam;
}

// ---------------------------------------------------------------------------
// * WndProc
// ---------------------------------------------------------------------------
// Window procedure, handles all messages for this program
LRESULT CALLBACK WndProc(       HWND    hWnd,
							UINT    message,
							WPARAM  wParam,
							LPARAM  lParam)
{
	static HGLRC hRC;               // Permenant Rendering context
	static HDC hDC;                 // Private GDI Device context

	switch (message)
	{
		// Window creation, setup for OpenGL
		case WM_CREATE:
			// Store the device context
			hDC = GetDC(hWnd);              

			// Select the pixel format
			SetDCPixelFormat(hDC);          

			// Create palette if needed
			hPalette = GetOpenGLPalette(hDC);

			// Create the rendering context and make it current
			hRC = wglCreateContext(hDC);
			wglMakeCurrent(hDC, hRC);
			
			// Call OpenGL setup code
			SetupRC();
			
			// create ASCII font display lists
			wglUseFontBitmaps(hDC, 0, 255, kFontBase); 

			// init other stuff
			initStuff();
			
			// Fetch hither a model
			addModel(LoadMRGmodel(NULL));

			break;

		// Window is being destroyed, cleanup
		case WM_DESTROY:
			// delete font lists
			glDeleteLists(kFontBase,256);

			// delete floor list
			glDeleteLists(sFloorList,1);

			// Deselect the current rendering context and delete it
			wglMakeCurrent(hDC,NULL);
			wglDeleteContext(hRC);

			ReleaseDC(hWnd,hDC);

			// Delete the palette if it was created
			if(hPalette != NULL)
				DeleteObject(hPalette);
			
			// delete all models
			gManager.clearAndDelete();

			// delete the global model velocity list
			delete [] gModelVelocity;
			
			// Tell the application to terminate after the window
			// is gone.
			PostQuitMessage(0);
			break;

		// Window is resized.
		case WM_SIZE:
			// Call our function which modifies the clipping
			// volume and viewport
			ChangeSize(LOWORD(lParam), HIWORD(lParam));
			break;


		// The painting function.  This message sent by Windows 
		// whenever the screen needs updating.
		case WM_PAINT:
			{
			// Call OpenGL drawing code
			RenderScene(hDC);

			SwapBuffers(hDC);

			// Validate the newly painted client area
			ValidateRect(hWnd,NULL);
			}
			break;


		// Windows is telling the application that it may modify
		// the system palette.  This message in essance asks the 
		// application for a new palette.
		case WM_QUERYNEWPALETTE:
			// If the palette was created.
			if(hPalette)
				{
				int nRet;

				// Selects the palette into the current device context
				SelectPalette(hDC, hPalette, FALSE);

				// Map entries from the currently selected palette to
				// the system palette.  The return value is the number 
				// of palette entries modified.
				nRet = RealizePalette(hDC);

				// Repaint, forces remap of palette in current window
				InvalidateRect(hWnd,NULL,FALSE);

				return nRet;
				}
			break;

	
		// This window may set the palette, even though it is not the 
		// currently active window.
		case WM_PALETTECHANGED:
			// Don't do anything if the palette does not exist, or if
			// this is the window that changed the palette.
			if((hPalette != NULL) && ((HWND)wParam != hWnd))
				{
				// Select the palette into the device context
				SelectPalette(hDC,hPalette,FALSE);

				// Map entries to system palette
				RealizePalette(hDC);
				
				// Remap the current colors to the newly realized palette
				UpdateColors(hDC);
				return 0;
				}
			break;

		// Mouse Buttons & Movement
		case WM_MOUSEMOVE:
			{
				// mouse is moving...
				POINT point;
				point.x = (MrgSint16)LOWORD(lParam);
				point.y = (MrgSint16)HIWORD(lParam);
				mouseMove(hWnd,point);			
			}
			break;
		case WM_LBUTTONDOWN:
			{
				// left mouse button pressed
				POINT point;
				point.x = (MrgSint16)LOWORD(lParam);
				point.y = (MrgSint16)HIWORD(lParam);
				mouseDown(hWnd,point);			
			}
			break;
		case WM_LBUTTONUP:
			{
				// left mouse button released...
				POINT point;
				point.x = (MrgSint16)LOWORD(lParam);
				point.y = (MrgSint16)HIWORD(lParam);
				mouseUp(hWnd,point);			
			}
			break;
		case WM_KEYDOWN:
			{
				// a key is pressed
				switch ((int)wParam)
				{
				case VK_UP:
				case VK_DOWN:
					// adjust polycounts
					setPolys(((int)wParam == VK_DOWN ? -1 : 1) * (sShiftDown ? 10 : 1) * (sCtrlDown ? 100 : 1));
					InvalidateRect(hWnd,NULL,FALSE);
					break;
					// remember modifier key pressess
				case VK_SHIFT:
					sShiftDown = TRUE;
					break;
				case VK_CONTROL:
					sCtrlDown = TRUE;
					break;
				}

			}
			break;
		case WM_KEYUP:
			// a key is released
			{
				switch ((int)wParam)
				{
					// remember modifier key presses
				case VK_SHIFT:
					sShiftDown = FALSE;
					break;
				case VK_CONTROL:
					sCtrlDown = FALSE;
					break;
				}

			}
			break;	
	
			// our timer
		case WM_TIMER:
			// update animating model positions
			if (sAnimate)
				updatePositions(!sTracking);
			// update camera location when tracking
			if (sTracking)
				computeMovement();
			// update poly count if nec.
			if ((sMgrOptions & MRG_DISTANCE) || (sMgrOptions & MRG_VISIBLE))
				gManager.updatePolyCount();
			// refresh
			InvalidateRect(hWnd,NULL,FALSE);
			break;

		// A menu command
		case WM_COMMAND:
			{
			HMENU hMenu = GetMenu(hWnd);
			WORD cmd = LOWORD(wParam);
			switch(cmd)
				{
				// Exit the program
				case ID_FILE_EXIT:
					DestroyWindow(hWnd);
					break;

				// Display the about box
				case ID_HELP_ABOUT:
					{
						MrgBoolean wasAnim, wasRate;
						if (wasAnim = sAnimate)
						{
							// if animating, we must pause for dialog box
							startTimer(hWnd,FALSE);
							if (wasRate = sUseFrameRate)
							{
								gManager.setFrameRateTarget(0.0f);
								sUseFrameRate = FALSE;
							}
							sAnimate = FALSE;
						}
						DialogBox (hInstance,
							MAKEINTRESOURCE(IDD_DIALOG_ABOUT),
							hWnd,
							(DLGPROC)AboutDlgProc);
						if (wasAnim)
						{
							sAnimate = TRUE;

							// if animating, we now resume
							if (sWalkAbout)
								startTimer(hWnd,TRUE);
							if (wasRate)
							{
								if (sWalkAbout)
									gManager.setFrameRateTarget(sFrameRate);
								sUseFrameRate = TRUE;
							}

						}
					}
					break;

				// Display the frame rate box
				case ID_OPTIONS_SETRATE:
					{
						MrgBoolean wasAnim, wasRate;
						if (wasAnim = sAnimate)
						{
							// if animating, we must pause for dialog box
							startTimer(hWnd,FALSE);
							if (wasRate = sUseFrameRate)
							{
								gManager.setFrameRateTarget(0.0f);
								sUseFrameRate = FALSE;
							}
							sAnimate = FALSE;
						}
						DialogBox (hInstance,
							MAKEINTRESOURCE(IDD_TARGET_RATE),
							hWnd,
							(DLGPROC)FrameRateDlgProc);
						if (wasAnim)
						{
							sAnimate = TRUE;

							// if animating, we now resume
							if (sWalkAbout)
								startTimer(hWnd,TRUE);
							if (wasRate)
							{
								if (sWalkAbout)
									gManager.setFrameRateTarget(sFrameRate);
								sUseFrameRate = TRUE;
							}

						}
					}
					break;

					// options
				case ID_OPTIONS_WIREFRAME:
					// wireframe on/off
					sWireframe = !sWireframe;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sWireframe ? MF_CHECKED : MF_UNCHECKED));
					InvalidateRect(hWnd,NULL,FALSE);
					break;

				case ID_OPTIONS_COUNT:
					// showing count on/off
					sShowCount= !sShowCount;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sShowCount ? MF_CHECKED : MF_UNCHECKED));
					InvalidateRect(hWnd,NULL,FALSE);
					break;

				case ID_OPTIONS_WALKABOUT:
					// walk or examine mode
					sWalkAbout = !sWalkAbout;
					if (!(sWalkAbout && sAnimate))
						startTimer(hWnd,FALSE); // stop timer, just in case
					else
						startTimer(hWnd,TRUE);	// start timer for animation
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sWalkAbout ? MF_CHECKED : MF_UNCHECKED));
					// force resize to setup camera perspective
					ChangeSize(sDimension.x,sDimension.y);
					// update position in walk mode
					if (sWalkAbout)
						updateCamera(TRUE);
					InvalidateRect(hWnd,NULL,FALSE);
					break;

				case ID_MYFILE_OPEN:
					{
						// set openfilenmame structure
						OPENFILENAME ofn;
						memset(&ofn,0,sizeof(OPENFILENAME));
						ofn.lStructSize = sizeof(OPENFILENAME);
						ofn.hwndOwner = hWnd;
						ofn.hInstance = hInstance;
						ofn.Flags = OFN_FILEMUSTEXIST | OFN_HIDEREADONLY | OFN_EXPLORER;
						ofn.lpstrDefExt = "*.mrg";
						char filename[512];
						filename[0] = 0;
						ofn.lpstrFile = filename;
						ofn.nMaxFile = 512;
						ofn.lpstrFilter = "MRG Files (*.mrg)\0*.mrg\0All Files (*.*)\0*.*\0\0";

						// get file from dialog
						if (GetOpenFileName(&ofn))
						{
							// show wait cursor
							HCURSOR prev = SetCursor(LoadCursor(NULL,IDC_WAIT));

							// try to load it
							MrgModel* model = LoadMRGmodel(ofn.lpstrFile);

							if (model)
							{
								// add it
								addModel(gCurrentModel = model);
								// force resize to setup camera perspective
								ChangeSize(sDimension.x,sDimension.y);
								// refresh
								InvalidateRect(hWnd,NULL,FALSE);
							}
							
							// restore cursor
							SetCursor(prev);
						}
					}
					break;

				case ID_FILE_ADD:
					{
						// add another model
						addModel(gCurrentModel = new MrgModel(*gCurrentModel));
						// refresh
						InvalidateRect(hWnd,NULL,FALSE);
					}
					break;
					
				case ID_OPTIONS_ANIMATE:
					// animate on/off
					sAnimate = !sAnimate;
					if (!(sWalkAbout && sAnimate))
						startTimer(hWnd,FALSE); // stop timer, just in case
					else
						startTimer(hWnd,TRUE);	// start timer for animation
					// turn on frame tracking if appropriate
					if (sWalkAbout && sUseFrameRate && sVariable)
						gManager.setFrameRateTarget(sAnimate ? sFrameRate : 0.0f);
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sAnimate ? MF_CHECKED : MF_UNCHECKED));
					break;

				case ID_OPTIONS_VISIBLE:
					// visiblity management option on/off
					sMgrOptions ^= MRG_VISIBLE;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sMgrOptions & MRG_VISIBLE ? MF_CHECKED : MF_UNCHECKED));
					gManager.setOptions(sMgrOptions);
					// update camera info (visiblity has changed)
					updateCamera(TRUE);
					// refresh
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_OPTIONS_AVAILABLE:
					// availability management option on/off
					sMgrOptions ^= MRG_AVAILABLE;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sMgrOptions & MRG_AVAILABLE? MF_CHECKED : MF_UNCHECKED));
					gManager.setOptions(sMgrOptions);
					// update poly counts, management option changed
					gManager.updatePolyCount();
					// refresh
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_OPTIONS_DISTANCE:
					// distacne management option on/off
					sMgrOptions ^= MRG_DISTANCE;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sMgrOptions & MRG_DISTANCE ? MF_CHECKED : MF_UNCHECKED));
					gManager.setOptions(sMgrOptions);
					// update poly count, management option changed
					gManager.updatePolyCount();
					// refresh
					InvalidateRect(hWnd,NULL,FALSE);
					break;

				case ID_OPTIONS_VARIABLE:
					// variable polygon counts (use MRG) on/off?
					sVariable = !sVariable;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sVariable ? MF_CHECKED : MF_UNCHECKED));
					// update poly counts (no change to target)
					setPolys(0);
					// set frame rate target if appropriate
					if (sUseFrameRate && sAnimate && sWalkAbout)
						gManager.setFrameRateTarget(sVariable ? sFrameRate : 0.0f);
					
					// refresh
					InvalidateRect(hWnd,NULL,FALSE);
					break;

					// change polygon targets:
				case ID_POLY_M1000:
					setPolys(-1000);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_M100:
					setPolys(-100);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_M10:
					setPolys(-10);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_M1:
					setPolys(-1);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_P1000:
					setPolys(1000);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_P100:
					setPolys(100);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_P10:
					setPolys(10);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				case ID_POLY_P1:
					setPolys(1);
					InvalidateRect(hWnd,NULL,FALSE);
					break;
				
					// frame rate options
				case ID_OPTIONS_RATE:
					sUseFrameRate = !sUseFrameRate;
					CheckMenuItem(hMenu, cmd, MF_BYCOMMAND | (sUseFrameRate ? MF_CHECKED : MF_UNCHECKED));
					if (sAnimate && sVariable && sWalkAbout)
						gManager.setFrameRateTarget(sUseFrameRate ? sFrameRate : 0.0f);
					break;
					
					

				}
			}
			break;


	default:   // Passes it on if unproccessed
	    return (DefWindowProc(hWnd, message, wParam, lParam));

	}

    return (0L);
	}

// ---------------------------------------------------------------------------
// * AboutDlgProc
// ---------------------------------------------------------------------------
// dialog callback
BOOL CALLBACK AboutDlgProc (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
	{
	
    switch (message)
	{
		// Process command messages
	    case WM_COMMAND:      
			{
			// Validate and Make the changes
			if(LOWORD(wParam) == IDOK)
				EndDialog(hDlg,TRUE);
		    }
			break;

		// Closed from sysbox
		case WM_CLOSE:
			EndDialog(hDlg,TRUE);
			break;
		}

	return FALSE;
	}


// ---------------------------------------------------------------------------
// * FrameRateDlgProc
//---------------------------------------------------------------------
// frame rate dialog callback
BOOL CALLBACK FrameRateDlgProc (HWND hDlg, UINT message, WPARAM wParam, LPARAM lParam)
{
	
    
	switch (message)
	{
		// init dialog
	case WM_INITDIALOG:
		{
			char string[32];
			sprintf(string,"%.2f",sFrameRate);
			SetDlgItemText(hDlg, IDC_FRAMERATE, string);
		}
		break;
		

	// Process command messages
	case WM_COMMAND:      
		{
			WORD cmd = LOWORD(wParam);
			switch (cmd)
			{
			case IDOK:
			case IDCANCEL:

				if (cmd == IDOK)
				{
					// user pressed ok, get frame rate data
					char string[32];
					if (GetDlgItemText(hDlg, IDC_FRAMERATE, string, 31))
					{
						// convert to float
						sFrameRate = atof(string);
						if (sFrameRate < 0.0f)
							sFrameRate = 0.0f;

						// tell manager
						if (sAnimate && sUseFrameRate && sVariable && sWalkAbout)
							gManager.setFrameRateTarget(sFrameRate);
					}
				}
					
				EndDialog(hDlg,TRUE);
				break;
			}


		
		}
		break;
	// Closed from sysbox
	case WM_CLOSE:
		EndDialog(hDlg,TRUE);
		break;
	}

	return FALSE;
}

// ---------------------------------------------------------------------------
// * getPerspParams
// ---------------------------------------------------------------------------
// Get perspective projection parameters. Center is the center of the scene,
// and pNear and pFar are the near and far clipping planes, computed such that
// the entire scene is always visible. For a standard render area, it is
// calculated based on a cylinder about the y-axis.

void
getPerspParams(MrgCoord3D& center,float& pNear,float& pFar)
{
	
	// walking or examining?	
	if (sWalkAbout)
	{
		// walking

		pNear = 0.0001f;
		float dx, dz;
		dx = sWorld[0];
		dz = sWorld[2];

		pFar = sqrt((dx*dx) + (dz*dz));
		
		// set center to origin
		center.setValue(0.0f,1.0f,-((pNear + pFar)/2));
	}
	else
	{
		// examining

		MrgCoord3D	min,max;
		float			diagonal;
		float			aspect;

		// get the bounding box
		if (gCurrentModel)
			gCurrentModel->getBoundingBox(MrgMatrix::identity(),min,max);
		else
		{
			min.setValue(0.0f,0.0f,0.0f);
			max.setValue(0.0f,0.0f,0.0f);
		}

		// the model rotates about its bounding box center
		center.setValue((max[0] + min[0]) / 2,(max[1] + min[1]) / 2,(max[2] + min[2]) / 2);
		sCenter = center;
		
		float dx,dy,dz;
		// compute maximum diagonal
		dx = max[0] - min[0];
		dy = max[1] - min[1];
		dz = max[2] - min[2];
		diagonal = sqrt(dx * dx + dy * dy + dz * dz);

		// near clipping plane is set so the entire cylinder is visible. for height,
		// we make sure the whole height is visible in a 60 degree field of view.
		// for width, the tangent from the eye to the cylinder 
		aspect = (float) sDimension.x / (float)sDimension.y;
		pNear = diagonal / 2;
		if (aspect < 1.0)
			pNear *= (sqrt(aspect * aspect + 3) - aspect) / aspect;
		pFar = pNear + diagonal;
	}
}

// ---------------------------------------------------------------------------
// * mouseDown
// ---------------------------------------------------------------------------
// The mouse button was pressed inside the render area.

void
mouseDown(HWND hWnd, POINT where)
{

	// start tracking
	sPtCurrent = sPtDown = where;
	sTracking = TRUE;
	sOrigRot = sRotation;

	// start timer if walking
	if (sWalkAbout && !sAnimate)
		startTimer(hWnd,TRUE);

	// grab focus
	SetCapture(hWnd);
}



// ---------------------------------------------------------------------------
// * mouseMove
// ---------------------------------------------------------------------------
// The mouse has moved

void
mouseMove(HWND hWnd, POINT where)
{
	// only do anything if tracking
	if (sTracking)
	{
		// save current point
		sPtCurrent = where;

		// if not walking around
		if (!sWalkAbout)
		{
			// calculate rotation
			computeRotation();

			// refresh the display
			InvalidateRect(hWnd,NULL,FALSE);
		}
	}
}


// ---------------------------------------------------------------------------
// * mouseUp
// ---------------------------------------------------------------------------
// The mouse button was released

void
mouseUp(HWND hWnd, POINT where)
{
	// should be tracking already
	if (sTracking)
	{
		// end tracking
		sTracking = FALSE;

		// release focus
		ReleaseCapture();

		// final refresh
		sPtCurrent = where;
		// are we walking around?
		if (sWalkAbout)
		{
			computeMovement();
			// stop timer
			if (!sAnimate)
				startTimer(hWnd,FALSE);
		}
		else
			computeRotation();
		
		// Refresh
		InvalidateRect(hWnd,NULL,FALSE);
	}
}


// ---------------------------------------------------------------------------
// * computeRotation
// ---------------------------------------------------------------------------
// compute the rotation

void
computeRotation(void)
{
	// axis of rotation (perpendicular to vector from PtDown to PtCurrent
	MrgCoord3D axis(sPtCurrent.y - sPtDown.y,sPtCurrent.x - sPtDown.x,0);

	// angle for rotation
	float ang = axis.length();

	sRotation.setValue(axis,ang);

	MrgRotation tmp = sOrigRot;
	tmp *= sRotation;

	sRotation = tmp;
}

// ---------------------------------------------------------------------------
// * initStuff
// ---------------------------------------------------------------------------
//initialize world data
void
initStuff(void)
{
	sRotation = MrgRotation::identity();
	sOffset.setValue(0.0f,0.0f,0.0f);
	sWorld.setValue(50.0f,1.8f,50.0f);

   /* Seed the random-number generator with current time so that
    * the numbers will be different every time we run.
    */
   srand( (unsigned)time( NULL ) );

	// tell manager about new camera data
	updateCamera(FALSE);
	// set options
	gManager.setOptions(sMgrOptions);
	// set default target
	MrgUint32 actual;
	gManager.setPolyCount(kTarget,actual);

}

// ---------------------------------------------------------------------------
// * textOut
// ---------------------------------------------------------------------------
// write out text at a 3D location
void
textOut(const MrgCoord3D &pos, const char *string)
{	
	// save raster pos
	glPushAttrib(GL_CURRENT_BIT | GL_LIGHTING_BIT | GL_LIST_BIT);

	// make white text
	glDisable(GL_LIGHTING);
	glColor4fv(kWhiteMaterial);

	// set raster position
	glRasterPos3f(pos[0],pos[1],pos[2]);
	
	// start with font base
	glListBase(kFontBase);

	// draw it
	glCallLists(strlen(string),GL_UNSIGNED_BYTE,string);

	// restore raster pos
	glPopAttrib();
}

// ---------------------------------------------------------------------------
// * textOut
// ---------------------------------------------------------------------------
// write out text at a 2D location
void
textOut(POINT pos, const char *string)
{	
	// save raster pos
	glPushAttrib(GL_CURRENT_BIT | GL_LIGHTING_BIT | GL_LIST_BIT);

	// make sure texturing is disabled
	glDisable(GL_TEXTURE_2D);

	// establish orthographic projection
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
	glOrtho(0.0,sDimension.x,0.0,sDimension.y,-1.0,1.0);
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	// make white text
	glDisable(GL_LIGHTING);
	glColor4fv(kWhiteMaterial);

	// set raster position
	glRasterPos2f(pos.x,pos.y);
	
	// start with font base
	glListBase(kFontBase);

	// draw it
	glCallLists(strlen(string),GL_UNSIGNED_BYTE,string);

	// restore original matrix
	glPopMatrix();
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();
	glMatrixMode(GL_MODELVIEW);

	// restore raster pos
	glPopAttrib();
}

// ---------------------------------------------------------------------------
// * computeMovement
// ---------------------------------------------------------------------------
// compute the movement
void
computeMovement(void)
{

	
	// do rotation first
	float dx = sPtCurrent.x - sPtDown.x;
	sRotY -= (dx > 0 ? 1 : -1 ) * dx * dx * kRotFac;

	// now offset
	float dy =  sPtCurrent.y - sPtDown.y ;
	float dist = (dy > 0 ? 1 : -1 ) * dy * dy * kOffsetFac;
	float rads = (sRotY - 180.0f) * M_PI / 180.0f;
	sOffset[0] -= (dist * sin(rads));
	sOffset[2] -= (dist * cos(rads));

	// apply limits to movement
	MrgCoord3D min,max;
	float width, depth;
	//getModelBoundingBox(min,max);
	max.setValue(sWorld[0]/2,0.0f,sWorld[2]/2);
	min.setValue(-sWorld[0]/2,0.0f,-sWorld[2]/2);

	width = kLimitFac * (max[0] - min[0]);
	depth = kLimitFac * (max[2] - min[2]);

	if (sOffset[0] < (min[0] - width))
		sOffset[0] = min[0] - width;
	if (sOffset[2] < (min[2] - depth))
		sOffset[2] = min[2] - depth;
	if (sOffset[0] > (max[0] + width))
		sOffset[0] = max[0] + width;
	if (sOffset[2] > (max[2] + depth))
		sOffset[2] = max[2] + depth;

	// tell manager about new camera data
	updateCamera(FALSE);
}

// ---------------------------------------------------------------------------
// * startTimer
// ---------------------------------------------------------------------------
// start or stop the timer
void
startTimer(HWND hWnd, MrgBoolean startIt)
{
	if (startIt)
	{
		// start timer
		SetTimer(hWnd,0,1,NULL);
	}
	else
	{
		// stop it
		KillTimer(hWnd,0);
	}
}

// ---------------------------------------------------------------------------
// * drawFloor
// ---------------------------------------------------------------------------
// draw the floor
void
drawFloor(void)
{
	MrgUint8 i;
	// create "floor"
	float dx,dz;
	dx = ((float)sWorld[0]) / kGridSpacing;
	dz = ((float)sWorld[2]) / kGridSpacing;
	float x,z;
	x = z = 0.0f;
	float baseX, baseY, baseZ;
	baseX = -sWorld[0]/2.0f;
	baseZ = -sWorld[2]/2.0f;
	baseY = -sWorld[1]/2.0f;
	
	// draw lines
	glPushAttrib(GL_CURRENT_BIT | GL_POLYGON_BIT| GL_LINE_BIT | GL_LIGHTING_BIT | GL_ENABLE_BIT); // save line & material settings
	// set grid material & line width
	float matX[4];
	float matZ[4];
	memcpy (matX,kGridXMaterial,4 * sizeof(float));
	memcpy (matZ,kGridZMaterial,4 * sizeof(float));
	glLineWidth(kGridWidth);
	// draw grid as lines
	glBegin(GL_LINES);
	for (i=0; i <= kGridSpacing; i++)
	{
		// define each line, normals, and materials
		glColor4fv(matX);
		glNormal3f(0.0f,1.0f,0.0f);
		glVertex3f(x+baseX,baseY,baseZ);
		glNormal3f(0.0f,1.0f,0.0f);
		glVertex3f(x+baseX,baseY,sWorld[2]+baseZ);
		glColor4fv(matZ);
		glNormal3f(0.0f,1.0f,0.0f);
		glVertex3f(baseX,baseY,z+baseZ);
		glNormal3f(0.0f,1.0f,0.0f);
		glVertex3f((float)sWorld[0]+baseX,baseY,z+baseZ);
		x += dx;
		z += dz;
		// adjust material such that we fade from starting axis colors
		// at the minimum point to white at the maximum point
		for (int j=0; j < 4; j++)
		{
			matX[j] += (1.0f / kGridSpacing);
			if (matX[j] > 1.0f)
				matX[j] = 1.0f;
			matZ[j] += (1.0f / kGridSpacing);
			if (matZ[j] > 1.0f)
				matZ[j] = 1.0f;
		}
		
	}
	glEnd();
	glPopAttrib(); // restore line & material settings
}

// ---------------------------------------------------------------------------
// * addModel
// ---------------------------------------------------------------------------
// add a model to management
void
addModel(MrgModel *model)
{
	// allocate new lists
	MrgUint16 num = gManager.getNumModels();
	MrgCoord3D* newVelList = new MrgCoord3D[num+1];

	// copy old lists
	if (num> 0)
	{
		memcpy(newVelList,gModelVelocity,num * sizeof(MrgCoord3D));
	}

	// add new items
	newVelList[num] = getNewVelocity();
	// check velocity
	MrgUint8 j;
	for (j=0; j < 3; j+=2)
	{
		float& vel = newVelList[num][j];
		if (fabs(vel) < kMinVelocity)
			vel = (vel < 0 ? -1.0f : 1.0f) * kMinVelocity;
	}


	// reassign global lists
	delete [] gModelVelocity;
	gModelVelocity = newVelList;

	// manage it
	gManager.add(model,FALSE);
	gManager.setPosition(model,getNewPosition());
	gManager.updatePolyCount();

	// remember it
	gCurrentModel = model;
}

// ---------------------------------------------------------------------------
// * getNewPostiion
// ---------------------------------------------------------------------------
// gimme a new position
MrgCoord3D
getNewPosition(void)
{
	MrgCoord3D rtrn(getNewVelocity());
	rtrn[0] *= sWorld[0]/2;
	rtrn[2] *= sWorld[2]/2;
	return rtrn;
}

// ---------------------------------------------------------------------------
// * getNewVelocity
// ---------------------------------------------------------------------------
// gimme a new velocity (each vector is (-1,1))
MrgCoord3D
getNewVelocity(void)
{
	float x,z;
	x = ((float)(rand() - (RAND_MAX / 2)))/ (float)(RAND_MAX/2);
	z = ((float)(rand() - (RAND_MAX / 2)))/ (float)(RAND_MAX/2);
	MrgCoord3D rtrn(x,0.0f,z);
	return rtrn;
}

// ---------------------------------------------------------------------------
// * updatePositions
// ---------------------------------------------------------------------------
// update positions of all models
void
updatePositions(MrgBoolean updateVisAndDist)
{

	MrgUint16 i;
	for (i=0; i < gManager.getNumModels(); i++)
	{
		// mult by velocity
		MrgUint8 j;
		MrgBoolean newVelocity = FALSE;
		MrgCoord3D pos;
		gManager.getPositionAt(i,pos);
		for (j=0; j < 3; j++)
		{
			float& v = pos[j];
			float& vel = gModelVelocity[i][j];
			v += (vel * kVelocityFac);

			// check bounds
			if (v < -sWorld[j] / 2.0f)
			{
				v = -sWorld[j] / 2.0f;
				newVelocity = TRUE;
			}
			else if (v > sWorld[j] / 2.0f)
			{
				v = sWorld[j] / 2.0f;
				newVelocity = TRUE;
			}
		}

		// pick a new velocity
		if (newVelocity)
		{
			gModelVelocity[i] = getNewVelocity();
			MrgUint8 j;
			for (j=0; j < 3; j+=2)
			{
				float& vel = gModelVelocity[i][j];
				if (fabs(vel) < kMinVelocity)
					vel = (vel < 0 ? -1.0f : 1.0f) * kMinVelocity;
			}
			
		}
		// tell the manager about new position
		gManager.setPositionAt(i,pos,updateVisAndDist);
	}
}

// ---------------------------------------------------------------------------
// * setPolys
// ---------------------------------------------------------------------------
// change number of polys
void
setPolys(MrgSint16 change)
{
	// change either whole world or just examined one
	if (sWalkAbout)
	{
		// whole world
		MrgUint32 actual,target;
		target = gManager.getPolyCountTarget();
		if (sVariable && (change < 0) && (target <= (MrgUint32)-change))
			return;
		gManager.setPolyCount(sVariable ? target + change : 0,actual);
	}
	else
	{
		if (!gCurrentModel)
			return;

		// examined one
		MrgUint32 count;
		if (gManager.getPolyCount(gCurrentModel,count) == MRG_SUCCESS)
		{
			if (sVariable && (change < 0) && (count <= (MrgUint32)-change))
				return;

			MrgUint32 actual;
			gManager.setPolyCount(gCurrentModel,sVariable ? count + change : 0,actual);
		}
	}
}

// ---------------------------------------------------------------------------
// * updateCamera
// ---------------------------------------------------------------------------
// update the camera data in manager
void
updateCamera(MrgBoolean updatePolys)
{
	// tell manager about new camera data
	float radRot = (sRotY-180.0f) * M_PI / 180.0f;
	MrgCoord3D dir(sin(radRot),0.0f,cos(radRot));
	gManager.setCameraData(sOffset, dir, 60.0f);

	// update polys if appropriate
	if (updatePolys)
		gManager.updatePolyCount();
}
