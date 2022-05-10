//=============================================================================
// PuppetReach.
//=============================================================================
class PuppetReach expands PuppetWorker;

var(Puppet) bool bExcludeParentLimit;
var(Puppet) bool bInitialRotate;
var(Puppet) bool bReachEndPlayer;
var transient bool bInitialized;
var(Puppet) name ReachBoneName;
var(Puppet) name ChildLimitBoneName, ParentLimitBoneName;
var actor ReachEnd;
var(Puppet) name ReachEndTag;
var(Puppet) float ReachAngleLimit;
var(Puppet) vector ReachOffsetPos;
var(Puppet) vector ReachVarianceAmp, ReachVarianceFreq;
var(Puppet) bool bStretchable;
var(Puppet) float StretchScale;
var transient float StretchFactor;

defaultproperties
{
	ReachBoneName=End
	ReachAngleLimit=30.000000
	ReachOffsetPos=(X=0.000000,Y=0.000000,Z=0.000000)
	ReachVarianceAmp=(X=0.000000,Y=0.000000,Z=0.000000)
	ReachVarianceFreq=(X=1.000000,Y=1.000000,Z=1.000000)
	bStretchable=False
	StretchScale=1.5
}
