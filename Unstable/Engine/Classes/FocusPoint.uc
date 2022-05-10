//=============================================================================
// FocusPoint.uc
// 
// OBSOLETE CLASS
//=============================================================================
class FocusPoint extends Info;

function PostBeginPlay()
{
	log( "==== Attention! This actor "$self$" at location "$Location$" with a tag of "$Tag$" is now OBSOLETE!" );
	log( "==== Please remove this actor ( "$self$" ) from your level as soon as possible. Thank you!" );
}

defaultproperties
{
	 Texture=S_Patrol
}
