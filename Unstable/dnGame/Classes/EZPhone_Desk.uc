/*-----------------------------------------------------------------------------
	EZPhone_Desk
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class EZPhone_Desk extends EZPhone;

var bool bOpen;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	HitTex = MeshGetTexture(1);
	PlayAnim('closed');
}

function AnimEnd()
{
	if (AnimSequence == 'opening')
	{
		CloseTime = 4.0;
		LoopAnim('open');
	} else if (AnimSequence == 'closing')
		LoopAnim('closed');
}

event Used(Actor Other, Pawn EventInstigator)
{
	if (!bOpen)
	{
		PlayAnim('opening');
		bOpen = true;
		bExaminable = true;
	} else {
		CloseTime = 0.0;
		Super.Used(Other, EventInstigator);
	}
}

function CloseDecoration( Actor Other )
{
	Super.CloseDecoration( Other );

	bExaminable = false;
	bOpen = false;

	PlayAnim('closing');
}

defaultproperties
{
	Mesh=mesh'c_generic.ezphone_desk'
	bBlockPlayers=true
	AnimSequence=closed
	bExaminable=false
	ScreenSurface=1
	InputSurface=1
	VideoSurface=2
	CollisionRadius=16
	CollisionHeight=16
	VidScreenOnAnim=open_activated
	VidScreenOffAnim=open
	ExamineFOV=55
	bShield=false
}
