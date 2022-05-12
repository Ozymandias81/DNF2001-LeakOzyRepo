//=============================================================================
// BloodBurst.
//=============================================================================
class UT_BloodBurst extends ut_Blood2;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	PlayAnim  ( 'Burst', 1.0 );

	if ( Level.NetMode != NM_DedicatedServer )
		SpawnCloud();
	bRandomFrame = !Level.bDropDetail;
}

simulated function SpawnCloud()
{
	local Actor A;

	if ( Level.bDropDetail || !Level.bHighDetailMode )
		return;
	if ( bGreenBlood )
		A= spawn(class'UT_GreenBloodPuff');
	else
		A = spawn(class'UT_BloodPuff');
	A.RemoteRole = ROLE_None;
}

defaultproperties
{
	 AnimSequence=Burst
     Texture=Texture'Botpack.Blood.BD6'
     DrawScale=0.150000
     AmbientGlow=80
     bOwnerNoSee=True
}
