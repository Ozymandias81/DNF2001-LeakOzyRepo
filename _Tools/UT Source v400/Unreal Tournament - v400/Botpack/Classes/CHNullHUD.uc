//=============================================================================
// CHNullHUD
//=============================================================================
class CHNullHud extends ChallengeHUD;

var localized string ESCMessage;
var float ESCFadeTime;

function PreRender( Canvas C )
{
	if (Level.TimeSeconds < 1.5)
		C.DrawTile( texture'BlackTexture', C.ClipX, C.ClipY, 0, 0, 256, 256 );

	Super(HUD).PreRender(C);
}

function PostRender( Canvas C )
{
	local float XL, YL;

	HUDSetup(C);

	if ( PlayerPawn(Owner).ProgressTimeOut > Level.TimeSeconds )
		DisplayProgressMessage(C);

	C.DrawColor = WhiteColor * ESCFadeTime;
	C.Style = ERenderStyle.STY_Translucent;
	C.bCenter = True;
	C.Font = MyFonts.GetBigFont( C.ClipX );
	C.StrLen(ESCMessage, XL, YL);
	C.SetPos(0, C.ClipY - YL);
	C.DrawText(ESCMessage);
	C.bCenter = False;

	Super(HUD).PostRender(C);
}

function Tick(float Delta)
{
	if (Level.TimeSeconds > 82)
	{
		if (ESCFadeTime < 1.0)
			ESCFadeTime += Delta/3;
		if (ESCFadeTime > 1.0)
			ESCFadeTime = 1.0;
	}
}

simulated function bool DisplayMessages( canvas C )
{
	if ( PlayerPawn(Owner).Player.Console.bTyping )
		DrawTypingPrompt(C, PlayerPawn(Owner).Player.Console);

	return true;
}

defaultproperties
{
	ESCMessage="Press ESC to begin."
}