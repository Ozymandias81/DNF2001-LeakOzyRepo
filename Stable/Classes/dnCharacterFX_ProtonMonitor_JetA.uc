//=============================================================================
// dnCharacterFX_ProtonMonitor_JetA. 	  March 22nd, 2001 - Charlie Wiederhold
//=============================================================================
class dnCharacterFX_ProtonMonitor_JetA expands dnCharacterFX;

// Jet for the Proton Monitor

#exec OBJ LOAD FILE=..\Textures\t_generic.dtx

defaultproperties
{
     DestroyWhenEmptyAfterSpawn=True
     SpawnNumber=3
     SpawnPeriod=0.050000
     PrimeTimeIncrement=0.000000
     MaximumParticles=45
     Lifetime=0.600000
     SpawnAtRadius=True
     RelativeLocation=True
     RelativeRotation=True
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=0.000000,Y=0.000000)
     Apex=(Z=45.000000)
     ApexInitialVelocity=-96.000000
     UseZoneGravity=False
     UseZoneVelocity=False
     Textures(0)=Texture't_generic.LensFlares.genwinflare2BC'
     StartDrawScale=0.600000
     EndDrawScale=0.400000
     TriggerType=SPT_Disable
     AlphaEnd=0.000000
     bBurning=True
     CollisionRadius=9.000000
     CollisionHeight=0.000000
     Physics=PHYS_MovingBrush
     Style=STY_Translucent
     bUnlit=True
}
