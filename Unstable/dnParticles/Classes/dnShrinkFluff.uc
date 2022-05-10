//=============================================================================
// dnShrinkFluff. (CDH)
// Fluff particles coming off of shrink ray stream's origin
//=============================================================================
class dnShrinkFluff expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     GroupID=151
     SpawnPeriod=0.050000
     MaximumParticles=5
     Lifetime=1.000000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     RealtimeAccelerationVariance=(X=200.000000,Y=200.000000,Z=200.000000)
     UseZoneGravity=False
     LineStartColor=(R=34,G=247,B=39)
     LineEndColor=(R=43,G=43,B=238)
     Textures(0)=Texture't_generic.lensflares.flare1sah'
     StartDrawScale=0.125000
     EndDrawScale=0.062500
     AlphaEnd=0.000000
     UpdateWhenNotVisible=True
     bHidden=True
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
