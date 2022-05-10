/*-----------------------------------------------------------------------------
	dnBreakableGlassTrigger
	Author: John Pollard
-----------------------------------------------------------------------------*/
class dnBreakableGlassTrigger extends Triggers;

#exec OBJ LOAD FILE=..\textures\dukeed_gfx.dtx

var() name				GlassTag;
var() bool				bDirForce;
var() float				ForceScale;

//================================================================================
//	PostBeginPlay
//================================================================================
function PostBeginPlay()
{
	Super.PostBeginPlay();
}

//================================================================================
//	Trigger
//================================================================================
function Trigger(actor Other, pawn EventInstigator)
{
	local dnBReakableGlass		Glass;

	foreach AllActors(class 'dnBreakableGlass', Glass, GlassTag)
	{
		if ( Glass.Tag == GlassTag )
			Glass.ReplicateBreakGlass( Location, bDirForce, ForceScale );
	}
}

//================================================================================
//	defaultproperties
//================================================================================
defaultproperties
{
	bDirForce=true
	ForceScale=300.0f
}
