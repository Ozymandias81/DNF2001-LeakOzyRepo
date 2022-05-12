//=============================================================================
// MaleOneBot.
//=============================================================================
class MaleOneBot extends MaleBot;

#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\male\metal01.WAV" NAME="metwalk1" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\male\metal02.WAV" NAME="metwalk2" GROUP="Male"
#exec AUDIO IMPORT FILE="..\UnrealShare\Sounds\male\metal03.WAV" NAME="metwalk3" GROUP="Male"

function ForceMeshToExist()
{
	Spawn(class'MaleOne');
}

function BeginPlay()
{
	Super.BeginPlay();
}

simulated function PlayMetalStep()
{
	local sound step;
	local float decision;

	if ( !bIsWalking && (Level.Game != None) && (Level.Game.Difficulty > 1) && ((Weapon == None) || !Weapon.bPointing) )
		MakeNoise(0.05 * Level.Game.Difficulty);
	if ( FootRegion.Zone.bWaterZone )
	{
		PlaySound(sound 'LSplash', SLOT_Interact, 0.5, false, 1500.0, 1.0);
		return;
	}

	decision = FRand();
	if ( decision < 0.34 )
		step = sound'MetWalk1';
	else if (decision < 0.67 )
		step = sound'MetWalk2';
	else
		step = sound'MetWalk3';

	if ( bIsWalking )
		PlaySound(step, SLOT_Interact, 0.5, false, 400.0, 1.0);
	else 
		PlaySound(step, SLOT_Interact, 1, false, 1000.0, 1.0);
}

defaultproperties
{
     Mesh=Male1
     Skin=Texture'Unreali.Kurgan'
	 CarcassType=MaleOneCarcass
}
