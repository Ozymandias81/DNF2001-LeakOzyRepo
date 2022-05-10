/*-----------------------------------------------------------------------------
	RainMistGenerator
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class RainMistGenerator extends SoftParticleSystem;

// Velocity of 50 in the player's "left" direction.

defaultproperties
{
	Style=STY_Translucent
	Enabled=true
	CollisionRadius=0
	CollisionHeight=0
	UseZoneVelocity=false
	UseZoneGravity=false
	Textures(0)=texture't_generic.rain.rain_mist1BC'
	Textures(1)=texture't_generic.rain.rain_mist2BC'
	Textures(2)=texture't_generic.rain.rain_mist3BC'
	Textures(3)=texture't_generic.rain.rain_mist4BC'
	AlphaEnd=0.0
	AlphaMid=0.5
	AlphaStart=0.0
	bUseAlphaRamp=true
	InitialVelocity=(X=50.0,Y=0.0,Z=0.0)
	MaxVelocityVariance=(X=0.0,Y=0.0,Z=0.0)
	MaximumParticles=6
	Lifetime=3.0
	SpawnPeriod=0.7
	UpdateWhenNotVisible=true
	RelativeLocation=true
	RelativeRotation=false
	RelativeSpawn=true
	bIgnoreBList=true
}