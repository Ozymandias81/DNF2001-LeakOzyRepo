/*=============================================================================
	DnCinematic.cpp: Code for playing cinematics.
=============================================================================*/
#pragma warning( disable : 4201 )


#include "EnginePrivate.h"
#pragma hdrstop
#pragma comment(lib,"binkw32.lib")

#pragma warning( disable : 4706 )

static HBINK bink=0;
static HBINKBUFFER binkbuf=0;
static HWND ourwind;


// draw with blackness
static void DoPaint( HWND win_handle)
{
  PAINTSTRUCT ps;

  HDC dc=BeginPaint(win_handle,&ps);  // clear the repaint flag

  PatBlt(dc,0,0,4096,4096,BLACKNESS);

  // Draw the frame (or the color mask for overlays)
  if (binkbuf)
    BinkBufferBlit( binkbuf, 0, 1 );

  EndPaint(win_handle,&ps);
}


// the main window proc
LONG FAR PASCAL WindowProc( HWND win_handle, unsigned msg, WORD wparam, LONG lparam )
{

  switch( msg )
  {
    case WM_CHAR:
      DestroyWindow(win_handle);
      break;

    case WM_SETFOCUS:
      BinkPause(bink,0);
      break;

    case WM_KILLFOCUS:
      BinkPause(bink,1);
      break;

    case WM_PAINT:
      DoPaint(win_handle);
      return(0);

    case WM_ERASEBKGND:
      return(1);

    case WM_WINDOWPOSCHANGING:
      // this insures that we are always aligned

      if ((((WINDOWPOS*)lparam)->flags&SWP_NOMOVE)==0) 
      {

        if (binkbuf) 
        {
          s32 x,y;

          x=((WINDOWPOS*)lparam)->x;
          y=((WINDOWPOS*)lparam)->y;
          BinkBufferCheckWinPos(binkbuf,&x,&y);
          ((WINDOWPOS*)lparam)->x=x;
          ((WINDOWPOS*)lparam)->y=y;

        }

      }
      break;

    case WM_WINDOWPOSCHANGED:
      if (binkbuf)
        BinkBufferSetOffset(binkbuf,0,0);
      break;

    case WM_DESTROY:
      PostQuitMessage( 0 );
      return(0);
  }
  return( DefWindowProc( win_handle, msg, wparam, lparam ) );
}


// create a class
static BOOL FirstInstance( HINSTANCE this_inst )
{
  WNDCLASS wc;
  wc.style = 0;
  wc.lpfnWndProc = (WNDPROC)(LPVOID) WindowProc;
  wc.cbClsExtra = 0;
  wc.cbWndExtra = 0;
  wc.hInstance = this_inst;
  wc.hIcon = LoadIcon(this_inst,MAKEINTRESOURCE(101));
  wc.hCursor = LoadCursor(0,IDC_ARROW);
  wc.hbrBackground = 0;
  wc.lpszMenuName = 0;
  wc.lpszClassName = _T("BinkExam");
  return( RegisterClass( &wc ) );
}


// advance to the next Bink Frame
static void NextBinkFrame( HWND win_handle )
{
  // decompress a frame
  BinkDoFrame(bink);

  // copy the data into the BinkBuffer
  //  (for overlays and primary this means on-screen!)
  if (BinkBufferLock(binkbuf))
  {
    BinkCopyToBuffer(bink,binkbuf->Buffer,binkbuf->BufferPitch,binkbuf->Height,0,0,binkbuf->SurfaceType);
    BinkBufferUnlock(binkbuf);
  }

  // blit the data onto the screen (only for off-screen and DIBs)
  BinkBufferBlit(binkbuf,bink->FrameRects,BinkGetRects(bink,binkbuf->SurfaceType));

  // advance or close the window
  if (bink->FrameNum==bink->Frames) // goto the next if not on the last
    DestroyWindow(win_handle);
  else
    BinkNextFrame(bink);

}


// main entry point
int PASCAL WinMain2( HINSTANCE this_inst, HINSTANCE prev_inst, TCHAR *cmdline,int cmdshow )
{
  MSG msg;

  cmdshow=cmdshow;

  if(!prev_inst)
    if (!FirstInstance(this_inst))
      return(1);

  ourwind=CreateWindow(  _T("BinkExam"),
                         _T("Example Player"),WS_CAPTION|WS_POPUP|WS_CLIPCHILDREN|WS_SYSMENU|WS_MINIMIZEBOX,
                         32,32,32,32,0,0,this_inst,0);
  if( !ourwind )
  {
    MessageBox(0,_T("Error creating window."),_T("Windows"),MB_OK|MB_ICONSTOP);
    return(1);
  }

  BinkSoundUseDirectSound(0); // or use: BinkSoundUseWaveOut();

  bink=BinkOpen(TCHAR_TO_ANSI(cmdline),0);
  if (!bink)
  {
    MessageBoxA(0,BinkGetError(),"Bink Error",MB_OK|MB_ICONSTOP);
    DestroyWindow(ourwind);
    return(1);
  }

  // open the Bink buffer
  binkbuf=BinkBufferOpen(ourwind,bink->Width,bink->Height,0);
  if (!binkbuf)
  {
    ShowWindow(ourwind,SW_HIDE);
    MessageBoxA(0,BinkBufferGetError(),"Bink Error",MB_OK|MB_ICONSTOP);
    DestroyWindow(ourwind);
    BinkClose(bink);
    return(1);
  }

  SetWindowPos(ourwind,0,0,0,binkbuf->WindowWidth,binkbuf->WindowHeight,SWP_NOMOVE);

  ShowWindow(ourwind,SW_SHOWNORMAL);

  BinkBufferSetOffset(binkbuf,0,0);

  for (;;)
  {
    if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE))
    {
      if (msg.message == WM_QUIT)
        break;
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
    else
    {
      if (!BinkWait(bink))
        NextBinkFrame(ourwind);
      else
        Sleep(1);
    }
  }

  if (bink)
  {
    BinkClose(bink);
    bink=0;
  }

  if (binkbuf)
  {
    BinkBufferClose(binkbuf);
    binkbuf=0;
  }

  return(0);
}































EXECFUNC(PlayCinematic)
{
	PlayCinematic(argv[1]);
}

void PlayCinematic(TCHAR *filename)
{
	WinMain2(hInstance,NULL,filename,0);

}

