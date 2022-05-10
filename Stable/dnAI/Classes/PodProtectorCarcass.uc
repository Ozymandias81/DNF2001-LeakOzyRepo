class PodProtectorCarcass extends CreaturePawnCarcass;

function Timer(optional int TimerNum)
{
}

defaultproperties
{
	CollisionHeight=1.0
	CollisionRadius=16.0
	bBlockPlayers=false
	Mass=100.000000
	Mesh=DukeMesh'c_characters.Pod_Protector'
	Physics=PHYS_Falling
	ItemName="Pod Protector Corpse"
	bRandomName=false
	bCanHaveCash=false
	bSearchable=false
	bNotTargetable=true
	MasterReplacement=class'SnatcherMasterChunk'
	BloodPoolName="dnGame.dnAlienBloodPool"
	BloodHitDecalName="dnGame.dnAlienBloodHit"
	HitPackageClass=class'HitPackage_AlienFlesh'
	BigChunksClass=class'dnParticles.dnBloodFX_BloodChunksSmall'
	BloodHazeClass=class'dnParticles.dnBloodFX_BloodHazeSmall'
	SmallChunksClass=class'dnParticles.dnBloodFX_BloodChunksSmall'
	SmallBloodHazeClass=class'dnParticles.dnBloodFX_BloodHazeSmall'
}
