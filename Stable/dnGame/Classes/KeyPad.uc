class KeyPad extends InputDecoration;

/*-----------------------------------------------------------------------------
	KeyPad
	Author: Brandon Reinhart

 How to use this class:
 
 Note: PassCodes need to all be the same length.
 
 General Variables:
 
 PassCode[32]:		A list of up to 32 passcodes to be matched against.
 SuccessEvent[32]:	A list of the related 32 events to trigger. i.e.: valid code 1, trigger event 1
 FailEvent:			An event to trigger if the wrong code is entered.
 bUnlockTarget:		Some things, like doors, check to see if this is true when triggered.  If it is, they stay unlocked.
 bRelocking:		If true, the keypad will return to the locked state after being tripped.
 SaverActivate:		This cyilinder describes the area in which to turn on the screen saver anim.
 	
 Sound Variables:
 
 CodeRejectedSound:	A sound to play when the wrong code is entered.
 CodeAcceptedSound:	A sound to play when the right code is entered.
 KeyPressSound:		A sound to play when a key is pressed.

-----------------------------------------------------------------------------*/

#exec OBJ LOAD FILE=..\Sounds\a_generic.dfx
#exec OBJ LOAD FILE=..\Meshes\c_generic.dmx
#exec OBJ LOAD FILE=..\Textures\keypads.dtx
#exec OBJ LOAD FILE=..\Textures\SMK3.dtx

var() bool bUnlockTarget;
var() bool bRelocking;
var() int PassCode[32];
var() name SuccessEvents[32];
var(KeypadSounds) sound CodeRejectedSound;
var(KeypadSounds) sound CodeAcceptedSound;
var(KeypadSounds) sound KeyPressSound;
var(KeypadSounds) sound KeyPadResetSound;

var bool bLocked;
var texture KeyPadTex, LockedPadTex, UnlockedPadTex;
var texture DigitsTex[12];
var struct KeyBox
{
	var float Top, Left;
	var float Width, Height;
} KeyBoxes[12];
var int TouchedKey;
var string EnteredCode;
var float TouchedTimer;
var bool bDirty;
var bool SaverActive;

function PostBeginPlay()
{
	Super.PostBeginPlay();
//	ScreenSaver.pause = true;
	SaverActive = true;
}

function Tick(float DeltaTime)
{
	local float XL, YL;
	local font pFont;

	Super.Tick(DeltaTime);

	if (SaverActive)
		return;

	if (ScreenSaver.pause && bDirty)
	{
		ScreenCanvas.DrawBitmap( 0, 0, 0, 0, 0, 0, KeyPadTex, true, false, false );

		if (TouchedKey >= 0)
			ScreenCanvas.DrawBitmap( KeyBoxes[TouchedKey].Left, KeyBoxes[TouchedKey].Top, 0, 0, 0, 0, DigitsTex[TouchedKey], true, false, false );

		if (bLocked)
		{
			if (EnteredCode == "")
				ScreenCanvas.DrawBitmap( 0, 32, 0, 0, 0, 0, LockedPadTex, true, false, false );
			else {
				if (TouchPawn != None)
					pFont = DukeHUD(TouchPawn.MyHUD).MediumFont;
				ScreenCanvas.TextSize( EnteredCode, XL, YL, pFont );
				ScreenCanvas.DrawStringDropShadowed( pFont, (ScreenX-XL)/2, 32 + (32-YL)/2, EnteredCode, false, false, true, true, 250, 0 );
			}
		} else
			ScreenCanvas.DrawBitmap( 0, 32, 0, 0, 0, 0, UnlockedPadTex, true, false, false );

		bDirty = false;
	}

	if (TouchedTimer > 0.0)
	{
		TouchedTimer -= DeltaTime;
		if (TouchedTimer < 0.0)
		{
			bDirty = true;
			TouchedTimer = 0.0;
			TouchedKey = -1;
		}
	}
}

function ScreenTouched( Pawn Other, float X, float Y )
{
	local int i;

	if (bDisrupted || bPowerOff)
		return;

	Super.ScreenTouched( Other, X, Y );

	bDirty = true;

	TouchPawn = PlayerPawn(Other);

	// Screen was pressed to activate the panel.
	if (!ScreenSaver.pause)
	{
		SaverActive			= false;
		ScreenSaver.pause	= true;
		MultiSkins[ScreenSurface] = ScreenCanvas;
		ScreenCanvas.palette= KeyPadTex.palette;
		bDirty				= true;
		return;
	}

	// Determine the number behind the hit.
	TouchedKey = -1;
	for (i=0; i<12; i++)
	{
		if ((X > KeyBoxes[i].Left) && (X < KeyBoxes[i].Left+KeyBoxes[i].Width) &&
			(Y > KeyBoxes[i].Top) && (Y < KeyBoxes[i].Top+KeyBoxes[i].Height))
		{
			TouchedKey = i;
			TouchedTimer = 0.5;
		}
	}

	if (TouchedKey == -1)
		return;

	if (Other.IsA('DukePlayer'))
		DukePlayer(Other).Hand_PressButton();

	PlaySound( KeyPressSound, SLOT_None );

	// If they hit the star, reset our state.
	if (TouchedKey == 10)
		ResetPressed();
	else if (TouchedKey == 11)
		TryCode();
	else {
		if (Len(EnteredCode) == Len(string(PassCode[0])))
			EnteredCode = Right(EnteredCode, Len(EnteredCode)-1);
		EnteredCode = EnteredCode$TouchedKey;
	}
}

function TryCode()
{
	local Actor A;
	local int i;

	bDirty = true;

	for (i=0; i<32; i++)
	{
		if ((int(EnteredCode) != 0) && (int(EnteredCode) == PassCode[i]))
		{
			PlaySound( CodeAcceptedSound, SLOT_None );
			bLocked = false;
			if( SuccessEvents[i] != '' )
				foreach AllActors( class 'Actor', A, SuccessEvents[i] )
				{
					if (A.IsA('DoorMover') && DoorMover(A).bLocked)
					{
						DoorMover(A).bLocked = false;
						DoorMover(A).PlaySound( DoorMover(A).OpeningSound, SLOT_None );
					} else
						A.Trigger( Self, TouchPawn );
				}
		}
	}

	if (bLocked)
	{
		PlaySound( CodeRejectedSound, SLOT_None );
		if( FailEvent != '' )
			foreach AllActors( class 'Actor', A, FailEvent )
				A.Trigger( Self, TouchPawn );
	}

	if (bRelocking)
		bLocked = true;
}

function ResetPressed()
{
	bDirty = true;

	PlaySound( KeyPadResetSound, SLOT_None );
	EnteredCode = "";
	TouchPawn = None;
}

function CloseDecoration( Actor Other )
{
	bDirty = true;

	ScreenSaver.pause = false;
	MultiSkins[ScreenSurface] = ScreenSaver;
	EnteredCode = "";
	TouchPawn = None;
	TouchedKey = -1;
	SaverActive = true;
}

defaultproperties
{
	ScreenX=128
	ScreenY=256

	KeyPadTex=texture'keypads.bkeypmain1BC'
	LockedPadTex=texture'keypads.bkeyplockedBC'
	UnlockedPadTex=texture'keypads.bkeypunlockedBC'
	DigitsTex(0)=texture'keypads.bkeypnum0BC'
	DigitsTex(1)=texture'keypads.bkeypnum1BC'
	DigitsTex(2)=texture'keypads.bkeypnum2BC'
	DigitsTex(3)=texture'keypads.bkeypnum3BC'
	DigitsTex(4)=texture'keypads.bkeypnum4BC'
	DigitsTex(5)=texture'keypads.bkeypnum5BC'
	DigitsTex(6)=texture'keypads.bkeypnum6BC'
	DigitsTex(7)=texture'keypads.bkeypnum7BC'
	DigitsTex(8)=texture'keypads.bkeypnum8BC'
	DigitsTex(9)=texture'keypads.bkeypnum9BC'
	DigitsTex(10)=texture'keypads.bkeypnumstarBC'
	DigitsTex(11)=texture'keypads.bkeypnumpondBC'
	KeyBoxes(0)=(Top=186,Left=48,Width=32,Height=32)
	KeyBoxes(1)=(Top=72,Left=10,Width=32,Height=32)
	KeyBoxes(2)=(Top=72,Left=48,Width=32,Height=32)
	KeyBoxes(3)=(Top=72,Left=86,Width=32,Height=32)
	KeyBoxes(4)=(Top=110,Left=10,Width=32,Height=32)
	KeyBoxes(5)=(Top=110,Left=48,Width=32,Height=32)
	KeyBoxes(6)=(Top=110,Left=86,Width=32,Height=32)
	KeyBoxes(7)=(Top=148,Left=10,Width=32,Height=32)
	KeyBoxes(8)=(Top=148,Left=48,Width=32,Height=32)
	KeyBoxes(9)=(Top=148,Left=86,Width=32,Height=32)
	KeyBoxes(10)=(Top=186,Left=10,Width=32,Height=32)
	KeyBoxes(11)=(Top=186,Left=86,Width=32,Height=32)
	bLocked=true
	PassCode(0)=1234
	bUnlockTarget=true
	bRelocking=false

	Mesh=mesh'c_generic.keypad3'
	ScreenSurface=1
	TouchedKey=-1

	CollisionHeight=8
	CollisionRadius=5
	bMeshLowerByCollision=false
	//bBlockPlayers=false
	//bCollideActors=false
	bProjTarget=true

	CodeRejectedSound=sound'a_generic.keypad.KeypdNoV01'
	CodeAcceptedSound=sound'a_generic.keypad.KeypdOKV01'
	KeyPressSound=sound'a_generic.keypad.KeypdType59'
	KeyPadResetSound=sound'a_generic.keypad.KeypdReset05'

	HealthPrefab=HEALTH_NeverBreak
	ItemName="Keypad"
	LodMode=LOD_Disabled

	CanvasTexture=texturecanvas'keypads.keypad_canv'
	ExamineFOV=50.0
}