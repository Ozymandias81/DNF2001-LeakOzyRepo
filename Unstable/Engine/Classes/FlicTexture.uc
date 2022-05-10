//=============================================================================
// FlicTexture. (NJS)
//=============================================================================
class FlicTexture expands TextureCanvas
	noexport
	native;
	
var () string filename;		// Flic's filename (should be in ..\textures
var () bool		   spool;			// Spool from disk when true
var () bool		   loop;			// Loop flic when true
var () bool		   pause;			// Pause flic when true
var () float	   time;			// Current time into this frame.
var () float	   frameDelay;		// Seconds to delay between frames. 0 = Use Flic settings
var () int		   currentFrame;	// Current frame index the flic is on
var () actor	   eventSource;		// Actor the event will come from.
var () name		   newFrameEvent;	// Triggered whenever a new frame is decoded.

// Transients:
var transient string oldFilename;
var transient int   previousFrame;
var transient float frameDuration;
var transient int   handle;

defaultproperties
{
}
