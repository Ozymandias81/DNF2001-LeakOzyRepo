//=============================================================================
// TriggerSmacker. (NJS)
//=============================================================================
class TriggerSmacker expands Triggers;

#exec Texture Import File=Textures\TrigSmk.pcx	Name=S_TrigSmk  Mips=Off Flags=2

var () SmackerTexture tex; 	// The flic texture this trigger referrs to.
var () const enum ELoopChange
{
	EL_None,
	EL_Set,
	EL_Clear,
	EL_Toggle
} loopChange;

var () const enum EPauseChange
{
	EP_None,
	EP_Set,
	EP_Clear,
	EP_Toggle
} pauseChange;

var () float frameDelay;
var () bool  frameDelaySet;

var () int   currentFrame;
var () name  currentFrameVariable;
var () bool  currentFrameSet;

var () string filename;
var () bool  filenameSet;

var () palette palette;
var () bool    paletteSet;

function Trigger( actor Other, pawn EventInstigator )
{
	if(tex!=None)
	{
		switch(loopChange)
		{
			case EL_Set: 	tex.loop=true;  	break;
			case EL_Clear:	tex.loop=false; 	break;
			case EL_Toggle: tex.loop=!tex.loop; break;
			default: break; // Do Nothing
		}

		switch(pauseChange)
		{
			case EP_Set: 	tex.pause=true;  	break;
			case EP_Clear:	tex.pause=false; 	break;
			case EP_Toggle: tex.pause=!tex.pause; break;
			default: break; // Do Nothing
		}

		if(frameDelaySet)	tex.frameDelay=frameDelay;
		if(currentFrameSet)	
		{
			if(currentFrameVariable!='') tex.currentFrame=GetVariableValue( currentFrameVariable, currentFrame );
			else						 tex.currentFrame=currentFrame;
		}
		if(filenameSet)		tex.filename=filename;
		if(paletteSet)		tex.palette=palette;		
	}
}

defaultproperties
{
    Texture=Texture'Engine.S_TrigSmk'

}
