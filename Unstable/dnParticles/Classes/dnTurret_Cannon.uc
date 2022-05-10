//=============================================================================
// dnTurret_Cannon.
//=============================================================================
class dnTurret_Cannon expands dnTurret_Explosion;

#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnTurret_Cannon_EffectA')
     AdditionalSpawn(1)=(SpawnClass=Class'dnParticles.dnWallTurret_Cannon')
     AdditionalSpawn(2)=(SpawnClass=Class'dnParticles.Turret_Cannon_Mark')
     AdditionalSpawn(3)=(SpawnClass=Class'dnParticles.dnTurret_Cannon_EffectB')
     SpawnNumber=0
     SpawnPeriod=0.000000
     PrimeCount=1
     Lifetime=0.250000
     UseZoneGravity=False
     StartDrawScale=10.000000
     EndDrawScale=0.100000
     UpdateWhenNotVisible=True
     TriggerType=SPT_None
}
