/*-----------------------------------------------------------------------------
	Snack_Burrito
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class Snack_Burrito extends VendSnack;

#exec OBJ LOAD FILE=..\Meshes\c_dukeitems.dmx
#exec OBJ LOAD FILE=..\Textures\ezvend.dtx
#exec OBJ LOAD FILE=..\Textures\SMK5.dtx
#exec OBJ LOAD FILE=..\Sounds\a_dukevoice.dfx
#exec OBJ LOAD FILE=..\Textures\hud_effects.dtx

defaultproperties
{
     PickupIcon=Texture'hud_effects.ingame_hud.am_burrito'
     VendSound=Sound'a_dukevoice.ezvend.ez-burrito'
     VendTitle(0)=Texture'ezvend.descriptions.burto_desc0'
     VendTitle(1)=Texture'ezvend.descriptions.burto_desc1'
     VendTitle(2)=Texture'ezvend.descriptions.burto_desc2'
     VendTitle(3)=Texture'ezvend.descriptions.burto_desc3'
     VendIcon=SmackerTexture'SMK5.s_burito_spn'
     PickupViewMesh=DukeMesh'c_dukeitems.Burrito'
     Mesh=DukeMesh'c_dukeitems.Burrito'
     ItemName="Burrito"
     CollisionRadius=10.000000
     CollisionHeight=8.000000
}
