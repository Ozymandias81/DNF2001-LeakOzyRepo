class CriticalEventMessage expands LocalMessage;

static function float GetOffset(int Switch, float YL, float ClipY )
{
	return (Default.YPos/768.0) * ClipY;
}

defaultproperties
{
	bBeep=true
	Lifetime=3

	DrawColor=(R=0,G=128,B=255)
	bCenter=true
	FontSize=1
	YPos=196
}
