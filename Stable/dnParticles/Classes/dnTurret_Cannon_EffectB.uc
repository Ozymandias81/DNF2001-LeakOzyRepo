//=============================================================================
// dnTurret_Cannon_EffectB.
//=============================================================================

// Cole

class dnTurret_Cannon_EffectB expands dnTurret_Cannon_EffectA;

#exec OBJ LOAD FILE=..\Textures\t_explosionFx.dtx

defaultproperties
{
     Lifetime=0.125000
     Textures(0)=Texture't_explosionFx.explosions.Twil_004'
     EndDrawScale=0.260000
     AlphaStart=0.100000
     AlphaEnd=0.000000
     AlphaStartUseSystemAlpha=True
}
