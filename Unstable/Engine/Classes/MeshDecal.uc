//=============================================================================
// MeshDecal.
//=============================================================================
class MeshDecal expands RenderActor
	native
	transient;

struct MeshDecalTri
{
    var int TriIndex;
    var float TexU[3];
    var float TexV[3];
};

var native texture Texture; // texture this decal is rendered with
var native actor Actor; // actor this decal is applied to
var native mesh Mesh; // actor mesh at the time of building
var private native const array<MeshDecalTri> Tris; // generated triangle array

var unbound int GrowTriIndex;
var unbound vector GrowBaryCenter;
var unbound float GrowRollRadians;
var unbound float GrowDimU;
var unbound float GrowDimV;
var unbound float GrowDuration;
var unbound float GrowScaleAmount;

//=============================================================================
native simulated final function int BuildDecal(actor inActor, texture inTexture,
    int inTriIndex, vector inBaryCenter, float inRollRadians, float inDimU, float inDimV);

//=============================================================================

simulated function int BuildDecalGrowable(actor inActor, texture inTexture,
    int inTriIndex, vector inBaryCenter, float inRollRadians, float inDimU, float inDimV,
    float inGrowDuration, float inGrowScaleAmount)
{
	local int result;

	result = BuildDecal(inActor, inTexture, inTriIndex, inBaryCenter, inRollRadians, inDimU, inDimV);	
	GrowTriIndex = inTriIndex;
	GrowBaryCenter = inBaryCenter;
	GrowRollRadians = inRollRadians;
	GrowDimU = inDimU;
	GrowDimV = inDimV;

	GrowDuration = inGrowDuration;
	GrowScaleAmount = inGrowScaleAmount;

	return(result);
}

// link to new actor dynamically, in priority order
simulated function DecalAttachToActor(actor inActor)
{
	local int i;
	local meshdecal decalTemp;

	// detach from existing dynamic owner if there is one
	if (Actor != None)
	{
		if (Actor.MeshDecalLink == self)
		{
			Actor.MeshDecalLink = MeshDecalLink;
		}
		else
		{
			decalTemp = Actor.MeshDecalLink;
			if (decalTemp != None)
			{
				while (decalTemp.MeshDecalLink != None)
				{
					if (decalTemp.MeshDecalLink == self)
					{
						decalTemp.MeshDecalLink = MeshDecalLink;
						break;
					}
					decalTemp = decalTemp.MeshDecalLink;
				}
			}
		}
		Actor = None;
	}

	// if the new actor is none, we're done
	if (inActor == None)
		return;
	
	Actor = inActor;
	
	// if there are already too many decals on the actor, remove the oldest
	i = 0;
	for (decalTemp=Actor.MeshDecalLink; decalTemp!=None; decalTemp=decalTemp.MeshDecalLink)
	{
		if (i >= 32)
			break;
		i++;
	}
	if (decalTemp!=None)
		decalTemp.DecalAttachToActor(None);

	// attach to actor
	MeshDecalLink = Actor.MeshDecalLink;
	Actor.MeshDecalLink = self;
	/*
	if (Actor.MeshDecalLink == None)
	{
		MeshDecalLink = Actor.MeshDecalLink;
		Actor.MeshDecalLink = self;
	}
	else
	{
		decalTemp = Actor.MeshDecalLink;
		while ((decalTemp.MeshDecalLink != None) && (decalTemp.MeshDecalLink.DecalPriority <= DecalPriority))
			decalTemp = decalTemp.MeshDecalLink;
		MeshDecalLink = decalTemp.MeshDecalLink;
		decalTemp.MeshDecalLink = self;
	}
	*/
}
simulated function PostBeginPlay()
{	
	Super.PostBeginPlay();
	LifeSpan = 15.0;
}
simulated function Destroyed()
{
	DecalAttachToActor(None);
	Super.Destroyed();
}
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	if (GrowDuration <= 0.0)
		return;
	
	GrowDuration -= DeltaTime;
	GrowDimU += GrowScaleAmount*DeltaTime;
	GrowDimV += GrowScaleAmount*DeltaTime;
	
	BuildDecal(Actor, Texture, GrowTriIndex, GrowBaryCenter, GrowRollRadians, GrowDimU, GrowDimV);
}

defaultproperties
{
    bHidden=true
	RemoteRole=ROLE_None
}
