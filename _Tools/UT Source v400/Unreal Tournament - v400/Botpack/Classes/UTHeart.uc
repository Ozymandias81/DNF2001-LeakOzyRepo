//=============================================================================
// UTHeart.
//=============================================================================
class UTHeart extends UTPlayerChunks;

auto state Dying
{

Begin:
	LoopAnim('Beat', 0.2);
	Sleep(0.1);
	GotoState('Dead');
}
defaultproperties
{
     Mesh=mesh'UnrealShare.PHeartM'
     CollisionRadius=+00014.000000
     CollisionHeight=+00003.000000
}
