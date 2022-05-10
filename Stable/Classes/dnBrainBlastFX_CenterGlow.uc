//=============================================================================
// dnBrainBlastFX_CenterGlow. 			  April 18th, 2001 - Charlie Wiederhold
//=============================================================================
class dnBrainBlastFX_CenterGlow expands dnBrainBlastFX;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnBrainBlastFX_Plasma',Mount=True)
     SpawnNumber=0
     PrimeCount=1
     PrimeTimeIncrement=0.000000
     MaximumParticles=1
     Lifetime=0.000000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.particle_efx.pflare1'
     StartDrawScale=2.000000
     RotationVariance=65535.000000
     RotationVelocity=1.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     VisibilityRadius=6000.000000
     VisibilityHeight=6000.000000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
