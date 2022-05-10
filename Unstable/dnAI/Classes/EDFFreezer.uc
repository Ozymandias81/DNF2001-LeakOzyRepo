//=============================================================================
// EDFFreezer.uc
//=============================================================================
class EDFFreezer extends HumanNPC;

#exec OBJ LOAD FILE=..\Meshes\c_characters.dmx

defaultproperties
{
//     bExplicitCover=True
     EgoKillValue=8
     Mesh=DukeMesh'c_characters.EDF_freezer'
     WeaponInfo(0)=(WeaponClass="dnGame.pistol",PrimaryAmmoCount=500,altAmmoCount=50)
     WeaponInfo(1)=(WeaponClass="dnGame.m16",PrimaryAmmoCount=950,altAmmoCount=25)
     WeaponInfo(2)=(WeaponClass="dnGame.shotgun",PrimaryAmmoCount=750,altAmmoCount=25)
     Health=50
     BaseEyeHeight=27.000000
     EyeHeight=27.000000
     GroundSpeed=420.000000
     bIsHuman=True
     CollisionRadius=17.000000
     CollisionHeight=39.000000
     bSnatched=false
}
