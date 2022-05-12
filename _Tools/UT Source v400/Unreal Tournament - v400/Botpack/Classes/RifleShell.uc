//=============================================================================
// RifleShell.
//=============================================================================
class RifleShell extends BulletBox;

defaultproperties
{
     AmmoAmount=1
     ParentAmmo=Botpack.BulletBox
	 ItemName="Rifle Round"
     PickupMessage="You got a rifle round."
     PickupViewMesh=UnrealI.RifleRoundM
     Mesh=UnrealI.RifleRoundM
     CollisionRadius=+00015.000000
     CollisionHeight=+00015.000000
}
