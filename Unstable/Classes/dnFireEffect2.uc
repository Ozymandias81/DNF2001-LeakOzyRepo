//=============================================================================
// dnFireEffect2.	Keith Schuler September 16,2000
// Fire Effect to combine with dnFireEffect3 for Lady Killer huge outside fires
//=============================================================================
class dnFireEffect2 expands dnFireEffect;

#exec OBJ LOAD FILE=..\sounds\a_ambient.dfx

defaultproperties
{
     Enabled=False
     DestroyWhenEmpty=True
     PrimeCount=1
     Lifetime=2.000000
     RelativeLocation=False
     RelativeRotation=False
     InitialVelocity=(X=0.000000,Y=200.000000,Z=200.000000)
     InitialAcceleration=(Y=-40.000000,Z=0.000000)
     MaxVelocityVariance=(X=100.000000,Y=100.000000)
     Textures(1)=Texture't_generic.fireflames.flame2aRC'
     Textures(2)=Texture't_generic.fireflames.flame3aRC'
     Textures(3)=Texture't_generic.fireflames.flame4aRC'
     DieOnLastFrame=True
     StartDrawScale=4.000000
     EndDrawScale=0.000000
     TriggerOnSpawn=True
     TriggerType=SPT_Pulse
     PulseSeconds=8.000000
     PulseSecondsVariance=1.000000
     VisibilityRadius=8192.000000
     VisibilityHeight=8192.000000
     bDirectional=True
     CollisionHeight=22.000000
     bCollideActors=True
     Physics=PHYS_MovingBrush
     SoundVolume=255
     AmbientSound=Sound'a_ambient.Fire.DestructFire'
}
