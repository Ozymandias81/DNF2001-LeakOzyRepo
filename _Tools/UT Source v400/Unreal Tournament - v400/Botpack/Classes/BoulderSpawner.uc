//=============================================================================
// BoulderSpawner.
//=============================================================================
class BoulderSpawner extends Effects;

var() float TriggerDelay, RepeatDelay;
var() int BouldersTothrowAfterDeactivated;
var() int BoulderSpeed;
var int BoulderCount;

function Trigger( actor Other, pawn EventInstigator )
{
	local CatapultRock a;

	Instigator = EventInstigator;
	a = Spawn(class'CatapultRock',,, Location+Vector(Rotation)*20);
	a.Speed = BoulderSpeed;
}

defaultproperties
{
     bOnlyTriggerable=True
     bHidden=True
     bDirectional=True
     DrawType=DT_Sprite
}
