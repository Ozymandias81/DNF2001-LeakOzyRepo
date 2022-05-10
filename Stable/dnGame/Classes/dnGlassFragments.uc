//=============================================================================
//	dnGlassFragments
//	Author: John Pollard
//=============================================================================
class dnGlassFragments expands InfoActor;

var() sound				FootStepSounds[3];
var() int				PlayerDamage;

var dnBreakableGlass	GlassOwner;
var int					LastSoundIndex;

#exec OBJ LOAD FILE=..\Sounds\dnsMaterials.dfx

//=============================================================================
//	PlayRandomFootStepSound
//=============================================================================
simulated function PlayRandomFootStepSound(Pawn Instigator)
{
	local int	Index;

	Index = Rand(3);

	if (Index == LastSoundIndex)
	{
		Index++;
		if (Index > 2)
			Index = 0;
	}

	Instigator.PlaySound(FootStepSounds[Index], SLOT_Misc, 2.0, false, 1000.0f, 1.0f);

	LastSoundIndex = Index;
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	FootStepSounds(0)=sound'dnsMaterials.GlassSteps.FtStepGlass01'
	FootStepSounds(1)=sound'dnsMaterials.GlassSteps.FtStepGlass05'
	FootStepSounds(2)=sound'dnsMaterials.GlassSteps.FtStepGlass06a'

	CollisionRadius=50.0f
	CollisionHeight=50.0f
	bCollideActors=true;
	bBlockPlayers=false;
	bBlockActors=false;
	DrawType=DT_None;
	LastSoundIndex=-1;
}
