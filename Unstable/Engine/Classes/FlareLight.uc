//=============================================================================
// FlareLight.
//=============================================================================
class FlareLight expands Light
	native;

// Lens flare.

var() struct native LensFlare
{
	var () texture FlareTexture;
	var () float   Offset;
	var () float   Scale;
	
	// Number of additional copies of this flare to draw at incremental rotations from the current.
	var () int     AdditionalCopies;  

	// Amount this flare rotates relative to it's distance from the light source in screen space.
	var () float   RotationFactor;
	var () float   RotationVelocity;	 // Rotational velocity.

	var () float   DistanceScaleFactor;

	// Managing scaling based off the inner/outer radii:
	var () float   OriginScale;
	var () float   InnerRadiusScale;
	var () float   OuterRadiusScale;

	var () bool    UseCone;

} LensFlares[16];

var() float InnerRadius;
var() float OuterRadius;
var() bool  ActorsBlock;
var() bool  MeshAccurate;

defaultproperties
{
	bCorona=TRUE
	InnerRadius=20.0
	OuterRadius=40.0
    Skin=S_Light
}
