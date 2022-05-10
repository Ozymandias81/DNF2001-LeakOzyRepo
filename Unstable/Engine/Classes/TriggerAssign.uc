//=============================================================================
// TriggerAssign. (NJS)
//
// 	When triggered, TriggerAssign will alter various properties of the objects
// referenced by it's 'Event'.  See the 'Public variables' section below for 
// more information.
//=============================================================================
class TriggerAssign expands Triggers;

#exec Texture Import File=Textures\TriggerAssign.pcx Name=S_TriggerAssign Mips=Off Flags=2

var () bool AssignInstigator;   // Apply these assignements to the instigator.

// Public Variables:
var () bool AssignEvent;		// Whether I should change my targets' 'Event'
var () name NewEvent;			// If above is true, what to change the event to.

var () bool AssignTag;			// Whether I should change my targets' 'Tag'
var () name NewTag;				// If the above is true, what to change the tag to.

// Please direct all hate mail to Keith for the AssignNewEvent and AssignNewTag :^)
var () bool AssignNewEvent;		// Whether I should change my targets' 'NewEvent'
var () name NewNewEvent;		// If above is true, what to change the NewEvent to.

var () bool AssignNewTag;		// Whether I should change my targets' 'NewTag'
var () name NewNewTag;			// If the above is true, what to change the NewTag to.

var () bool    AssignbNotTargetable;
var () bool    NewbNotTargetable;

var () bool AssignNewAcceleration;
var () vector NewAcceleration;

var () bool AssignNewCollisionRadius;
var () float NewCollisionRadius;

var () bool AssignNewCollisionHeight;
var () float NewCollisionHeight;

var () bool		AssignNewPhysics;
var () EPhysics NewPhysics;

var () bool		AssignNewRotationRate;
var () rotator	NewRotationRate;

var () bool     AssignVelocity;
var () vector   NewVelocity;

var (AssignLighting) name ValueVariable;
var (AssignLighting) bool AssignLightBrightness;
var (AssignLighting) byte NewLightBrightness;
var (AssignLighting) bool AssignLightHue;
var (AssignLighting) byte NewLightHue;
var (AssignLighting) bool AssignLightSaturation;
var (AssignLighting) byte NewLightSaturation;

var (AssignDisplay)	bool	AssignNewMesh;		// Whether I should change my targets' 'mesh'
var (AssignDisplay)	mesh 	NewMesh;			// If the above is true, what to change the mesh to.
var (AssignDisplay)	bool    AssignNewSkin;	// Whether I should change my targets' 'skin'
var (AssignDisplay)	texture NewSkin;			// If the above is true, what to change the mesh to.
var (AssignDisplay)	bool    AssignbUnlit;
var (AssignDisplay)	bool    NewbUnlit;
var (AssignDisplay)	bool  	AssignNewDrawScale;
var (AssignDisplay)	float 	NewDrawScale;
var (AssignDisplay)	bool	AssignNewStyle;
var (AssignDisplay) 	ERenderStyle NewStyle;

var (AssignDisplay)	float	NewScaleGlow;
var (AssignDisplay)	float	NewScaleGlowRampTime;
var (AssignDisplay)	bool	AssignScaleGlow;	

function Trigger( actor Other, pawn EventInstigator )
{
	local actor A;
	local Decoration D;
	local TriggerAssign TA;
	local byte lightVariable;
	
	if(AssignInstigator)
	{
		EventInstigator.Tag=NewTag;
	}

	if(ValueVariable!='')
	{
		lightVariable=GetVariableValue( ValueVariable );
		NewLightBrightness=lightVariable;
		NewLightHue=lightVariable;
		NewLightSaturation=lightVariable;
	}
	
	// Validate event:
	if( Event != '' )
		// Trigger all actors with matching tags:
		foreach AllActors( class 'Actor', A, Event )		
		{
			if(AssignEvent) 			A.Event=NewEvent;
			if(AssignTag)   			A.Tag=NewTag;
			if(AssignNewMesh) 			A.Mesh=NewMesh;
			if(AssignNewSkin)			A.Skin=NewSkin;
			if(AssignbUnlit)			A.bUnlit=NewbUnlit;
			if(AssignbNotTargetable)
			{
				if ( A.bIsRenderActor )
					RenderActor(A).bNotTargetable=NewbNotTargetable;
			}
			if(AssignVelocity)			A.velocity=NewVelocity;
			if(AssignNewAcceleration) A.Acceleration=NewAcceleration;
			if(AssignNewDrawScale)    A.DrawScale=NewDrawScale;
			if(AssignNewPhysics)		A.SetPhysics(NewPhysics);
			if(AssignNewRotationRate) { A.RotationRate=NewRotationRate; A.bFixedRotationDir=true; }

			TA=TriggerAssign(A);
			if(TA!=none)
			{
				if(AssignNewEvent) TA.NewEvent=NewNewEvent;
				if(AssignNewTag)   TA.NewTag=NewNewTag;
			}
			
			if(AssignLightBrightness) A.LightBrightness=NewLightBrightness;
			if(AssignLightHue)		  A.LightHue=NewLightHue;
			if(AssignLightSaturation) A.LightSaturation=NewLightSaturation;	
			
			if(AssignNewCollisionRadius) A.SetCollisionSize(NewCollisionRadius, CollisionHeight);
			if(AssignNewCollisionHeight) A.SetCollisionSize(CollisionRadius, NewCollisionHeight);		

			if(AssignNewStyle) A.Style=NewStyle;
		}

	// ScaleGlow modification. Currently only works on decorations, but will work on
	// all actors when Brandon or someone moves it over.
	if( Event != '' )
		// Trigger all actors with matching tags:
		foreach AllActors( class 'Decoration', D, Event )		
		{
			if(AssignScaleGlow)
			{
				if (NewScaleGlowRampTime == 0)
				{
					D.ScaleGlow = NewScaleGlow;
				}
				else 
				{
					if (D.ScaleGlow != NewScaleGlow) 
					{
						D.RampScaleGlow (NewScaleGlow, NewScaleGlowRampTime);
					}
				}
			}
		}

}

defaultproperties
{
     Texture=Texture'Engine.S_TriggerAssign'
}
