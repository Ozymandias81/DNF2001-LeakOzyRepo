//=============================================================================
// dnPBomb_Effect1.
//=============================================================================
class dnPBomb_Effect1 expands dnParachuteBombExplosion;

// Explosion called by ParachuteBomb
// Stephen Cole

defaultproperties
{
     AdditionalSpawn(0)=(SpawnClass=None)
     Lifetime=0.000000
     InitialVelocity=(Z=0.000000)
     Textures(0)=Texture't_explosionFx.explosions.R3020001'
     DieOnLastFrame=True
     StartDrawScale=5.000000
     EndDrawScale=1.500000
     RotationVariance=1000.000000
     ZBias=8000.000000
     VisibilityHeight=0.000000
     bBurning=True
}
