/*-----------------------------------------------------------------------------
	dnFlameThrowerFX_Shrunk_NozzleFlame
	Effect: Charlie Wiederhold
	Gameplay: Brandon Reinhart

	Originally in dnParticles, moved to dnGame to solve package dependency.
-----------------------------------------------------------------------------*/
class dnFlameThrowerFX_Shrunk_NozzleFlame expands dnFlameThrowerFX_Shrunk;

#exec OBJ LOAD FILE=..\Textures\t_firefx.dtx

simulated function PreBeginPlay()
{
	// Dependency problem?  This wouldn't take in the default properties.
	CollisionActorClass = class'FlamethrowerCollisionActorShrunk';
	Super.PreBeginPlay();
}

simulated function Trigger( actor Other, Pawn Instigator )
{
	SetTimer(0.25, true, 1);

	Super.Trigger( Other, Instigator );
}

simulated function Timer(optional int TimerNum)
{
	if ( TimerNum == 1 )
	{
		SetTimer(0.0, false, 1);
		GlobalTrigger( NameForString(string(Tag)$"Flame") );
	}
	else
		Super.Timer(TimerNum);
}

defaultproperties
{
     Enabled=False
     SpawnPeriod=0.007500
     Lifetime=0.900000
     LifetimeVariance=0.300000
     RelativeSpawn=True
     SmoothSpawn=True
     InitialVelocity=(X=32.000000,Z=0.000000)
     InitialAcceleration=(Z=8.000000)
     MaxVelocityVariance=(X=0.000000,Y=1.000000,Z=1.000000)
     UseZoneGravity=False
     Textures(0)=Texture't_firefx.firespray.flamehotend3RC'
     Textures(1)=Texture't_firefx.firespray.flamehotend2RC'
     Textures(2)=Texture't_firefx.firespray.flamehotend1RC'
     Textures(3)=Texture't_firefx.firespray.Flamestill1aRC'
     StartDrawScale=0.004000
     EndDrawScale=0.032500
     RotationVariance=65535.000000
     RotationVelocityMaxVariance=3.000000
     UpdateWhenNotVisible=True
     UseParticleCollisionActors=True
     ParticlesPerCollision=14
     NumCollisionActors=8
     AlphaMid=1.000000
     AlphaRampMid=0.100000
     CollisionRadius=0.000000
     CollisionHeight=0.000000
     Style=STY_Translucent
     bUnlit=True
}
