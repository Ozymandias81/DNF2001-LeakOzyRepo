//=============================================================================
// BoneStretchEffect. (CDH)
// Stretchs a bone's translational origin to a target point in the world.
//=============================================================================
class BoneStretchEffect extends MeshEffect;

var() name StretchBoneName;
var actor StretchEnd;
var() name StretchEndTag;
var() float StretchFactor;
var() rotator StretchOrient;
var() vector StretchMeshOffset;
var() vector StretchWorldOffset;

simulated function SetInfo(int channel, actor a, MeshEffect inTemplate)
{
	local BoneStretchEffect inf;
	inf = BoneStretchEffect(inTemplate);
	if (inf == None)
		return;

    StretchBoneName = inf.StretchBoneName;
    StretchEndTag = inf.StretchEndTag;
    StretchFactor = inf.StretchFactor;
    StretchOrient = inf.StretchOrient;
    StretchMeshOffset = inf.StretchMeshOffset;
    StretchWorldOffset = inf.StretchWorldOffset;
}

simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst, endMinst;
    local vector t, tempOfs;
    minst = a.GetMeshInstance();
    if (minst==None)
        return;

	if (StretchBoneName=='None')
		return;
	if (StretchEnd==None)
	{
		StretchEnd = FindActorTagged(class'Actor', StretchEndTag);
		if (StretchEnd==None)
			return;
	}

	bone = minst.BoneFindNamed(StretchBoneName);
	if (bone==0)
		return;
	tempOfs = StretchWorldOffset;
	endMinst = StretchEnd.GetMeshInstance();
	if (endMinst!=None)
		tempOfs += endMinst.MeshToWorldLocation(StretchMeshOffset) - StretchEnd.Location;
	t = minst.WorldToMeshLocation(StretchEnd.Location + tempOfs);
	minst.BoneSetTranslate(bone, t, true);
}

defaultproperties
{
    bAffectsBones=True
	StretchBoneName=End
	StretchFactor=1.000000
}
