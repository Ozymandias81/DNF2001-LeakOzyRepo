//=============================================================================
// dnEMPFX_Spawner2. 				Feb 21st, 2001 - Charlie Wiederhold
//=============================================================================
class dnEMPFX_Spawner2 expands dnEMPFX;

// Spawner for the shock effects

#exec OBJ LOAD FILE=..\Textures\t_test.dtx

defaultproperties
{
     Enabled=True
     DestroyWhenEmpty=False
     DestroyWhenEmptyAfterSpawn=True
     AdditionalSpawn(2)=(TakeParentTag=True,Mount=True)
     AdditionalSpawn(3)=(TakeParentTag=True,Mount=True)
     AdditionalSpawn(4)=(TakeParentTag=True,Mount=True)
     AdditionalSpawn(5)=(TakeParentTag=True,Mount=True)
     AdditionalSpawn(6)=(TakeParentTag=True,Mount=True)
     SpawnNumber=1
     SpawnPeriod=0.250000
     PrimeCount=0
     MaximumParticles=0
     Lifetime=0.500000
     RelativeLocation=True
     RelativeRotation=True
     Connected=True
     LineStartColor=(R=128,G=255,B=255)
     LineEndColor=(R=128,G=255,B=255)
     Textures(0)=Texture't_test.smokeeffects.charlieeffecttest1BC'
     StartDrawScale=0.400000
     EndDrawScale=0.000000
     AlphaStart=0.000000
     AlphaEnd=1.000000
     TriggerAfterSeconds=0.850000
     TriggerType=SPT_Disable
}
