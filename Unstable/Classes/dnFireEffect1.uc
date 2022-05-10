//=============================================================================
// dnFireEffect1. 									Keith Schuler Sept 13, 2000
//=============================================================================
class dnFireEffect1 expands dnFireEffect;

// Generic fire. Spawned by the G_FireEffect1 decoration

defaultproperties
{
     Lifetime=0.500000
     LifetimeVariance=0.200000
     RelativeSpawn=True
     RelativeLocation=False
     RelativeRotation=False
     MaxVelocityVariance=(X=64.000000,Y=64.000000,Z=150.000000)
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     DieOnLastFrame=True
     DrawScaleVariance=0.250000
     StartDrawScale=1.300000
     EndDrawScale=0.250000
     UpdateWhenNotVisible=True
     TriggerType=SPT_Toggle
     Physics=PHYS_MovingBrush
     bDirectional=True
     SoundVolume=255
     CollisionRadius=6.000000
     CollisionHeight=1.000000
}
