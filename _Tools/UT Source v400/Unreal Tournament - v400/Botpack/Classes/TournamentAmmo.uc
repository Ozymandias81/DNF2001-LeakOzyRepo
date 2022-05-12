//=============================================================================
// TournamentAmmo.
//=============================================================================
class TournamentAmmo extends Ammo
	abstract;

#exec AUDIO IMPORT FILE="Sounds\Pickups\AmmoPickup_4.WAV" NAME="AmmoPick" GROUP="Pickups"

defaultproperties
{
	PickupMessageClass=class'Botpack.PickupMessagePlus'
    PickupSound=Sound'Botpack.Pickups.AmmoPick'
}
