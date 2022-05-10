/*-----------------------------------------------------------------------------
	Snack_CowPie
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_CowPie extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\SMK6.dtx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\ezvend.dtx

defaultproperties
{
     HealingAmount=15
     PickupIcon=Texture'hud_effects.ingame_hud.am_cowpie'
     VendSound=Sound'a_dukevoice.ezvend.ez-sportsdrink'
     VendTitle(0)=Texture'ezvend.descriptions.cowpie_desc00'
     VendTitle(1)=Texture'ezvend.descriptions.cowpie_desc01'
     VendTitle(2)=Texture'ezvend.descriptions.cowpie_desc02'
     VendTitle(3)=Texture'ezvend.descriptions.cowpie_desc03'
     VendIcon=SmackerTexture'SMK6.cowpie_spn'
     PickupViewMesh=DukeMesh'c_dukeitems.Cowpie'
     Mesh=DukeMesh'c_dukeitems.Cowpie'
     ItemName="Cow Pie"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
