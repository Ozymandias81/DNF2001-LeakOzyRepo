//=============================================================================
// MimicRotationEffect. (CDH)
// Sets the rotation of a bone to mimic the rotation of another actor.
//=============================================================================
class MimicRotationEffect extends MeshEffect;

var() name MimicSourceTag;
var actor MimicSourceActor;
var() bool bMimicRotationRelative;
var() name MimicBoneName;
var() rotator MimicPreRotate;
var() bool bMimicRelativeToSelfDefault;

// Mimic by rotation instead of a bone.
var actor AffectedActor;
var() bool bMimicRotation;

simulated function PostBeginPlay()
{
	Super.PostBeginPlay();

	if ( bMimicRotation )
		Enable( 'Tick' );
	else
		Disable( 'Tick' );
}

simulated function SetInfo(int channel, actor a, MeshEffect inTemplate)
{
	local MimicRotationEffect inf;
	inf = MimicRotationEffect(inTemplate);
	if (inf == None)
		return;

	AffectedActor = a;
    MimicSourceTag = inf.MimicSourceTag;
    bMimicRotationRelative = inf.bMimicRotationRelative;
    MimicBoneName = inf.MimicBoneName;
    MimicPreRotate = inf.MimicPreRotate;
    bMimicRelativeToSelfDefault = inf.bMimicRelativeToSelfDefault;
	bMimicRotation = inf.bMimicRotation;
}

simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst;
    local rotator r;

	if ( bMimicRotation )
		return;

    minst = a.GetMeshInstance();
    if (minst==None)
        return;

	FindSourceActor();

	bone = minst.BoneFindNamed(MimicBoneName);
	if (bone==0)
		return;
	if (bMimicRelativeToSelfDefault)
	{
		r = minst.BoneGetRotate(bone, false, true);
		minst.BoneSetRotate(bone, r, false);
	}
	r = MimicSourceActor.Rotation;
	r += MimicPreRotate;
	minst.BoneSetRotate(bone, r, !bMimicRotationRelative, bMimicRelativeToSelfDefault);
}

simulated function Tick( float Delta )
{
    local rotator r;

	if ( !bMimicRotation )
		return;

	FindSourceActor();

	r = MimicSourceActor.Rotation;
	r += MimicPreRotate;
	AffectedActor.SetRotation( r );
}

simulated function FindSourceActor()
{
	if ( MimicSourceActor == None )
	{
		if ( MimicSourceTag == 'None' )
            MimicSourceActor = self;
        else
        {
            MimicSourceActor = FindActorTagged( class'Actor', MimicSourceTag );
		    if ( MimicSourceActor == None )
			    return;
        }
	}
}

defaultproperties
{
    bAffectsBones=True
}
