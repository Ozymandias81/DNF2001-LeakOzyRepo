//=============================================================================
// Z1_Ps_Anchor.
//=============================================================================
// AllenB
class Z1_Ps_Anchor expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx
// September 28th, 2000 - "Nobody expects the Actor Inquisition!" - Charlie Wiederhold

defaultproperties
{
     FragType(0)=None
     MassPrefab=MASS_Heavy
     HealthPrefab=HEALTH_NeverBreak
     bLandForward=True
     LandFrontCollisionRadius=64.000000
     LandFrontCollisionHeight=4.000000
     LandSideCollisionRadius=64.000000
     LandSideCollisionHeight=4.000000
     Grabbable=True
     PlayerViewOffset=(X=-1.000000,Y=4.000000,Z=0.000000)
     Health=0
     ItemName="Anchor"
     bTakeMomentum=False
     CollisionHeight=39.000000
     Mass=300.000000
     Mesh=DukeMesh'c_zone1_vegas.ps_anchor'
}
