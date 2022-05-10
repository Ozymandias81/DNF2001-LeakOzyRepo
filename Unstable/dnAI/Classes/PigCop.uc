//=============================================================================
// PigCop.uc
//=============================================================================
class PigCop extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
     EgoKillValue=8
     Mesh=DukeMesh'c_characters.PigCop'
     WeaponInfo(0)=(WeaponClass="dnGame.m16",PrimaryAmmoCount=500,altAmmoCount=50)
	 WeaponInfo(1)=(WeaponClass="")
	 WeaponInfo(2)=(WeaponClass="")
     Health=50
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     GroundSpeed=420.000000
     bIsHuman=True
     CollisionRadius=17.000000
     CollisionHeight=39.000000
	 bAggressiveToPlayer=true
}
