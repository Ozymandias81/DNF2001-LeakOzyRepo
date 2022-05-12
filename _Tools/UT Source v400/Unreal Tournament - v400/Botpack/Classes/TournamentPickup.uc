//=============================================================================
// TournamentPickup.
//=============================================================================
class TournamentPickup extends Pickup;

function FireEffect();

function BecomeItem()
{
	local Bot B;
	local Pawn P;

	Super.BecomeItem();

	if ( Instigator.IsA('Bot') || Level.Game.bTeamGame || !Level.Game.IsA('DeathMatchPlus')
		|| DeathMatchPlus(Level.Game).bNoviceMode
		|| (DeathMatchPlus(Level.Game).NumBots > 4) )
		return;

	// let high skill bots hear pickup if close enough
	for ( P=Level.PawnList; P!=None; P=P.NextPawn )
	{
		B = Bot(p);
		if ( (B != None)
			&& (VSize(B.Location - Instigator.Location) < 800 + 100 * B.Skill) )
		{
			B.HearPickup(Instigator);
			return;
		}
	}
}

defaultproperties
{
	M_Activated=""
    M_Selected=""
    M_Deactivated=""
	ItemMessageClass=class'Botpack.ItemMessagePlus'
	PickupMessageClass=class'Botpack.PickupMessagePlus'
}
