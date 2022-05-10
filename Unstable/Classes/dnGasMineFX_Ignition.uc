//=============================================================================
// dnGasMineFX_Ignition. 					May 31st, 2001 - Charlie Wiederhold
//=============================================================================
class dnGasMineFX_Ignition expands dnGasMineFX;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx
#exec OBJ LOAD FILE=..\sounds\dnsWeapn.dfx

var() int IgniteDamage;
var() sound BlastSound;

function PostBeginPlay()
{
	Super.PostBeginPlay();

	HurtRadius( IgniteDamage, 240.0, class'FireDamage', 10000, Location );
	PlaySound( BlastSound, SLOT_Talk, 0.75, true, 2000.f );
	PlaySound( BlastSound, SLOT_Interface, 0.75, true, 2000.f );
}

defaultproperties
{
	 BlastSound=sound'dnsWeapn.Flamethrower.FTGasIgnite'
     bIgnoreBList=True
     IgniteDamage=75
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnGasMineFX_Ignition_Flash')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnGasMineFX_Ignition_Shockwave')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.dnGasMineFX_Ignition_Residue')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=16
     MaximumParticles=16
     Lifetime=0.600000
     LifetimeVariance=0.100000
     InitialVelocity=(Z=64.000000)
     MaxVelocityVariance=(X=32.000000,Y=32.000000,Z=32.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend2RC'
     Textures(2)=Texture't_firefx.firespray.flamehotend3RC'
     DrawScaleVariance=0.250000
     StartDrawScale=1.000000
     EndDrawScale=1.00000
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=2.000000
     UpdateWhenNotVisible=True
     AlphaMid=1.000000
     AlphaEnd=0.000000
     AlphaRampMid=0.750000
     bUseAlphaRamp=True
     CollisionRadius=128.000000
     CollisionHeight=128.000000
     Style=STY_Translucent
     bUnlit=True
	 RemoteRole=ROLE_SimulatedProxy
}
