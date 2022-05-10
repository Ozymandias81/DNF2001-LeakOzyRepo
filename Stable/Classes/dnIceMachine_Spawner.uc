//=============================================================================
// dnIceMachine_Spawner. 			   November 15th, 2000 - Charlie Wiederhold
//=============================================================================
class dnIceMachine_Spawner expands dnIce;

// Ice that spawns from the ice machine

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Enabled=False
     TurnedOnSound=Sound'a_generic.SodaFountain.IceDispense'
     TurnedOnSoundRadius=384.000000
     Lifetime=1.500000
     RelativeSpawn=True
     InitialVelocity=(X=32.000000,Z=0.000000)
     MaxVelocityVariance=(X=16.000000,Y=16.000000)
     BounceElasticity=0.500000
     Bounce=True
     ParticlesCollideWithWorld=True
     Textures(0)=Texture't_generic.iceparticles.iceparticle1aRC'
     Textures(1)=Texture't_generic.iceparticles.iceparticle1bRC'
     Textures(2)=Texture't_generic.iceparticles.iceparticle1cRC'
     StartDrawScale=0.075000
     EndDrawScale=0.075000
     AlphaEnd=0.000000
     RotationVariance=65535.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Pulse
     PulseSeconds=3.500000
     bDirectional=True
     bEdShouldSnap=True
     Style=STY_Translucent
     DrawScale=0.250000
     bUnlit=True
     CollisionRadius=4.000000
     CollisionHeight=0.000000
}
