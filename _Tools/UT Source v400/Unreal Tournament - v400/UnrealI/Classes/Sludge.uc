//=============================================================================
// Sludge.
//=============================================================================
class Sludge extends Ammo;

#exec TEXTURE IMPORT NAME=I_SludgeAmmo FILE=TEXTURES\HUD\i_sludge.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=sludgemesh ANIVFILE=MODELS\sludge_a.3D DATAFILE=MODELS\sludge_d.3D LODSTYLE=8
#exec MESH ORIGIN MESH=sludgemesh X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=sludgemesh SEQ=All    STARTFRAME=0  NUMFRAMES=11
#exec MESH SEQUENCE MESH=sludgemesh SEQ=Swirl    STARTFRAME=0  NUMFRAMES=11
#exec TEXTURE IMPORT NAME=Jsludge1 FILE=MODELS\pickup.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=sludgemesh X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=sludgemesh NUM=1 TEXTURE=Jsludge1

auto state Init
{
Begin:
	BecomePickup();
	LoopAnim('Swirl',0.3);
	GoToState('Pickup');
}

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=100
     UsedInWeaponSlot(8)=1
     PickupMessage="You picked up 25 Kilos of Tarydium Sludge"
     PickupViewMesh=Mesh'UnrealI.sludgemesh'
     MaxDesireability=0.220000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UnrealI.Icons.I_SludgeAmmo'
     Mesh=Mesh'UnrealI.sludgemesh'
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=15.000000
     bCollideActors=True
}
