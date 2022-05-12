//=============================================================================
// BladeHopper.
//=============================================================================
class BladeHopper extends TournamentAmmo;

#exec MESH IMPORT MESH=BladeHopperM ANIVFILE=MODELS\razorammo_a.3D DATAFILE=MODELS\razorammo_d.3D LODSTYLE=10
#exec MESH ORIGIN MESH=BladeHopperM X=0 Y=0 Z=-70 YAW=0
#exec MESH SEQUENCE MESH=BladeHopperM SEQ=All    STARTFRAME=0  NUMFRAMES=1
#exec TEXTURE IMPORT NAME=BladeHopperT FILE=MODELS\razorammo.PCX GROUP="Skins"  LODSET=2
#exec MESHMAP SCALE MESHMAP=BladeHopperM X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=BladeHopperM NUM=0 TEXTURE=BladeHopperT

defaultproperties
{
	 Skin=Texture'Botpack.BladeHopperT'
     AmmoAmount=25
     MaxAmmo=75
     UsedInWeaponSlot(7)=1
     PickupMessage="You picked up some Razor Blades."
	 ItemName="Blade Hopper"
     PickupViewMesh=Mesh'Botpack.BladeHopperM'
     MaxDesireability=0.220000
     Mesh=Mesh'Botpack.BladeHopperM'
     bMeshCurvy=False
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
