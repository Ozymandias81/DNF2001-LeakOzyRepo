/*-----------------------------------------------------------------------------
	CannonFlash2
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class CannonFlash2 extends FlashEffects;

#exec OBJ LOAD FILE=..\Meshes\c_dnWeapon.dmx

simulated function Destroyed()
{
	local rotator r;

	Super.Destroyed();

	/*
	r = Rotation;
	r.Roll += 16384;
	spawn(class'dnMuzzleRPGSmoke2',,,,r);
	*/
}

defaultproperties
{
	Mesh=mesh'c_dnweapon.flash_shotgun'
	DrawScale=3.0
}