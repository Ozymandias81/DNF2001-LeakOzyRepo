class TrophyDude extends Decoration;

var bool bFinal;

function PostBeginPlay()
{
	SetTimer(38.0, True);
}

function Timer()
{
	SetTimer(0.0, False);
	PlayAnim('Trophy5', 0.3);
}

function AnimEnd()
{
	if (!bFinal)
	{
		PlayAnim('Trophy4', 0.3);
		bFinal = True;
	}
}

defaultproperties
{
	bStatic=False
	DrawType=DT_Mesh
	Mesh=TrophyMale1
}

