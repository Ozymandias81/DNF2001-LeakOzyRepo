class CriticalEventPlus expands LocalMessagePlus;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY;
}

defaultproperties
{
	bBeep=True
	bFadeMessage=True
	bIsSpecial=True
	bIsUnique=True
	Lifetime=3

	DrawColor=(R=0,G=128,B=255)
	bCenter=True
	FontSize=1
	YPos=196
}
