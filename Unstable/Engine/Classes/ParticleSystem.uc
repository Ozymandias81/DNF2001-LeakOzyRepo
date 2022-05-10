//=============================================================================
// ParticleSystem. 
// Base of the particle system goodness
// - FIXME need to change name to represent the fact that beam systems are now based
// off of this as well.
//=============================================================================
class ParticleSystem expands RenderActor
	native;

var () bool BSPOcclude	?("Whether to use the BSP to occlude the particle or beam system.");

var () enum EZBufferMode
{
	ZBM_Occlude,		// Particles both read and write from the Z buffer (default)
	ZBM_ReadOnly,		// Particles only read from the Z buffer.  They will not occlude things behind them
	ZBM_None 			// Particles don't interact with the Z buffer
} ZBufferMode;

var () float ZBias;	// Must be between 0 and 16

var () float SystemAlphaScale				?("Amount to scale the alpha of the entire system.");	
var () float SystemAlphaScaleVelocity		?("Rate at which SystemAlphaScale changes.");
var () float SystemAlphaScaleAcceleration	?("Rate at which SystemAlphaAcceleration changes.");
var () float AlphaVariance 					?("+/- this amount of alpha.");
var () float AlphaStart 					?("Initial alpha.");
var () float AlphaMid						?("Middle alpha.");
var () float AlphaEnd 						?("Ending alpha.");
var () float AlphaRampMid					?("Where during the lifetime the alpha should consider the middle.");
var () bool  AlphaStartUseSystemAlpha;
var () bool  bUseAlphaRamp					?("Whether or not to consider the mid value in alpha ramping.");
var () bool  SimulateInEditor				?("Attempt to simulate the particle/beam system in the editor.");

defaultproperties
{
	 BSPOcclude=True
	 ZBufferMode=ZBM_ReadOnly
	 ZBias=0.0
 	 AlphaStart=1.0
	 AlphaMid=0.0
	 AlphaEnd=1.0
	 AlphaRampMid=0.5
	 bUseAlphaRamp=false
 	 SystemAlphaScale=1.0	 
}