class UTBloodPool2 expands UTBloodPool;

simulated function Timer()
{
	// Check for nearby players, if none then destroy self

	if ( !bAttached )
	{
		Destroy();
		return;
	}

	if ( !bStartedLife )
	{
		RemoteRole = ROLE_None;
		bStartedLife = true;
	}
}

defaultproperties
{
	DrawScale=+0.68
	splats(0)=texture'Botpack.BloodSplat7'
	splats(1)=texture'Botpack.BloodSplat5'
	splats(2)=texture'Botpack.BloodSplat1'
	splats(3)=texture'Botpack.BloodSplat3'
	splats(4)=texture'Botpack.BloodSplat4'
}