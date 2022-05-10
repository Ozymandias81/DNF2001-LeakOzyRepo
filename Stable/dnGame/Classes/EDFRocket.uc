/*-----------------------------------------------------------------------------
	EDFRocket
	Author: Everybody has raped this code.
-----------------------------------------------------------------------------*/
class EDFRocket extends dnRocket;

defaultproperties
{
     TrailClass=Class'dnParticles.dnRocketFX_Burn'
     AdditionalMountedActors(0)=(ActorClass=Class'dnGame.dnWeaponFX',MountOrigin=(Y=5.500000,Z=-12.000000),MountAngles=(Roll=-16384))
     ExplosionClass=Class'dnParticles.dnExplosion1'
     speed=700.000000
     MaxSpeed=1100.000000
     Damage=100.000000
     MomentumTransfer=80000
     RemoteRole=ROLE_SimulatedProxy
     LifeSpan=6.000000
     LodMode=LOD_Disabled
     Mesh=DukeMesh'c_dnWeapon.rpg_rocket'
     AmbientGlow=96
     bUnlit=True
     SoundRadius=64
     SoundVolume=255
     SoundPitch=100
     AmbientSound=Sound'dnsWeapn.missile.MBurn09'
     LightType=LT_Steady
     LightEffect=LE_NonIncidence
     LightBrightness=255
     LightHue=28
     LightSaturation=92
     LightRadius=6
     bBounce=True
}
