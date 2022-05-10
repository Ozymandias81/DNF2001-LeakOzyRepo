//=============================================================================
// dnShrinkStream. (CDH)
// Primary beam of shrink ray
//=============================================================================
class dnShrinkStream expands SoftParticleSystem;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     GroupID=151
     SpawnPeriod=0.050000
     Lifetime=2.500000
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(X=500.000000,Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneGravity=False
     LineStartColor=(R=34,G=247,B=39)
     LineEndColor=(R=43,G=43,B=238)
     Textures(0)=Texture't_generic.lensflares.flare1sah'
     StartDrawScale=0.250000
     EndDrawScale=0.125000
     UpdateWhenNotVisible=True
     bHidden=True
     Style=STY_Translucent
     CollisionRadius=0.000000
     CollisionHeight=0.000000
}
