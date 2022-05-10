//=============================================================================
// PuppetMimic.
//=============================================================================
class PuppetMimic expands PuppetWorker;

var(Puppet) name MimicBoneName;
var(Puppet) bool bMimicRotation;
var(Puppet) bool bRotationRelative;
var(Puppet) rotator MimicPreRotate;
var(Puppet) bool bMimicSequence;

defaultproperties
{
	MimicBoneName=Root
}
