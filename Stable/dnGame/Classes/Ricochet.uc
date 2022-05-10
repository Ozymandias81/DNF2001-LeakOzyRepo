/*-----------------------------------------------------------------------------
	Ricochet
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Ricochet extends Effects;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var sound RicochetSounds[4];
var float AmbientTime;

simulated function PostBeginPlay()
{
	AmbientSound = RicochetSounds[Rand(4)];
	AmbientTime = GetSoundDuration( AmbientSound );
	LifeSpan = AmbientTime;
}

simulated function Tick( float Delta )
{
	AmbientTime -= Delta;
	if (AmbientTime <= 0)
	{
		AmbientSound = None;
		Disable( 'Tick' );
		Destroy();
	}
}

defaultproperties
{
	Texture=None
	DrawType=DT_Sprite
	RicochetSounds(0)=sound'dnsWeapn.Ricochet.Ricochet26'
	RicochetSounds(1)=sound'dnsWeapn.Ricochet.Ricochet33'
	RicochetSounds(2)=sound'dnsWeapn.Ricochet.Ricochet34'
	RicochetSounds(3)=sound'dnsWeapn.Ricochet.Ricochet35'
	SoundVolume=255
	SoundRadius=150
	RemoteRole=ROLE_None
	bNetTemporary=true
}