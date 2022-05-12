//=============================================================================
// CHEOLHUD
//=============================================================================
class CHEOLHud extends ChallengeHUD;

var localized string ESCMessage;
var float ESCFadeTime;

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
	if (Level.TimeSeconds > 40)
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
	ESCMessage="Press ESC to continue..."
}