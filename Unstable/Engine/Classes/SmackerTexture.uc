//=============================================================================
// SmackerTexture. (NJS)
//=============================================================================
class SmackerTexture expands TextureCanvas
	noexport
	native;

var () string filename;			// Flic's filename (should be in ..\textures)
var () float  time;				// Current time into this frame.
var () float  frameDelay;		// Seconds to delay between frames. 0 = Use Flic settings
var () int	  currentFrame;		// Current frame index the flic is on
var () bool   restartOnLoad;
var () bool	  spool;			// Spool from disk when true
var () bool	  loop;				// Loop flic when true
var () bool	  pause;			// Pause flic when true
var () bool   interlaced;
var () bool   doubled;
var () bool   centered;
var () actor  eventSource;		// Actor the event will come from.
var () name	  newFrameEvent;	// Triggered whenever a new frame is decoded.

//var () TextureCanvas Right;		// NJS: For extending to 512x512
//var () TextureCanvas Bottom;		// NJS: For extending to 512x512
//var () TextureCanvas BottomRight;	// NJS: For extending to 512x512

// Transients:
var transient string oldFilename;
var transient int   previousFrame;
var transient float frameDuration;
var transient int   handle;

native final function int GetFrameCount();

defaultproperties
{
	restartOnLoad=True
	centered=True
	loop=True
	spool=True
}