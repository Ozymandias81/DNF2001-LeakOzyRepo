//=============================================================================
// dnExplosion1_ShowyEffect1.	Keith Schuler
// An additional explosion effect, since I ran out of AdditionalSpawn slots
//=============================================================================
class dnExplosion1_ShowyEffect1 expands dnExplosion1_Showy1;

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx
#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     Enabled=True
     AdditionalSpawn(0)=(SpawnClass=Class'dnParticles.dnExplosion1_Effect1')
     AdditionalSpawn(1)=(SpawnClass=None)
     AdditionalSpawn(2)=(SpawnClass=None)
     AdditionalSpawn(3)=(SpawnClass=None)
     AdditionalSpawn(4)=(SpawnClass=None)
     AdditionalSpawn(5)=(SpawnClass=None)
     AdditionalSpawn(6)=(SpawnClass=None)
     AdditionalSpawn(7)=(SpawnClass=None)
     Lifetime=1.450000
     Textures(0)=Texture't_generic.lensflares.subtle_flare6BC'
     StartDrawScale=16.000000
     EndDrawScale=16.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     AlphaStart=0.000000
     AlphaMid=0.360000
     AlphaEnd=0.000000
     AlphaRampMid=0.062500
     bUseAlphaRamp=True
     bHidden=False
     CollisionRadius=1.000000
     CollisionHeight=1.000000
}
