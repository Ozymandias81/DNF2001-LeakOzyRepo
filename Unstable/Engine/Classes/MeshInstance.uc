//=============================================================================
// MeshInstance. (CDH)
// Runtime "instances" of a mesh associated with an actor.
//=============================================================================
class MeshInstance extends Primitive
    native
    noexport
    transient;

// Mesh animation channel structure
struct MeshChannel
{
	var bool bAnimFinished; // Unlooped animation sequence has finished.
	var bool bAnimLoop; // Whether animation is looping.
	var bool bAnimNotify; // Whether a notify is applied to the current sequence.
	var bool bAnimBlendAdditive; // Animation uses additive rather than absolute blending.
	var() name AnimSequence; // Animation sequence we're playing.
	var() float AnimFrame; // Current animation frame, 0.0 to 1.0.
	var() float AnimRate; // Animation rate in frames per second, 0=none, negative=velocity scaled.
	var() float AnimBlend; // Animation blending factor.
	var float TweenRate; // Tween-into rate.
	var float AnimLast; // Last frame.
	var float AnimMinRate; // Minimum rate for velocity-scaled animation.
	var float OldAnimRate; // Animation rate of previous animation ( =AnimRate until animation completes).
	var plane SimAnim; // Replicated to simulated proxies.
	var MeshEffect MeshEffect; // Mesh effect actor, none for normal sequences
};

// DNF mesh animation channels
// Channels 1-15 are used as additional animation channels for applicable meshes
// Channel 0 is copied from the actor's animation data and should not be altered directly.
var MeshChannel MeshChannels[16];

native final function vector MeshToWorldLocation(vector v, optional bool bFromStd);
native final function vector WorldToMeshLocation(vector v, optional bool bToStd);
native final function rotator MeshToWorldRotation(rotator r);
native final function rotator WorldToMeshRotation(rotator r);

native final function int BoneFindNamed(name BoneName);
native final function name BoneGetName(int Bone);
native final function int BoneGetParent(int Bone);
native final function int BoneGetChildCount(int Bone);
native final function int BoneGetChild(int Bone, int ChildIndex);
native final function vector BoneGetTranslate(int Bone, optional bool bAbsolute, optional bool bDefault, optional float fScale);
native final function rotator BoneGetRotate(int Bone, optional bool bAbsolute, optional bool bDefault);
native final function vector BoneGetScale(int Bone, optional bool bAbsolute, optional bool bDefault);
native final function bool BoneSetTranslate(int Bone, vector T, optional bool bAbsolute);
native final function bool BoneSetRotate(int Bone, rotator R, optional bool bAbsolute, optional bool bRelCurrent);
native final function bool BoneSetScale(int Bone, vector S, optional bool bAbsolute);
native final function GetBounds( out Vector mins, out Vector maxs );