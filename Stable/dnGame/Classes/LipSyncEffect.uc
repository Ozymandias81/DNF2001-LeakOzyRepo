//=============================================================================
// LipSyncEffect. (CDH)
// Performs a lip-sync on the mouth bones of the actor based on monitored sound.
// Geared for humanoids; assumes the common humanoid bone layout is in use.
//=============================================================================
class LipSyncEffect extends MeshEffect;

var() name JawBoneName;
var() name MouthCornerBoneName;
var() name UpperLipBoneName;
var() name LowerLipBoneName;

simulated function SetInfo(int channel, actor a, MeshEffect inTemplate)
{
	local LipSyncEffect inf;
	inf = LipSyncEffect(inTemplate);
	if (inf == None)
		return;

	JawBoneName = inf.JawBoneName;
	MouthCornerBoneName = inf.MouthCornerBoneName;
	UpperLipBoneName = inf.UpperLipBoneName;
	LowerLipBoneName = inf.LowerLipBoneName;
}

simulated function EvalBones(int channel, actor a)
{
    local int bone;
    local MeshInstance minst;
	local rotator r;
    local vector s, t;
	local float f;
    minst = a.GetMeshInstance();
    if (minst==None)
        return;

    // rotate the jaw downward
	bone = minst.BoneFindNamed(JawBoneName);
	if (bone==0)
		return;	
    r = minst.BoneGetRotate(bone, false);
	r.Pitch = a.MonitorSoundLevel * -2048.0;
	minst.BoneSetRotate(bone, r, false);

	// scale in the mouth corner a bit
    bone = minst.BoneFindNamed(MouthCornerBoneName);
	if (bone==0)
		return;	
	f = 1.0 - a.MonitorSoundLevel * 2.0;
    s.x = f; s.y = f; s.z = f;
    minst.BoneSetScale(bone, s, true);

	// move the upper lip up a little
    bone = minst.BoneFindNamed(UpperLipBoneName);
    if (bone==0)
        return;
    t = minst.BoneGetTranslate(bone, false, true);
	t.x += 0.25 * a.MonitorSoundLevel;
	minst.BoneSetTranslate(bone, t, false);

	// same with the lower lip
    bone = minst.BoneFindNamed(LowerLipBoneName);
    if (bone==0)
        return;
    t = minst.BoneGetTranslate(bone, false, true);
	t.x += -0.5 * a.MonitorSoundLevel;
	minst.BoneSetTranslate(bone, t, false);
}

defaultproperties
{
    bAffectsBones=True
	JawBoneName=Jaw
	MouthCornerBoneName=MouthCorner
	UpperLipBoneName=Lip_U
	LowerLipBoneName=Lip_L
}
