//=============================================================================
// HUD: Superclass of the heads-up display.
//=============================================================================
class HUD extends InfoActor
	abstract
	native
	config(user);

#exec TEXTURE IMPORT NAME=BlackTexture FILE=TEXTURES\Black.PCX
#exec TEXTURE IMPORT NAME=WhiteTexture FILE=TEXTURES\White.PCX

//=============================================================================
// Variables.

var globalconfig int HudMode;	
var globalconfig int Crosshair;
var() string HUDConfigWindowType;
var Mutator HUDMutator;
var PlayerPawn PlayerOwner; // always the actual owner
var unbound float HUDScaleX, HUDScaleY;

// Duke HUD:
var int currentInventoryCategory;				// Index of the inventory category currently selected. -1 means none
var int currentInventoryItem;					// Index of the sub item in the given category
var unbound float InventoryGoAwayDelay;			// Time before inventory goes away (or 0 if not)
var unbound int visibleCategories;

// Objectives
var bool bDrawObjectives;

// Core colors.
var color WhiteColor, RedColor, LightGreenColor, DarkGreenColor, GreenColor, CyanColor, UnitColor, BlueColor,
	 GoldColor, PurpleColor, TurqColor, GrayColor, FaceColor, LightBlueColor, DarkBlueColor, BlackColor;
var unbound color OrangeColor;

struct HUDLocalizedMessage
{
	var Class<LocalMessage> Message;
	var int Switch;
	var PlayerReplicationInfo RelatedPRI;
	var Object OptionalObject;
	var float EndOfLife;
	var float LifeTime;
	var bool bDrawing;
	var int numLines;
	var string StringMessage;
	var color DrawColor;
	var font StringFont;
	var float XL, YL;
	var float YPos;
};

function CloseInventory()
{
	InventoryGoAwayDelay = 0;
	currentInventoryCategory =- 1;
	PlayerOwner.Player.console.MouseCapture = false;
	PlayerOwner.Player.console.MouseLineMode = false;
	PlayerOwner.InputHookActor = none;
}

function ClearMessage(out HUDLocalizedMessage M)
{
	M.Message = None;
	M.Switch = 0;
	M.RelatedPRI = None;
	M.OptionalObject = None;
	M.EndOfLife = 0;
	M.StringMessage = "";
	M.DrawColor = WhiteColor;
	M.XL = 0;
	M.bDrawing = false;
}

function CopyMessage(out HUDLocalizedMessage M1, HUDLocalizedMessage M2)
{
	M1.Message = M2.Message;
	M1.Switch = M2.Switch;
	M1.RelatedPRI = M2.RelatedPRI;
	M1.OptionalObject = M2.OptionalObject;
	M1.EndOfLife = M2.EndOfLife;
	M1.StringMessage = M2.StringMessage;
	M1.DrawColor = M2.DrawColor;
	M1.XL = M2.XL;
	M1.YL = M2.YL;
	M1.YPos = M2.YPos;
	M1.bDrawing = M2.bDrawing;
	M1.LifeTime = M2.LifeTime;
	M1.numLines = M2.numLines;
}

//=============================================================================
// Status drawing.

simulated event PreRender( canvas Canvas );
simulated event PostRender( canvas Canvas );
simulated event RenderOverlays( canvas Canvas )
{
	local Pawn P;

	P = Pawn(Owner);
	if ( P != None ) 
	{
		if ( P.CarriedDecoration != None )
		{
			if ( P.CarriedDecoration.bDeleteMe ) 
			{ 
				P.DropDecoration(,true); 
				P.CarriedDecoration = None;
			}
			else
				P.CarriedDecoration.RenderOverlays(Canvas);
		}
	}
}

simulated function InputNumber( byte F );
simulated function DrawCrossHair( canvas Canvas, int StartX, int StartY);
simulated function AddPickupEvent( class<Inventory> InvClass );

//=============================================================================
// Messaging.

simulated function Message( PlayerReplicationInfo PRI, coerce string Msg, name N );
simulated function LocalizedMessage
	(
	class<LocalMessage> Message,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2, 
	optional Object OptionalObject, 
	optional string CriticalString,
	optional class<Actor> OptionalClass
	);

simulated function PlayReceivedMessage( string S, string PName, ZoneInfo PZone )
{
	PlayerPawn(Owner).ClientMessage(S);
	if (PlayerPawn(Owner).bMessageBeep)
		PlayerPawn(Owner).PlayBeepSound();
}

// DisplayMessages is called by the Console in PostRender.
// It offers the HUD a chance to deal with messages instead of the
// Console.  Returns true if messages were dealt with.
simulated function bool DisplayMessages(canvas Canvas)
{
	return false;
}

simulated function HUDAddEnergy(int Energy);
simulated function FlashCash();
simulated function OwnerDied();

simulated exec function ShowObjectives();
simulated function HideObjectives();

simulated function bool MouseClick();

simulated function color GetTextColor()
{
	return WhiteColor;
}

defaultproperties
{
    bHidden=True
    RemoteRole=ROLE_None
	WhiteColor=(R=255,G=255,B=255)
	RedColor=(R=255,G=0,B=0)
	LightBlueColor=(R=0,G=0,B=128)
	DarkBlueColor=(R=0,G=0,B=64)
	BlueColor=(R=0,G=0,B=255)
	LightGreenColor=(R=0,G=128,B=0)
	DarkGreenColor=(R=32,G=64,B=32)
	GreenColor=(R=0,G=255,B=0)
	GoldColor=(R=255,G=255,B=0)
	TurqColor=(R=0,G=128,B=255)
	GrayColor=(R=200,G=200,B=200)
	FaceColor=(R=50,G=50,B=50)
	CyanColor=(R=0,G=255,B=255)
	PurpleColor=(R=255,G=0,B=255)
	UnitColor=(R=1,G=1,B=1)
	BlackColor=(R=0,G=0,B=0)
	OrangeColor=(R=255,G=144,B=0)
}
