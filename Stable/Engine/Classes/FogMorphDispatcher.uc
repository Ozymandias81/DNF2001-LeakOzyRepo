//=============================================================================
// FogMorphDispatcher.
//=============================================================================
class FogMorphDispatcher expands Dispatchers;

var() color FogColor;
var() byte  FogDistance;	
var() float FogDensity;		
var() float InnerRadius;

var actor ThePlayer;		// Current player that touched this dispatcher.

function PostBeginPlay()
{
	Disable('Tick');
}

function Tick(float deltaTime)
{
	local vector Vector2d;
	local float alpha, length;
	local zoneinfo z;
		
	Vector2d=ThePlayer.Location-Location;
	Vector2d.z=0;
	length=sqrt(Vector2d.x*Vector2d.x+Vector2d.y*Vector2d.y);

	//PlayerPawn(ThePlayer).ClientMessage("Length:"$length$" Collision Radius:"$CollisionRadius);	
	z=ThePlayer.Region.Zone;

	if(length>CollisionRadius*1.10)
	{
		z.fogColor=z.originalFogColor;
		z.fogDistance=z.originalFogDistance;
		z.fogDensity=z.originalFogDensity;

		ThePlayer=none;
		Disable('Tick');
		return;
	}
	if(length>CollisionRadius) length=CollisionRadius;
	if(length<=InnerRadius)    alpha=1.0;
	else
	{
		alpha=1.0-((length-InnerRadius)/(CollisionRadius-InnerRadius));
	}

	
	z.fogColor.r=byte(Lerp(alpha,float(z.originalFogColor.r),float(FogColor.r)));
	z.fogColor.g=byte(Lerp(alpha,float(z.originalFogColor.g),float(FogColor.g)));
	z.fogColor.b=byte(Lerp(alpha,float(z.originalFogColor.b),float(FogColor.b)));
	z.fogColor.a=byte(Lerp(alpha,float(z.originalFogColor.a),float(FogColor.a)));

	z.fogDistance=byte(Lerp(alpha,float(z.originalFogDistance),float(FogDistance)));
	z.fogDensity=Lerp(alpha,z.originalFogDensity,FogDensity);
	
}

function Touch(actor other)
{
	if(PlayerPawn(other)==none) return; // Ensure that this is a player
	ThePlayer=other;
	Enable('Tick');
}

defaultproperties
{
     bDirectional=True
     CollisionRadius=100.000000
}
