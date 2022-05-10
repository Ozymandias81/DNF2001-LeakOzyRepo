//=============================================================================
// ExplodingWall.
//=============================================================================
class ExplodingWall extends Effects;

#exec Texture Import File=models\exp001.pcx  Name=s_Exp Mips=Off Flags=2

var() float ExplosionSize;
var() float ExplosionDimensions;
var() float WallParticleSize;
var() float WoodParticleSize;
var() float GlassParticleSize;
var() float SparkParticleSize;	// Added by Keith
var() int NumWallChunks;
var() int NumWoodChunks;
var() int NumGlassChunks;
var() int NumSparks;			// Added by Keith
var() texture WallTexture;
var() texture WoodTexture;
var() texture GlassTexture;
var() texture SparkTexture;		// Added by Keith
var() int Health;
var() class<DamageType> ActivatedBy[5];
var() sound BreakingSound;
var() bool bTranslucentGlass;
var() bool bUnlitGlass;

function PreBeginPlay()
{
	DrawType = DT_None;
	Super.PreBeginPlay();
}

auto State Exploding
{
	singular function Trigger( actor Other, pawn EventInstigator )
	{
		Explode(EventInstigator, Vector(Rotation));
	}

	singular function TakeDamage( int NDamage, Pawn InstigatedBy, vector HitLocation,
						vector Momentum, class<DamageType> DamageType)
	{
		local int i;
		local bool bAbort;	

		if ( bOnlyTriggerable )
			return;
		
		if ( DamageType != class'AnyDamage' )
		{
			bAbort = true;
			for ( i=0; i<5; i++ )	 
				if (DamageType==ActivatedBy[i]) bAbort=False;
			if ( bAbort )
				return;
		}
		Health -= NDamage;
		if ( Health <= 0 )
			Explode(instigatedBy, Momentum);
	}

	function Explode( pawn EventInstigator, vector Momentum)
	{
		local int i;
		local Fragment s;
		local actor A;

		if( Event != '' )
			foreach AllActors( class 'Actor', A, Event )
				A.Trigger( Instigator, Instigator );

		Instigator = EventInstigator;
		if ( Instigator != None )
			MakeNoise(1.0);
		
		PlaySound(BreakingSound, SLOT_None,2.0);

		Destroy();
	}
}

defaultproperties
{
     ExplosionSize=200.000000
     ExplosionDimensions=120.000000
     WallParticleSize=1.000000
     WoodParticleSize=1.000000
     GlassParticleSize=1.000000
     NumWallChunks=10
     NumWoodChunks=3
     ActivatedBy(0)=class'ExplosionDamage'
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Sprite
     Texture=Texture'engine.s_actor'
     DrawScale=0.300000
     CollisionRadius=32.000000
     CollisionHeight=32.000000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
}
