//=============================================================================
// Sludge.
//=============================================================================
class BioAmmo extends TournamentAmmo;

#exec MESH IMPORT MESH=BioAmmoM ANIVFILE=MODELS\bioammo_a.3D DATAFILE=MODELS\bioammo_d.3D X=0 Y=0 Z=0
#exec MESH LODPARAMS MESH=shieldM STRENGTH=0.3
#exec MESH ORIGIN MESH=BioAmmoM X=0 Y=0 Z=0 Roll=64 PITCH=128
#exec MESH SEQUENCE MESH=BioAmmoM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=JBammo1 FILE=MODELS\bioammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=BioAmmoM X=0.04 Y=0.04 Z=0.08
#exec MESHMAP SETTEXTURE MESHMAP=BioAmmoM NUM=1 TEXTURE=JBammo1

auto state Init
{
Begin:
	BecomePickup();
	GoToState('Pickup');
}

defaultproperties
{
	 Physics=PHYS_Falling;
     AmmoAmount=25
     MaxAmmo=100
     UsedInWeaponSlot(8)=1
     PickupMessage="You picked up the Biosludge Ammo."
     PickupViewMesh=Mesh'botpack.BioAmmoM'
     MaxDesireability=0.220000
     Mesh=Mesh'Botpack.BioAmmoM'
     bMeshCurvy=False
     CollisionRadius=22.000000
     CollisionHeight=9.000000
     bCollideActors=True
	 ItemName="Biosludge Ammo"
}
