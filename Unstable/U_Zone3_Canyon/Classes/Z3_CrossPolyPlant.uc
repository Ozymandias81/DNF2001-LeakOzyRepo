//=============================================================================
// Z3_CrossPolyPlant.
//=============================================================================
class Z3_CrossPolyPlant expands Zone3_Canyon;

#exec OBJ LOAD FILE=..\Textures\m_zone3_canyon.dtx

defaultproperties
{
     SpawnOnHit=Class'dnParticles.dnBulletFX_LeavesSpawner'
     DestroyedSound=Sound'a_impact.Foliage.ImpFoliage014'
     HealthPrefab=HEALTH_SortaHard
     ItemName="Plant"
     bFlammable=True
     bMovable=False
     CollisionRadius=17.000000
     CollisionHeight=19.000000
     bBounce=False
     Mesh=DukeMesh'c_zone3_canyon.crosspoly2'
}
