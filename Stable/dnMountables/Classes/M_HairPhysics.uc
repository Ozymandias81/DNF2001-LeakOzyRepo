//=============================================================================
//	M_HairPhysics
//	Author: John Pollard
//=============================================================================
class M_HairPhysics expands M_Hair;

// Struct defs
struct AxisConstraint
{
	var() float	Pos;
	var() float	Neg;
};

struct BoneInfo
{
	var int					Index;
	var vector				Origin;
	var bool				bUseConstraint;
	var AxisConstraint		Constraints[3];
};

struct BoneConstraint
{
	var() name				BoneName;
	var() AxisConstraint	XConstraint;
	var() AxisConstraint	YConstraint;
	var() AxisConstraint	ZConstraint;
};

// Globals
var BoneInfo	Bones[33];
var int			NumBones;
var int			NumBoneChains;
var	vector		LastLocation;

// Bone affector parameters
var(HairParameters) float	HairTightness	?("How tight the hair is when it stretches.");
var(HairParameters) float	ConstrainAll	?("How far hair can move.");
var(HairParameters) float	Sensitivity		?("Scale of hair movement.");
var(HairParameters) vector	OtherForce		?("Outside force (like gravity)");

var(HairParameters)	AxisConstraint	XConstraint ?("Positive/Negative constraint on the X Axis.");
var(HairParameters)	AxisConstraint	YConstraint ?("Positive/Negative constraint on the Y Axis.");
var(HairParameters)	AxisConstraint	ZConstraint ?("Positive/Negative constraint on the Z Axis.");

var(HairParameters) BoneConstraint	BoneConstraints[16];		// Constrain up to 16 bones

var					AxisConstraint	Constraints[3];
var					vector			ConstraintAxis[3];

var transient bool	bBonesInitialized;

//=============================================================================
//	PostBeginPlay
//=============================================================================
simulated function PostBeginPlay()
{
	Super.PostBeginPlay();
	Enable( 'Tick' );
}

//=============================================================================
//	SetupBones
//=============================================================================
function SetupBones()
{
	local int i, j, Count;

	NumBoneChains = 0;

	// Get the mesh instance.
	GetMeshInstance();
	
	if (MeshInstance == None)
		return;

	// Get the root bone
	Bones[0].Index = MeshInstance.BoneFindNamed('ROOT');

	if (Bones[0].Index == 0)
		return;			// We will assume this is not a physics hair if no ROOT bone defined

	NumBoneChains = MeshInstance.BoneGetChildCount(Bones[0].Index);

	if (NumBoneChains > 16)			// (33-1)/2
		NumBoneChains = 16;

	// Get the kids
	for (i=0; i< NumBoneChains; i++)
	{
		Bones[i*2+1].Index = MeshInstance.BoneGetChild(Bones[0].Index, i);
		Bones[i*2+2].Index = MeshInstance.BoneGetChild(Bones[i*2+1].Index, 0);
	}
	
	NumBones = NumBoneChains*2+1;

	for (i=0; i<NumBones; i++)
	{
		Bones[i].Origin = MeshInstance.BoneGetTranslate(Bones[i].Index, true, false );
		Bones[i].bUseConstraint = false;
	}

	// Build constrain info
	Constraints[0] = XConstraint;
	Constraints[1] = YConstraint;
	Constraints[2] = ZConstraint;

	ConstraintAxis[0] = vect(1,0,0);
	ConstraintAxis[1] = vect(0,1,0);
	ConstraintAxis[2] = vect(0,0,1);

	// Build per bone constrain info
	for (i=0; i< 16; i++)
	{
		if (BoneConstraints[i].BoneName == '')
			continue;

		// Find the bone in the list, and set it up
		for (j=0; j<NumBones; j++)
		{
			if (MeshInstance.BoneGetName(Bones[j].Index) == BoneConstraints[i].BoneName)
				break;		// Found it
		}

		if (j == NumBones)
			continue;

		// Got it
		Bones[j].bUseConstraint = true;
		Bones[j].Constraints[0] = BoneConstraints[i].XConstraint;
		Bones[j].Constraints[1] = BoneConstraints[i].YConstraint;
		Bones[j].Constraints[2] = BoneConstraints[i].ZConstraint;
	}
	
	//LastLocation = Owner.Location;
	LastLocation = MeshInstance.MeshToWorldLocation(Bones[NumBones-1].Origin);

	Enable( 'Tick' );
}

//=============================================================================
//	VectorWorldToMesh
//	Hacky way to rotate a vector into mesh space
//=============================================================================
function vector VectorWorldToMesh(vector In)
{
	local vector	Origin;

	//Owner.GetMeshInstance();

	Origin = vect(0,0,0);

	// Transform the end points of the vector
	Origin = MeshInstance.WorldToMeshLocation(Origin);
	In = MeshInstance.WorldToMeshLocation(In);
	//Origin = Owner.MeshInstance.WorldToMeshLocation(Origin);
	//In = Owner.MeshInstance.WorldToMeshLocation(In);
	
	return (In - Origin);	// Convert the endpoints into a new vector in the new space
}

//=============================================================================
//	VectorMeshToWorld
//	Hacky way to rotate a vector into world space
//=============================================================================
function vector VectorMeshToWorld(vector In)
{
	local vector	Origin;

	Origin = vect(0,0,0);

	// Transform the end points of the vector
	Origin = MeshInstance.MeshToWorldLocation(Origin);
	In = MeshInstance.MeshToWorldLocation(In);
	
	return (In - Origin);	// Convert the endpoints into a new vector in the new space
}

//=============================================================================
//	Tick
//=============================================================================
simulated function Tick(float Delta)
{
	local vector	NewLocation;
	local vector	Dir, DirToUse;
	local float		Dist;
	local rotator	r;
	local int		i, j;
	local vector	t, t2;
	local float		d;

	if (!bBonesInitialized)
	{
		SetupBones();
		bBonesInitialized = true;
	}

	if (NumBoneChains == 0)
		return;

	// Get the mesh instance.
	GetMeshInstance();
	
	if ( MeshInstance == None )
		return;

	// Call super.
	Super.Tick( Delta );

	//NewLocation = Owner.Location;
	NewLocation = MeshInstance.MeshToWorldLocation(Bones[NumBones-1].Origin);

	//Dir = NewLocation - LastLocation;
	Dir = LastLocation - NewLocation;		// Get a vector looking at the old position

	LastLocation = NewLocation;
	
	Dir += OtherForce;

	// Rotate the direction into mesh space
	Dir = VectorWorldToMesh(Dir);

	DirToUse = vect(0,0,0);

	// Apply constraints
	for (i=0; i<3; i++)
	{
		Dist = Dir dot ConstraintAxis[i];

		if (Dist > 0.0)
			DirToUse += ConstraintAxis[i]*FMin(Dist, Constraints[i].Pos);
		else if (Dist < 0.0)
			DirToUse -= ConstraintAxis[i]*FMin((-Dist), Constraints[i].Neg);
	}

	Dir = DirToUse*Sensitivity;

	//BroadcastMessage("Dir = "@Dir);

	Dist = VSize(Dir);

	if (Dist > ConstrainAll)
	{
		Dir /= Dist;
		Dir *= ConstrainAll;
	}

	for (i=1; i<NumBones; i++)
	{
		if (Bones[i].Index == 0)
			continue;

		// Get the absolute position of the bone in mesh space
		t = MeshInstance.BoneGetTranslate(Bones[i].Index, true, false );

		// Apply per bone contraint if needed
		if (Bones[i].bUseConstraint)
		{
			DirToUse = vect(0,0,0);
			
			// Apply per bone constraint
			for (j=0; j<3; j++)
			{
				Dist = Dir dot ConstraintAxis[j];

				if (Dist > 0.0)
					DirToUse += ConstraintAxis[j]*FMin(Dist, Bones[i].Constraints[j].Pos);
				else if (Dist < 0.0)
					DirToUse -= ConstraintAxis[j]*FMin((-Dist), Bones[i].Constraints[j].Neg);
			}
		}
		else
			DirToUse = Dir;
		
		// Apply dir to bone
		if ((i & 1) != 0)
			t += DirToUse*Delta*75.0*0.30;
		else
			t += DirToUse*Delta*75.0;

		// Slowly move back to the original bone location... (kind of like a rubberband or spring effect)
		t += (Bones[i].Origin - t)*HairTightness*Delta*75.0;	

		// Finally, set the bone position
		MeshInstance.BoneSetTranslate(Bones[i].Index, t, true);
	}
}

//=============================================================================
//	defaultproperties
//=============================================================================
defaultproperties
{
	// These numbers were just tinkered with till they looked good for most hair models
	HairTightness=0.108

	ConstrainAll=0.37
	
	Sensitivity=1.1

	XConstraint=(Pos=0.37f,Neg=0.37f)
	YConstraint=(Pos=0.36f,Neg=0.36f)
	ZConstraint=(Pos=0.12f,Neg=0.02f)

	OtherForce=(X=0,Y=0,Z=-0.50)
	
	bBonesInitialized=false
}