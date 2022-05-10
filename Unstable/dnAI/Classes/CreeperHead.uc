class CreeperHead extends dnDecoration;

function bool OnEvalBones( int Channel )
{
	local MeshInstance Minst;
	local int bone;

	Minst = GetMeshInstance();
	bone = Minst.BoneFindNamed( 'Root' );

	Minst.BoneSetScale( bone, vect( 0, 0, 0 ), true );
	bone = Minst.BoneFindNamed( 'Head' );
	Minst.BoneSetScale( bone, vect( 1, 1, 1 ), true );

	EvalEyesShut();
}


simulated function bool EvalEyesShut()
{
	local int bone;
	local vector BlinkEyelidPosition;
	local vector t;
	local MeshInstance Minst;

	Minst = GetMeshInstance();
	
	bone = minst.BoneFindNamed('Pupil_L');
	if (bone!=0)
		minst.bonesetscale( bone, vect( 0, 0, 0 ), false );
	bone = minst.BoneFindNamed('Pupil_R');
	if (bone!=0)
		minst.bonesetscale( bone, vect( 0, 0, 0 ), false );		
	return false;
}

function PostBeginPlay()
{
	PlayAllAnim( 'A_HeadCreepIdleA',, 0.1, true );
}

function PlayAllAnim(name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping)
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;

	if ((MeshInstance.MeshChannels[0].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(0))))
		return; // already playing
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime);
	else
		PlayAnim(Sequence, Rate, TweenTime);
}

DefaultProperties
{
	Mesh=DukeMesh'c_characters.NPC_M_OldA'
	DrawType=DT_Mesh
	bCollideActors=false
	CollisionHeight=0.000000
	Collisionradius=0.000000
}