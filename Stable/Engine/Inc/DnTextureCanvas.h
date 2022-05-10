#ifndef __DNTEXTURECANVAS_H__
#define __DNTEXTURECANVAS_H__

#include "flic.h"	// Routines for decoding flics.

/*-----------------------------------------------------------------------------
	NJS: UTextureCanvas. 
-----------------------------------------------------------------------------*/
class ENGINE_API UTextureCanvas : public UProceduralTexture
{
	DECLARE_CLASS(UTextureCanvas,UProceduralTexture,0)
	
	// Members:
	TMap< UTexture*, TArray< BYTE > >* PaletteMap;
	BYTE Dirty;			// Count of how many frames to reupload this texture

	// Constructors:
	UTextureCanvas();

	// UObject interface.
	void Serialize( FArchive& Ar );
	void Init( INT  InUSize, INT  InVSize );
	void ConstantTimeTick();
	void Destroy();

	// UTextureCanvas Interface:
	void SetDirty()		{ Dirty=2; }
	void Resize( INT InUSize, INT InVSize );
	void DrawStatic();
	void DrawPixel ( int x, int y, unsigned char color );
	void DrawLine  ( int x1, int y1, int x2, int y2, unsigned char color );
	int  DrawCharacter( UFont *font, int x, int y, char character, UBOOL masking=true );
	void DrawString( UFont *font, int x, int y, char *string, UBOOL proportional, UBOOL wrap, UBOOL masking=true );
	void DrawBitmap( int x, int y, int left, int top, int right, int bottom, UTexture *Bitmap, UBOOL masking=false, UBOOL wrap=false, UBOOL scale=false  );

	void DrawClear ( unsigned char color );
	void DrawCircle( int x, int y, int radius, unsigned char color, UBOOL filled );
	void DrawRectangle( int left, int top, int right, int bottom, unsigned char color, UBOOL filled );

	// !BR ScriptedTexture style interface.
	void DrawTile( FLOAT X, FLOAT Y, FLOAT XL, FLOAT YL, FLOAT U, FLOAT V, FLOAT UL, FLOAT VL, UTexture *Tex, FTextureInfo *Info, UBOOL bMasked, UBOOL bUseColor=0, BYTE ColorIndex=0 );
	INT DrawString( UFont* Font, INT DrawX, INT	DrawY, const TCHAR*	Text, UBOOL	bUseColor=0, BYTE PaletteEntry=0);
	void GetCharSize( UFont* Font, TCHAR InCh, INT& Width, INT& Height );

	DECLARE_FUNCTION(execDrawPixel);
	DECLARE_FUNCTION(execDrawLine);
	DECLARE_FUNCTION(execDrawString);
	DECLARE_FUNCTION(execDrawBitmap);
	DECLARE_FUNCTION(execDrawClear);
	DECLARE_FUNCTION(execDrawCircle);
	DECLARE_FUNCTION(execDrawRectangle);
	DECLARE_FUNCTION(execDrawStatic);
	DECLARE_FUNCTION(execTextSize)
	DECLARE_FUNCTION(execForceTick);
};

class ENGINE_API UStaticTexture : public UTextureCanvas
{
	DECLARE_CLASS(UStaticTexture,UTextureCanvas,0)

	// Constructors:
	UStaticTexture();

	void ConstantTimeTick();
};

class ENGINE_API UFlicTexture : public UTextureCanvas
{
	DECLARE_CLASS(UFlicTexture,UTextureCanvas,0)

	// Members:
	FString filename;//TCHAR filename[255];	  // Filename of the flic. 
	DWORD spool : 1;		  // Whether to spool the flic or not.
	DWORD loop  : 1;		  // Whether to loop the flic (or just stop on the last frame).
	DWORD pause : 1;		  // Whether the flic is paused.
	FLOAT time;				  // Current amount into the current frame.
	FLOAT frameDelay;		  // Delay between frames (in seconds)
	int   currentFrame;		  // Current frame the flic is on.
	
	AActor *eventSource;	  // Actor that the event will come from.
	FName newFrameEvent;	  // Event that triggers every frame.

	// Transients:
	FString oldFilename;//TCHAR oldFilename[255];
	int   previousFrame;
	FLOAT frameDuration;
	TFAnimation *handle;

	// Constructors:
	UFlicTexture();

	// Function Members
	void Init( INT  InUSize, INT  InVSize );
	void Serialize( FArchive& Ar );
	void SetFrame( int frameNumber );
	void __fastcall Tick( FLOAT DeltaSeconds );
};

class ENGINE_API UAVITexture : public UTextureCanvas
{
	DECLARE_CLASS(UAVITexture,UTextureCanvas,0)

	// Members:
	FString filename;//TCHAR filename[255];	  // Filename of the flic. 
	DWORD spool : 1;		  // Whether to spool the flic or not.
	DWORD loop  : 1;		  // Whether to loop the flic (or just stop on the last frame).
	DWORD pause : 1;		  // Whether the flic is paused.
	FLOAT time;				  // Current amount into the current frame.
	FLOAT frameDelay;		  // Delay between frames (in seconds)
	int   currentFrame;		  // Current frame the flic is on.
	
	AActor *eventSource;	  // Actor that the event will come from.
	FName newFrameEvent;	  // Event that triggers every frame.

	// Transients:
	FString oldFilename;//TCHAR oldFilename[255];
	int   previousFrame;
	FLOAT frameDuration;
	TFAnimation *handle;

	// Constructors:
	UAVITexture();

	// Function Members
	void Init( INT  InUSize, INT  InVSize );
	void Serialize( FArchive& Ar );
	void SetFrame( int frameNumber );
	void __fastcall Tick( FLOAT DeltaSeconds );
};

class ENGINE_API USmackerTexture : public UTextureCanvas
{
	DECLARE_CLASS(USmackerTexture,UTextureCanvas,0)

	// Members:
	FString filename;//TCHAR filename[255];	  // Filename of the flic. 
	FLOAT time;				  // Current amount into the current frame.
	FLOAT frameDelay;		  // Delay between frames (in seconds)
	int   currentFrame;		  // Current frame the flic is on.
	DWORD restartOnLoad : 1;
	DWORD spool			: 1; // Whether to spool the flic or not.
	DWORD loop			: 1; // Whether to loop the flic (or just stop on the last frame).
	DWORD pause			: 1; // Whether the flic is paused.
	DWORD interlaced	: 1; // Whether the flic is paused.
	DWORD doubled		: 1; // Whether the flic is paused.
	DWORD centered		: 1;
	
	AActor *eventSource;	  // Actor that the event will come from.
	FName newFrameEvent;	  // Event that triggers every frame.

	// Transients:
	FString oldFilename;//TCHAR oldFilename[255];
	int   previousFrame;
	FLOAT frameDuration;
	void *handle;

	// Constructors:
	USmackerTexture();

	// Members Functions:
	void Init( INT  InUSize, INT  InVSize );
	void Serialize( FArchive& Ar );
	void DumpHeader();
	void SetFrame( int frameNumber );
	void __fastcall Tick( FLOAT DeltaSeconds );
	void SetPalette();	// Sets the palette from the smack.

	DECLARE_FUNCTION(execGetFrameCount);
};

#ifdef FIXME_INABIT

class ENGINE_API UTerminalTexture : public UTextureCanvas
{
	DECLARE_CLASS(UTerminalTexture,UTextureCanvas,0)

	// Members:
	UFont		  *TerminalFont;
	unsigned char  ClearColor;
	UBOOL		   FlashingCursor;
	unsigned char  CursorCharacter;
	INT CursorRow, CursorColumn;
	INT Rows, Columns;

	// PrivateData:
	char ScreenData[4096];

	// Constructors:
	UTerminalTexture();

	// Members:
	void Serialize( FArchive& Ar );
	void Init( INT  InUSize, INT  InVSize );
	void ConstantTimeTick();

	virtual void TerminalResize();
	virtual void TerminalClear();
	virtual void TerminalDraw();
	virtual void TerminalAddChar(char character);
	virtual void TerminalAddText(char *string);
};

class ENGINE_API UCommandPromptTexture : public UTerminalTexture
{
	DECLARE_CLASS(UCommandPromptTexture,UTerminalTexture,0)

	UCommandPromptTexture();

	void TerminalAddText(char *text);
};

class ENGINE_API UTelnetTexture : public UTerminalTexture
{
	DECLARE_CLASS(UTelnetTexture,UTerminalTexture,0)

	UBOOL LocalEcho;	// Whether to use local echo or not.
	UBOOL CrLf;			// Whether to send a crlf after every line.

	int Socket;			// Transient socket handle.

	UTelnetTexture();

	// Members:
	void Serialize( FArchive& Ar );
	void Init( INT  InUSize, INT  InVSize );
	void ConstantTimeTick();

	// Terminal interface:
	void TerminalAddText(char *text);

	// Telnet texture interface:
	UBOOL TelnetConnect    (char *address);
	UBOOL TelnetDisconnect ();
	UBOOL TelnetSendText   (char *text);
	UBOOL TelnetReceiveText(char *buffer, int bufferMaxSize);
	UBOOL TelnetCommand    (char *command);
};
#endif

#ifdef CHRISSYPATCHY
class ENGINE_API UViewportTexture : public UTextureCanvas
{
	DECLARE_CLASS(UViewportTexture,UTextureCanvas,0)

	// Constructors:
	UViewportTexture();

	void Init( INT InUSize, INT InVSize );
	void Serialize( FArchive& Ar );
	void ConstantTimeTick();
};
#endif

#endif
