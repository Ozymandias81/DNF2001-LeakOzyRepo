/*-----------------------------------------------------------------------------
	AccessPad
	Author: Brandon Reinhart

 How to use this class:
 
 Note: PassCodes need to all be the same length.
 
 General Variables:
 
 PlayerCanUse:		Set to true if the player is allowed to succeed when using the pad.
 SuccessEvent:		An event to trigger on success.
 FailEvent:			An event to trigger on failure.
 	
 Sound Variables:
 
 RejectedSound:		A sound to play when the user is rejected.
 AcceptedSound:		A sound to play when the user is accepted.

-----------------------------------------------------------------------------*/
class AccessPad extends InputDecoration;

#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\Textures\m_generic.dtx

var(PuzzleSounds) sound			RejectedSound;
var(PuzzleSounds) sound			AcceptedSound;
var() bool						PlayerCanUse;

var SmackerTexture				HandSaver;
var SmackerTexture				AccessSmack;
var int							EndFrame;

var bool						bAccessPlaying;

var Pawn						AccessPawn;

function PostBeginPlay()
{
	AccessSmack.CurrentFrame = 0;
	AccessSmack.pause = true;

	Super.PostBeginPlay();

	if (bPowerOff)
		return;

	MultiSkins[ScreenSurface] = HandSaver;
	ScreenSaver = HandSaver;
	HandSaver.pause = false;
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	if (bDisrupted || bPowerOff)
		return;

	if (bAccessPlaying)
		return;

	bAccessPlaying = true;
	MultiSkins[ScreenSurface] = AccessSmack;
	AccessSmack.CurrentFrame = 0;
	TouchPawn = PlayerPawn(Other);
	AccessPawn = Other;
	EndFrame = 1000;
	HandSaver.pause = true;
}

function Tick(float Delta)
{
	local actor A;

	Super.Tick(Delta);

	if ( !bAccessPlaying )
		return;

	AccessSmack.pause = false;
	AccessSmack.ForceTick( Delta );
	if (AccessSmack.CurrentFrame >= EndFrame)
	{
		HandSaver.pause = false;
		AccessSmack.pause = true;
		AccessSmack.CurrentFrame = 0;
		MultiSkins[ScreenSurface] = HandSaver;
		bAccessPlaying = false;
		return;
	}

	if ((AccessSmack.CurrentFrame >= 51) && (EndFrame == 1000))
	{
		if (AccessPawn.IsA('PlayerPawn') && !PlayerCanUse)
		{
			if( FailEvent != '' )
				foreach AllActors( class 'Actor', A, FailEvent )
					A.Trigger( Self, AccessPawn );
			PlaySound( RejectedSound, SLOT_None );
			AccessSmack.CurrentFrame = 75;
			EndFrame = 94;
		} else {
			if( SuccessEvent != '' )
				foreach AllActors( class 'Actor', A, SuccessEvent )
					A.Trigger( Self, AccessPawn );
			PlaySound( AcceptedSound, SLOT_None );
			EndFrame = 74;
		}
	}
}

function Trigger( actor Other, pawn EventInstigator )
{
	if (bPowerOff)
	{
		bPowerOff = false;
		ScreenSaver.pause = false;
		MultiSkins[ScreenSurface] = HandSaver;
	} else {
		if ( (EventInstigator == None) || (!EventInstigator.IsA('PlayerPawn')) )
			ScreenTouched( EventInstigator, 0, 0 );
	}
}

function SaverActivated()
{
	HandSaver.pause = false;
}

function SaverDeactivated()
{
	HandSaver.pause = true;
}

function CloseDecoration( Actor Other )
{
	AccessPawn = None;
	TouchPawn = None;
}

defaultproperties
{
	Mesh=mesh'c_generic.puzzlescreen'
	ScreenSurface=1

	CollisionHeight=12
	CollisionRadius=8
	bMeshLowerByCollision=true
	bProjTarget=true
	bExaminable=false

	RejectedSound=sound'a_generic.keypad.KeypdNoV01'
	AcceptedSound=sound'a_generic.keypad.KeypdOKV01'

	HealthPrefab=HEALTH_NeverBreak
	ItemName="Access Pad"
	LodMode=LOD_Disabled

	CanvasTexture=texturecanvas'powerpuzzle1.ppuzzle_screen2'
	HandSaver=smackertexture'smk6.s_hscansaver'
	AccessSmack=smackertexture'smk6.s_hscan1'
	PowerOffSkin=texture'm_generic.puzzlescrn2BC'
}