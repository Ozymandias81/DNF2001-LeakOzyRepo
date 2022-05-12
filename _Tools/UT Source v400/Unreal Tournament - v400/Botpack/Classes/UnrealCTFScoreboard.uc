// UnrealCTFScoreBoard
//=============================================================================
class UnrealCTFScoreBoard extends TeamScoreBoard;

#exec TEXTURE IMPORT NAME=BlueFlag FILE=..\BOTPACK\TEXTURES\HUD\i_bscore.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=GreenFlag FILE=..\BOTPACK\TEXTURES\HUD\i_gscore.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=RedFlag FILE=..\BOTPACK\TEXTURES\HUD\i_rscore.PCX GROUP="Icons" MIPS=OFF FLAGS=2
#exec TEXTURE IMPORT NAME=YellowFlag FILE=..\BOTPACK\TEXTURES\HUD\i_yscore.PCX GROUP="Icons" MIPS=OFF FLAGS=2

#exec TEXTURE IMPORT NAME=I_RedBox FILE=..\BOTPACK\TEXTURES\HUD\i_redbox.PCX GROUP="Icons" MIPS=OFF
#exec TEXTURE IMPORT NAME=I_BlueBox FILE=..\BOTPACK\TEXTURES\HUD\i_bluebox.PCX GROUP="Icons" MIPS=OFF

var() texture FlagIcon[4];

function DrawNameAndPing(Canvas Canvas, PlayerReplicationInfo PRI, float XOffset, float YOffset)
{
	local float XL, YL;
	local font CanvasFont;

	Super.DrawNameAndPing(Canvas, PRI, XOffset, YOffset);
	if ( PRI.HasFlag == None )
		return;

	// Flag icon
	Canvas.DrawColor = WhiteColor;
	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.SetPos(XOffset - 32, YOffset);
	Canvas.DrawIcon(FlagIcon[CTFFlag(PRI.HasFlag).Team], 1.0);
}

defaultproperties
{
	 FlagIcon(0)=texture'RedFlag'
	 FlagIcon(1)=texture'BlueFlag'
	 FlagIcon(2)=texture'GreenFlag'
	 FlagIcon(3)=texture'YellowFlag'
	 FragGoal="Capture Limit:"
}
