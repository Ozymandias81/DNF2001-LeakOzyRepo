/*-----------------------------------------------------------------------------
	ShotgunShell
	Author: Nick Shaffner
-----------------------------------------------------------------------------*/
class ShotgunShell expands Projectile;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx
#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var bool bHasBounced;

simulated function PlayLanded()
{
	if ( (Level.NetMode != NM_DedicatedServer) && !Region.Zone.bWaterZone )
		PlaySound(Sound'dnsWeapn.shotgun.ShotgunShDrop03');
}

simulated function HitWall( vector HitNormal, actor Wall )
{
	local vector RealHitNormal;

	if ( bHasBounced && ((FRand() < 0.85) || (Velocity.Z > -50)) )
		bBounce = false;
	PlayLanded();
	RealHitNormal = HitNormal;
	HitNormal = Normal(HitNormal + 0.4 * VRand());
	if ( (HitNormal Dot RealHitNormal) < 0 )
		HitNormal *= -0.5;
	Velocity = 0.5 * (Velocity - 2 * HitNormal * (Velocity Dot HitNormal));
	RandSpin(70000);
	bHasBounced = True;
}

simulated function ZoneChange( Zoneinfo NewZone )
{
	if (NewZone.bWaterZone && !Region.Zone.bWaterZone)
	{
		Velocity=0.2*Velocity;
//		PlaySound(Sound'Drip1');
		bHasBounced=True;
	}
}


simulated function Landed( vector HitNormal )
{
	local rotator RandRot;

	PlayLanded();
	SetPhysics(PHYS_None);
	RandRot = Rotation;
	RandRot.Pitch = 0;
	RandRot.Roll = 0;
	SetRotation(RandRot);
}

function Eject(Vector Vel)
{
	Velocity = Vel + Instigator.Velocity*0.5;
	RandSpin(70000);
	if (Instigator.HeadRegion.Zone.bWaterZone)
	{
		Velocity = Velocity * (0.2+FRand()*0.2);
		bHasBounced=True;
	}
}

defaultproperties
{
     MaxSpeed=1000.000000
     Physics=PHYS_Falling
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=4.000000
     Mesh=Mesh'c_dnWeapon.ShotgunShell'
     bUnlit=false
     bNoSmooth=true
     bCollideActors=false
     bBounce=true
     bFixedRotationDir=true
     NetPriority=2.000000
     bNetOptional=true
}
