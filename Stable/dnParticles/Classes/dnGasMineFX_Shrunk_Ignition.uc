//=============================================================================
// dnGasMineFX_Shrunk_Ignition. 					May 31st, 2001 - Charlie Wiederhold
//=============================================================================
class dnGasMineFX_Shrunk_Ignition expands dnGasMineFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx
#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx

var() int IgniteDamage;
var() sound BlastSound;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	HurtRadius( IgniteDamage, 164.0, class'FireDamage', 10000, Location );
	PlaySound( BlastSound, SLOT_Talk, 0.4, true, 2000.f );
	PlaySound( BlastSound, SLOT_Interface, 0.4, true, 2000.f );
}

defaultproperties
{
	 BlastSound=sound'dnsWeapn.Flamethrower.FTGasIgnite'
     bIgnoreBList=True
     IgniteDamage=30
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnGasMineFX_Shrunk_Ignition_Flash')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnGasMineFX_Shrunk_Ignition_Shockwave')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnGasMineFX_Shrunk_Ignition_Residue')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=16
     MaximumParticles=16
     Lifetime=0.600000
     LifetimeVariance=0.100000
     InitialVelocity=(Z=16.000000)
     MaxVelocityVariance=(X=8.000000,Y=8.000000,Z=16.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend2RC'
     Textures(2)=Texture't_firefx.firespray.flamehotend3RC'
     DrawScaleVariance=0.10000
     StartDrawScale=0.30000
     EndDrawScale=0.3000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     Style=STY_Translucent
     bUnlit=True
	 RemoteRole=ROLE_SimulatedProxy
}
