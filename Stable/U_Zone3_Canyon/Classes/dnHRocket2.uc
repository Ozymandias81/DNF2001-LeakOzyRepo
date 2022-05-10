//=============================================================================
// dnHRocket2.
//=============================================================================
class dnHRocket2 expands dnHomingRocket;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

defaultproperties
{
     TurnScaler=5.000000
     TrailClass=Class'dnParticles.dnHRocket2trail'
     TrailMountOrigin=(X=-53.000000)
     AdditionalMountedActors(0)=(MountOrigin=(X=-53.000000,Z=24.000000))
     ExplosionClass=Class'dnParticles.dnParachuteBombExplosion'
     speed=2000.000000
     MaxSpeed=2000.000000
     MomentumTransfer=8000
     VisibilityRadius=8000.000000
     VisibilityHeight=8000.000000
     LifeSpan=10.000000
     Mesh=DukeMesh'c_dnWeapon.missile_air'
     bUnlit=False
     DrawScale=1.000000
}
