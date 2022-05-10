//=============================================================================
// dnFireworks1. (AHB3d)	
//=============================================================================
class dnFireworks1 expands dnFireworks;

// Blue Launching Firworks like in Starship Troopers
// Does NOT do damage.
// Uses dnFireworks1a and dnFireworks1b

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     UpdateEnabled=False
     BSPOcclude=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnFireworks1a',Mount=True)
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnFireworks1b',Mount=True)
     PrimeTime=0.200000
     PrimeTimeIncrement=0.100000
     MaximumParticles=1
     Lifetime=0.000000
     SpawnAtRadius=True
     SpawnAtHeight=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Textures(0)=Texture't_generic.lensflares.bluelensflare1B'
     StartDrawScale=8.000000
     EndDrawScale=8.000000
     PulseSeconds=0.000000
     bStasis=True
     Physics=PHYS_MovingBrush
     LifeSpan=4.000000
     Style=STY_Translucent
     bUnlit=True
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     bBounce=True
     bFixedRotationDir=True
     Mass=5.000000
     DestroyOnDismount=True
}
