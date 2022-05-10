//=============================================================================
// PlayerCanSeeMe (NJS)
// Triggers whenever the player can see me
//=============================================================================
class PlayerCanSeeMe extends InfoActor;

var () bool Enabled;
var () bool OneShot;
var () name PlayerBecameVisible;
var () name PlayerBecameNotVisible;
var    bool PlayerSawMe;

function PostBeginPlay()
{
	Super.PostBeginPlay();
	if ( Enabled )
		Enable('Tick');
}

function Tick(float DeltaSeconds)
{
	local bool PlayerSeesMe;
	if(!Enabled) return;

	PlayerSeesMe=PlayerCanSeeMe();
	if(PlayerSeesMe!=PlayerSawMe)
	{
		PlayerSawMe=PlayerSeesMe;
		if(PlayerSawMe) GlobalTrigger(PlayerBecameVisible);
		else			GlobalTrigger(PlayerBecameNotVisible);

		if(OneShot) { Enabled=False; Disable('Tick'); }
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	Enabled=!Enabled;
	if(!Enabled) Disable('Tick');
	else		 Enable('Tick');
}

defaultProperties
{
	Enabled=True
	OneShot=False
}