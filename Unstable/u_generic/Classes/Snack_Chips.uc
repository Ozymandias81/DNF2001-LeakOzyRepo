/*-----------------------------------------------------------------------------
	Snack_Chips
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_Chips extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx

defaultproperties
{
     HealingAmount=15
     PickupIcon=Texture'hud_effects.ingame_hud.am_chips'
     VendSound=Sound'a_dukevoice.ezvend.ez-sportsdrink'
     VendTitle(0)=Texture'ezvend.descriptions.chips_desc0'
     VendTitle(1)=Texture'ezvend.descriptions.chips_desc1'
     VendTitle(2)=Texture'ezvend.descriptions.chips_desc2'
     VendTitle(3)=Texture'ezvend.descriptions.chips_desc3'
     VendIcon=SmackerTexture'SMK5.chips_spn'
     PickupViewMesh=DukeMesh'c_dukeitems.chips'
     Mesh=DukeMesh'c_dukeitems.chips'
     ItemName="Chips"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
