//=============================================================================
// Z1_PokerChip_Black.					October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_PokerChip_Black expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     SpawnOnHit=None
     MassPrefab=MASS_Ultralight
     HealthPrefab=HEALTH_NeverBreak
     Grabbable=True
     PlayerViewOffset=(X=0.825000,Y=-1.875000,Z=2.500000)
     BobDamping=0.975000
     LodMode=LOD_Disabled
     ItemName="$100 Poker Chip"
     CollisionRadius=2.000000
     CollisionHeight=1.000000
     bMeshLowerByCollision=False
     Physics=PHYS_Falling
     Mesh=DukeMesh'c_zone1_vegas.pokrsinchipblk'
}
