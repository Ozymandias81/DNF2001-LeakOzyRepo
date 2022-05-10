//=============================================================================
// PuppetStretch.
//=============================================================================
class PuppetStretch expands PuppetWorker;

var(Puppet) name StretchBoneName;
var actor StretchEnd;
var(Puppet) name StretchEndTag;
var(Puppet) float StretchFactor;
var(Puppet) rotator StretchOrient;
var(Puppet) vector StretchMeshOffset;
var(Puppet) vector StretchWorldOffset;

defaultproperties
{
	StretchBoneName=End
	StretchFactor=1.000000
}
