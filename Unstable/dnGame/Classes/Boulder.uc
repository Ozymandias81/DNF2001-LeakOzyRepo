/*-----------------------------------------------------------------------------
	Boulder
	Author: From Unreal, in here for Level Desginers dependent on old stuff.
-----------------------------------------------------------------------------*/
class Boulder extends Decoration;

function PostBeginPlay()
{
	local float Decision;

	Super.PostBeginPlay();
	Decision = FRand();
	if (Decision<0.25) PlayAnim('Pos1');
	if (Decision<0.5) PlayAnim('Pos2');
	if (Decision<0.75) PlayAnim('Pos3');
	else PlayAnim('Pos4');	
}

defaultproperties
{
     DrawType=DT_Sprite
     CollisionRadius=+00026.000000
     CollisionHeight=+00016.000000
     bCollideActors=true
     bCollideWorld=true
     bBlockActors=true
     bBlockPlayers=true
     bProjTarget=true
}
