class SpecialDecoration extends dnDecoration;

var() name FaceAnim;
var float DesiredFaceAnimBlend, FaceAnimBlend, FaceAnimBlendRate;

function PostBeginPlay()
{
	PlayFaceAnim( FaceAnim,, 0.1, true );
	Super.PostBeginPlay();
}

function PlayFaceAnim( name Sequence, optional float Rate, optional float TweenTime, optional bool bLooping )
{
	GetMeshInstance();
	if (MeshInstance==None)
		return;
	if ((MeshInstance.MeshChannels[5].AnimSequence == Sequence)
	 && ((Sequence=='None') || (IsAnimating(5))))
		return; // already playing

	if (Sequence=='None')
	{
		DesiredFaceAnimBlend = 1.0;
		FaceAnimBlend = 0.0;
		if (TweenTime == 0.0)
			FaceAnimBlendRate = 5.0;
		else
			FaceAnimBlendRate = 0.5 / TweenTime;
		return; // don't actually play the none anim, we want to shut off the channel gradually, the ticking will set it to none later
	}
	else if (MeshInstance.MeshChannels[5].AnimSequence=='None')
	{
		DesiredFaceAnimBlend = 0.0;
		FaceAnimBlend = 1.0;
		if (TweenTime == 0.0)
			FaceAnimBlendRate = 5.0;
		else
			FaceAnimBlendRate = 0.5 / TweenTime;
	}
	else
	{
		FaceAnimBlend = 0.0;
		DesiredFaceAnimBlend = 0.0;
		FaceAnimBlendRate = 1.0;
	}
	
	if (Rate == 0.0) Rate = 1.0; // default
	if (TweenTime == 0.0) TweenTime = -1.0; // default

	if (bLooping)
		LoopAnim(Sequence, Rate, TweenTime,, 5);
	else
		PlayAnim(Sequence, Rate, TweenTime, 5);
}

