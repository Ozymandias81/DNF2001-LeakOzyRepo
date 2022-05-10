/*-----------------------------------------------------------------------------
	DecorativeCorpse
	Author: Brandon Reinhart
-----------------------------------------------------------------------------*/
class DecorativeCorpse extends HumanPawnCarcass;

var() bool				bLoopExpression;
var() bool				bBlownUp;
var() bool				bGibGenerator;

var() EFacialExpression FacialExpression;

function PostBeginPlay()
{

    local int bone;
	local vector newloc, v;
	local MeshInstance minst;
	local float OldCollisionHeight;

	Super.PostBeginPlay();

	if (bGibGenerator)
		return;

	//SetFacialExpression( FacialExpression );

	minst = GetMeshInstance();
	Minst.MeshChannels[ 5 ].bAnimLoop = bLoopExpression;
	Minst.MeshChannels[ 5 ].TweenRate = 0.1;

	if( FacialExpression == FACE_Clenched )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Clench1';
	else if( FacialExpression == FACE_Roar )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Roar1';
	else if( FacialExpression == FACE_Frown )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Frown1';
	else if( FacialExpression == FACE_AngrySmile )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_SmileA1';
	else if( FacialExpression == FACE_HappySmile )
		Minst.MeshChannels[ 5 ].AnimSEquence = 'F_SmileH1';
	else if( FacialExpression == FACE_Sneer )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Sneer1';
	else if( FacialExpression == FACE_Surprise )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Surprise1';
	else if( FacialExpression == FACE_Pain1 )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Pain1';
	else if( FacialExpression == FACE_Pain2 )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Pain2';
	else if( FacialExpression == FACE_Breathe1 )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Breathe1';
	else if( FacialExpression == FACE_Breathe2 )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Breathe2';
	else if( FacialExpression == FACE_Scared1 )
		Minst.MeshChannels[ 5 ].AnimSequence = 'F_Scared1';

	if (bRandomName)
		ItemName = Level.Game.GetRandomName()$"'s Corpse";

	SetPhysics(PHYS_None);

	bCollideWorld = false;

	// Get the abdomen's location, ignore Z.
    bone = minst.BoneFindNamed('Shin_L');
	v = minst.BoneGetTranslate(bone, true, false);
	v = minst.MeshToWorldLocation(v);
	v = Location - v;
	v.z = 0;

	// Offset the prepivot by the abdomen's location.
	PrePivot += v;

	// Adjust our collision width to the previous height.
	OldCollisionHeight = CollisionHeight;
	SetCollisionSize( CollisionHeight + CollisionHeight*0.5, 10 );

	// Adjust the location for the change.
	newloc = Location;
	newloc.Z -= OldCollisionHeight - 10;
	newloc -= v;
	SetLocation(newloc);
}

function Trigger( actor Other, pawn EventInstigator )
{
	local bool bTotalChunks;
    local int bone, chestbone, pelvisbone;
	local float chestdist, pelvisdist;
	local vector v, RandDir;
	local humanmeshchunk hmc;

	if ((bBlownUp) && (!bGibGenerator))
		return;
	bBlownUp = true;

	// Blow up the top half!
	GetMeshInstance();
	if (MeshInstance == none)
		return;

	if (Level.NetMode != NM_DedicatedServer)
	{
		// Spawn a few nasty effects.
		if ( !bSteelSkin )
		{
			spawn(class'dnParticles.dnBloodFX_BloodHaze');
			spawn(class'dnParticles.dnBloodFX_BloodChunks');
		} else
			spawn(class'dnParticles.dnRobotGibFX_MachineChunks');

		// Play the gib sound.
		GibSound();

		// Create a shower of gibs.
		SpawnGibShower(Location);

		TrashedBones[5] = MeshInstance.BoneFindNamed('Chest');
	}
}

defaultproperties
{
	bDecorative=true
	bBloodPool=false
	bSearchable=true
	bUseTriggered=true
	CollisionRadius=17.0
	CollisionHeight=39.0
	AnimSequence=A_Death_HitRShoulder
}
