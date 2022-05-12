//=============================================================================
// RazorAmmo.
//=============================================================================
class RazorAmmo extends Ammo;

#exec TEXTURE IMPORT NAME=I_RazorAmmo FILE=TEXTURES\HUD\i_razor.PCX GROUP="Icons" MIPS=OFF

#exec MESH IMPORT MESH=RazorAmmoMesh ANIVFILE=MODELS\rabox_a.3D DATAFILE=MODELS\rabox_d.3D LODSTYLE=8 LODFRAME=1
#exec MESH LODPARAMS MESH=RazorAmmoMesh STRENGTH=0.3
#exec MESH ORIGIN MESH=RazorAmmoMesh X=0 Y=0 Z=0 YAW=0
#exec MESH SEQUENCE MESH=RazorAmmoMesh SEQ=All    STARTFRAME=0  NUMFRAMES=2
#exec MESH SEQUENCE MESH=RazorAmmoMesh SEQ=Open   STARTFRAME=0  NUMFRAMES=2
#exec TEXTURE IMPORT NAME=JPickup21 FILE=..\unrealshare\MODELS\pickup2.PCX GROUP="Skins"
#exec MESHMAP SCALE MESHMAP=RazorAmmoMesh X=0.05 Y=0.05 Z=0.1
#exec MESHMAP SETTEXTURE MESHMAP=RazorAmmoMesh NUM=1 TEXTURE=JPickup21

var bool bOpened;

auto state Pickup
{
	function Touch( Actor Other )
	{
		local Vector Dist2D;

		if ( bOpened )
		 Super.Touch(Other);
		if ( (Pawn(Other) == None) || !Pawn(Other).bIsPlayer )
			return;
		Dist2D = Other.Location - Location;
		Dist2D.Z = 0;
		if ( VSize(Dist2D) <= 40.0 )
			Super.Touch(Other);
		else 
		{
			SetCollisionSize(20.0, CollisionHeight);
			SetLocation(Location); //to force untouch
			bOpened = true;
			PlayAnim('Open', 0.05);
		}
	}

	function Landed(vector HitNormal)
	{
		Super.Landed(HitNormal);
		if ( !bOpened )
		{
			bCollideWorld = false;
			SetCollisionSize(170,CollisionHeight);
		}
	}
}

defaultproperties
{
     AmmoAmount=25
     MaxAmmo=75
     UsedInWeaponSlot(7)=1
     PickupMessage="You picked up Razor Blades"
     PickupViewMesh=Mesh'UnrealI.RazorAmmoMesh'
     MaxDesireability=0.220000
     PickupSound=Sound'UnrealShare.Pickups.AmmoSnd'
     Icon=Texture'UnrealI.Icons.I_RazorAmmo'
     Physics=PHYS_Falling
     Mesh=Mesh'UnrealI.RazorAmmoMesh'
     bMeshCurvy=False
     CollisionRadius=20.000000
     CollisionHeight=10.000000
     bCollideActors=True
}
