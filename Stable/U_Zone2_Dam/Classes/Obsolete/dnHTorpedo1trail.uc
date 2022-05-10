//=============================================================================
// dnHTorpedo1trail.
//=============================================================================
class dnHTorpedo1trail expands dnMissileTrail;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     Lifetime=1.500000
     InitialAcceleration=(Z=64.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.Smoke.gensmoke1cRC'
     Textures(1)=Texture't_generic.Smoke.gensmoke1dRC'
     Textures(2)=Texture't_generic.Smoke.gensmoke1bRC'
     AlphaStart=0.750000
     AlphaEnd=0.000000
     bHidden=True
     bUnlit=True
}
