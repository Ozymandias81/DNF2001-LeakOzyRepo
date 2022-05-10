//=============================================================================
// dnFireEffect.                   Created by Charlie Wiederhold April 13, 2000
//=============================================================================
class dnFireEffect expands SoftParticleSystem;

// General fire effect class.
// Does NOT do damage. 

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     SpawnPeriod=0.050000
     Lifetime=1.000000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=64.000000,Y=64.000000,Z=64.000000)
     InitialAcceleration=(Y=64.000000,Z=64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_generic.fireflames.flame1aRC'
     EndDrawScale=2.000000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
     PulseSeconds=0.000000
     bBurning=True
     CollisionRadius=128.000000
     CollisionHeight=128.000000
     Style=STY_Translucent
     bUnlit=True
}
