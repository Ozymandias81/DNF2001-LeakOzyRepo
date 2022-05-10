/*-----------------------------------------------------------------------------
	BulletWhiz
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class BulletWhiz extends Effects;

#exec OBJ LOAD FILE=..\Sounds\dnsWeapn.dfx

var sound WhizSounds[3];
var float AmbientTime;

simulated function PostBeginPlay()
{
	local sound Whiz;
	
	Whiz = WhizSounds[Rand(3)];
	Owner.PlayOwnedSound(Whiz, SLOT_Interface, 2.0);
	Owner.PlayOwnedSound(Whiz, SLOT_Ambient, 2.0);
}

defaultproperties
{
	WhizSounds(0)=sound'a_impact.Bullet.BulletWhiz05'
	WhizSounds(1)=sound'a_impact.Bullet.BulletWhiz08'
	WhizSounds(2)=sound'a_impact.Bullet.BulletWhiz09'
	RemoteRole=ROLE_SimulatedProxy
	bNetTemporary=true
	bHidden=true
	LifeSpan=0.05
}