/*-----------------------------------------------------------------------------
	Snack_MRE
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_MRE extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     HealingAmount=20
     PickupIcon=Texture'hud_effects.ingame_hud.am_mrereg'
     PickupViewMesh=DukeMesh'c_dukeitems.MRE'
     Mesh=DukeMesh'c_dukeitems.MRE'
     ItemName="MRE"
     CollisionRadius=12.000000
     CollisionHeight=8.000000
}
