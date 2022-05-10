//=============================================================================
// Z1_PokerChipStack_Black. 			October 26th, 2000 - Charlie Wiederhold
//=============================================================================
class Z1_PokerChipStack_Black expands Zone1_Vegas;

#exec OBJ LOAD FILE=..\sounds\a_zone1_vegas.dfx
#exec OBJ LOAD FILE=..\meshes\c_zone1_vegas.dmx
#exec OBJ LOAD FILE=..\textures\m_zone1_vegas.dtx

defaultproperties
{
     FragType(0)=Class'dnParticles.dnDebris_PokerChips_Black'
     FragType(1)=Class'dnParticles.dnDebris_Smoke'
     SpawnOnHit=None
     DestroyedSound=Sound'a_zone1_vegas.Casino.ChipSplat'
     HealthPrefab=HEALTH_Easy
     ItemName="$100 Poker Chip Stack"
     bFlammable=True
     CollisionRadius=4.500000
     CollisionHeight=4.500000
     Physics=PHYS_Falling
     WaterSplashClass=None
     Mesh=DukeMesh'c_zone1_vegas.pokrchipblk6'
}
