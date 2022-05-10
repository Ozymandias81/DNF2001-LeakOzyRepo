//=============================================================================
//	TriggerVideoPoker2
//	Author: John Pollard
//=============================================================================
class TriggerVideoPoker2 expands Triggers;

#exec OBJ LOAD FILE=..\Textures\canvasfx.dtx

var VideoPoker		VideoPokerMachine;	// The video poker machine that we will send messages to
var DukePlayer		Duke;				// The Duke standing in this trigger
var	byte			bUse;				// Dukes last use state
var bool			bHandUp;
var bool			bHaveFocus;

var texture			OldScreenTexture;
var int				ScreenSurfaceIndex;
var bool			bWaitingForCoin;

var(TriggerVideoPoker)	name	ScreenTag;
var(TriggerVideoPoker)	name	CoinTag;
var(TriggerVideoPoker)	name	FocusTag;

struct KeyBox
{
	var float Top, Left;
	var float Width, Height;
};

var KeyBox			Keys[7];			// The 7 buttons they can press on the screen + coin button

var int				VideoPokerKey;
var bool			bUseDownOnce;

//=============================================================================
//	PostBeginPlay
//=============================================================================
function PostBeginPlay()
{
	local VideoPoker		v;
	local int				i;

	// Find the video poker machine this trigger will control
	foreach allactors(class'VideoPoker', v)
		VideoPokerMachine = v;

	if (VideoPokerMachine != None)
		VideoPokerKey = VideoPokerMachine.GetKey();

	// Deal/Draw
	Keys[0].Left = 97;
	Keys[0].Width = 183-97;
	Keys[0].Top = 105;
	Keys[0].Height = 130-105;

	// Cards
	for (i=1; i< 6; i++) { Keys[i].Top = 177; Keys[i].Height = 241-177; }

	Keys[1].Left = 7;
	Keys[1].Width = 56-7;
	Keys[2].Left = 57;
	Keys[2].Width = 105-57;
	Keys[3].Left = 107;
	Keys[3].Width = 155-107;
	Keys[4].Left = 157;
	Keys[4].Width = 206-157;
	Keys[5].Left = 208;
	Keys[5].Width = 255-208;

	// Coin slot
	Keys[6].Left = 211;
	Keys[6].Width = 255 - Keys[6].Left;
	Keys[6].Top = 10;
	Keys[6].Height = 56 - Keys[6].Top;

	Disable('Tick');
}

//=============================================================================
//	IsPressingKey
//	Simply checks to see if x/y pair are within the bounds of a KeyBox
//	(the check is inclusive of KeyBox)
//=============================================================================
function bool IsPressingKey(int x, int y, KeyBox Box)
{
	if (x < Box.Left)
		return false;
	if (x > (Box.Left+Box.Width))
		return false;
	if (y < Box.Top)
		return false;
	if (y > (Box.Top+Box.Height))
		return false;

	return true;
}

//=============================================================================
//	MakeSureWeaponIsDown
//=============================================================================
function MakeSureWeaponIsDown()
{
	Duke.Hand_BringUp(true);
}

//=============================================================================
//	MakeSureWeaponIsUp
//=============================================================================
function MakeSureWeaponIsUp()
{
	Duke.Hand_WeaponUp();
}

//=============================================================================
//	MakeSureHandIsUp
//	If hand is currently not up, it brings it up
//=============================================================================
function MakeSureHandIsUp()
{
	if (!bHandUp)
	{
		Duke.Hand_BringUp();
		bHandUp = true;
	}
}

//=============================================================================
//	MakeSureHandIsDown
//	If hand is currently not down, it puts it down
//=============================================================================
function MakeSureHandIsDown()
{
	if (bHandUp)
	{
		Duke.Hand_PutDown(true);
		bHandUp = false;
	}
}

//=============================================================================
//	PressKey
//=============================================================================
function PressKey(int i)
{
	Duke.Hand_PressButton();

	switch(i)
	{
		case 0:
			VideoPokerMachine.DrawPressed();
			break;
		case 1:
			VideoPokerMachine.ToggleCard1Pressed();
			break;
		case 2:
			VideoPokerMachine.ToggleCard2Pressed();
			break;
		case 3:
			VideoPokerMachine.ToggleCard3Pressed();
			break;
		case 4:
			VideoPokerMachine.ToggleCard4Pressed();
			break;
		case 5:
			VideoPokerMachine.ToggleCard5Pressed();
			break;
	}
}

//=============================================================================
//	SurfaceGivesFocus
//=============================================================================
function bool SurfaceGivesFocus(name SurfName)
{
	if (SurfName == '')
		return false;

	if (SurfName == ScreenTag)
		return true;

	if (SurfName == CoinTag)
		return true;

	if (SurfName == FocusTag)
		return true;

	return false;
}

//=============================================================================
//	GetFocus
//=============================================================================
function GetFocus()
{
	local int Index;

	if (bHaveFocus)
		return;			// Already got focus...
	
	if (Duke.bUse == 0)	// Don't get focus until they hit "use" key
		return;

	// Find the screen used for this video poker machine, and swap it out with the real canvas texture
	ScreenSurfaceIndex = FindSurfaceByName(ScreenTag);

	if (ScreenSurfaceIndex != -1)
	{
		// Save old texture
		OldScreenTexture = GetSurfaceTexture(ScreenSurfaceIndex);		
		// Set new texture
		SetSurfaceTexture(ScreenSurfaceIndex, VideoPokerMachine.TableCanvas);
	}
	
	// Activate the machine
	VideoPokerMachine.Activate(VideoPokerKey);

	// Put the weapon down
	MakeSureWeaponIsDown();

	bHaveFocus = true;
}

//=============================================================================
//	LoseFocus
//=============================================================================
function LoseFocus()
{
	if (!bHaveFocus)
		return;			// Already lost focus
	
	if (ScreenSurfaceIndex != -1)
	{
		// Restore to old texture
		SetSurfaceTexture(ScreenSurfaceIndex, OldScreenTexture);
		ScreenSurfaceIndex = -1;
	}

	// DeActivate the machine
	VideoPokerMachine.DeActivate(VideoPokerKey);

	// Put the hand down
	MakeSureHandIsDown();
	// Make sure the weapon comes back up
	MakeSureWeaponIsUp();

	bHaveFocus = false;
}

//=============================================================================
//	GetUseState
//=============================================================================
function GetUseState()
{
	bUseDownOnce = false;
	
	if (Duke.bUse != 0 && bUse == 0)
	{
		bUseDownOnce = true;
		bUse = 1;
	}
	else if (Duke.bUse == 0)
		bUse = 0;
}

//=============================================================================
//	Tick
//=============================================================================
function Tick(float Delta)
{
	local vector	StartTrace, EndTrace, HitLocation, HitNormal;
	local vector	DrawOffset;
	local texture	HitTexture;
	local int		x, y, i;
	local int		SurfaceIndex;
	local name		SurfaceName;

	local float	u, v;

	Super.Tick(Delta);

	if (Duke == None)
		return;

	// See if Duke is pressing use key
	GetUseState();

	//
	//	Check for focus
	//

	DrawOffset = Duke.BaseEyeHeight * vect(0,0,1);
	StartTrace = Duke.Location + DrawOffset;
	EndTrace   = StartTrace + (vector(Duke.ViewRotation)*50.0);

	// Find the texture we are looking at
	HitTexture = TraceTexture(EndTrace, StartTrace, None,,,,,,SurfaceIndex,true,x,y);

	SurfaceName = FindNameForSurface(SurfaceIndex);

	if (SurfaceGivesFocus(SurfaceName))
		GetFocus();
	else
		LoseFocus();

	if (!bHaveFocus)
		return;			// No focus, so don't do anything else

	if ((SurfaceName == CoinTag && !IsPressingKey(x, y, Keys[6])) ||  SurfaceName != CoinTag)
		if (!Duke.DukesHand.IsBusy())
			MakeSureHandIsUp();		// Hand is always up when not looking at coin surface

	//if (bUseDownOnce)
	//	BroadcastMessage("Name:"@HitTexture.Name@"X:"@x@", Y:"@y);

	if (bWaitingForCoin && !Duke.DukesHand.IsBusy())
	{
		if (VideoPokerMachine.Bet1Pressed(Duke))
			Duke.Hand_QuickAnim('DropCoin_Start','DropCoin',0.6);

		bWaitingForCoin = false;
	}
	else if (bUseDownOnce && !bWaitingForCoin)
	{
		// See if any keys were pressed on the main canvas
		if (SurfaceName == ScreenTag)
		{
			for (i=0; i<6; i++)
			{
				if (IsPressingKey(x, y, Keys[i]))
				{
					PressKey(i);
					break;
				}
			}
		}
		else if (SurfaceName == CoinTag)
		{
			if (IsPressingKey(x, y, Keys[6]))		// Coin machine
			{
				if (VideoPokerMachine.CanBetAmount(1, Duke, true))
				{
					MakeSureHandIsDown();
					bWaitingForCoin = true;
				}
			}
		}
	}
}

//=============================================================================
//	Touch
//=============================================================================
function Touch( actor Other )
{
	Enable('Tick');

	if (Other.IsA('DukePlayer'))
	{
		if (Duke == None)
		{
			Duke = DukePlayer(Other);
			bUse = 1;
			bHandUp = false;
			bHaveFocus = false;
			bWaitingForCoin = false;
		}
	}

	Super.Touch(Other);
}

//=============================================================================
//	Touch
//=============================================================================
function Untouch( actor Other )
{
	if (Other.IsA('DukePlayer'))
	{
		if (Duke != None)
		{
			LoseFocus();
			Duke = None;
		}
	}

	Super.UnTouch(Other);
	
	Disable('Tick');
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	Texture=Texture'Engine.S_TrigVideoPoker'
}
