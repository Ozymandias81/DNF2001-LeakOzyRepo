//
// Represents a schematic for a client localized message.
//
class LocalMessage expands Info;

var bool	bComplexString;									// Indicates a multicolor string message class.
var bool	bIsConsoleMessage;								// If true, put a GetString on the console.
var bool	bBeep;											// If true, beep!
var bool	bOffsetYPos;									// If the YPos indicated isn't where the message appears.
var int		Lifetime;										// # of seconds to stay in HUD message queue.

var class<LocalMessage> ChildMessage;						// In some cases, we need to refer to a child message.

// Canvas Variables
var bool	bFromBottom;									// Subtract YPos.
var color	DrawColor;										// Color to display message with.
var float	XPos, YPos;										// Coordinates to print message at.
var bool	bCenter;										// Whether or not to center the message.

var int FontSize;						// Relative font size.
										// 0: Huge
										// 1: Big
										// 2: Small ...

static function RenderComplexMessage( 
	Canvas							Canvas, 
	out float						XL,
	out float						YL,
	optional String					MessageString,
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject
	);

static function string GetString(
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
	)
{
	return "";
}

static function string AssembleString(
	HUD MyHUD,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional String MessageString
	)
{
	return "";
}

static function ClientReceive
	( 
	PlayerPawn						P,
	optional int					Switch,
	optional PlayerReplicationInfo	RelatedPRI_1, 
	optional PlayerReplicationInfo	RelatedPRI_2,
	optional Object					OptionalObject,
	optional class<Actor>			OptionalClass
	)
{
	if ( P.MyHUD != None )
		P.MyHUD.LocalizedMessage( Default.Class, Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject,, OptionalClass );

	if ( Default.bBeep && P.bMessageBeep )
		P.PlayBeepSound();

	if ( Default.bIsConsoleMessage )
	{
		if ((P.Player != None) && (P.Player.Console != None))
			P.Player.Console.AddString(static.GetString( Switch, RelatedPRI_1, RelatedPRI_2, OptionalObject, OptionalClass ));
	}
}

static function color GetColor(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1, 
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.DrawColor;
}

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return Default.YPos;
}

static function int GetFontSize(int Switch)
{
	return Default.FontSize;
}

defaultproperties
{
	Lifetime=3
	DrawColor=(R=255,G=255,B=255)
}