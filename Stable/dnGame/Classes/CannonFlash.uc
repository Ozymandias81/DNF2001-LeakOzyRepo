/*-----------------------------------------------------------------------------
	CannonFlash
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class CannonFlash extends FlashEffects;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

simulated function Destroyed()
{
	local rotator r;

	Super.Destroyed();

	r = Rotation;
	r.Roll += 16384;
	spawn(class'dnMuzzleRPGSmoke2',,,,r);
}

defaultproperties
{
	Mesh=mesh'c_dnweapon.flash_pistol'
	DrawScale=5.0
}