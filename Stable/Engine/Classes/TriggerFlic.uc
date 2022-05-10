//=============================================================================
// TriggerFlic. (NJS)
//=============================================================================
class TriggerFlic expands Triggers;

var () FlicTexture		tex; 	// The flic texture this trigger referrs to.
var () SmackerTexture	SmackerTex;

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
	
	if(SmackerTex!=None)
	{
		switch(loopChange)
		{
			case EL_Set: 	SmackerTex.loop=true;  	break;
			case EL_Clear:	SmackerTex.loop=false; 	break;
			case EL_Toggle: SmackerTex.loop=!SmackerTex.loop; break;
			default: break; // Do Nothing
		}

		switch(pauseChange)
		{
			case EP_Set: 	SmackerTex.pause=true;  	break;
			case EP_Clear:	SmackerTex.pause=false; 	break;
			case EP_Toggle: SmackerTex.pause=!SmackerTex.pause; break;
			default: break; // Do Nothing
		}

		if(frameDelaySet)	SmackerTex.frameDelay=frameDelay;
		if(currentFrameSet)	
		{
			if(currentFrameVariable!='') SmackerTex.currentFrame=GetVariableValue( currentFrameVariable, currentFrame );
			else						 SmackerTex.currentFrame=currentFrame;
		}
		if(filenameSet)		SmackerTex.filename=filename;
		if(paletteSet)		SmackerTex.palette=palette;		
	}
}

defaultproperties
{
    Texture=Texture'Engine.S_TrigFlic'

}
