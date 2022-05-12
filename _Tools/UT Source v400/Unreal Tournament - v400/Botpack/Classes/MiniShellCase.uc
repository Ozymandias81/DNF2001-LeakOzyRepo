//=============================================================================
// MiniShellCase.
//=============================================================================
class MiniShellCase extends UT_ShellCase;
	
simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	Super.HitWall(HitNormal, Wall);
	GotoState('Ending');
}

State Ending
{
Begin:
	Sleep(0.7);
	Destroy();
}

defaultproperties
{
	 DrawScale=+1.2
	 bOnlyOwnerSee=True
     LightType=LT_None
	 RemoteRole=ROLE_None
}
