class GlassShatterEffect extends SoftParticleSystem;

var () int GlassParticleCountBase;
var () int GlassParticleCountVariance;


simulated function SpawnGlassParticles(vector SurfBase, vector SurfU, vector SurfV, vector SurfUSize, vector SurfVSize,vector IncomingHitVector)
{
	local int ParticleIndex;
	local particle p;
	local int count;
	local float DistanceFromHit;
	local float MaxActivationDelay;

	MaxActivationDelay=1.0;

	GlassParticleCountBase=(VSize(SurfUSize)*VSize(SurfVSize))/100;
	for(count=(GlassParticleCountBase+Rand(GlassParticleCountVariance));
		count>0;
		count--)
	{
		ParticleIndex=SpawnParticle(1);
		if(ParticleIndex>1)
		{
			GetParticle(ParticleIndex,p);
			p.Location=SurfBase+(SurfUSize*FRand())+(SurfVSize*FRand());
			//p.Velocity=vect(0,0,0);
			//p.Acceleration=vect(0,0,0);
			
			DistanceFromHit=VSize(p.Location-Location);
			

			p.Velocity+=IncomingHitVector*(2000.0/VSize(p.Location-Location));
			p.Velocity+=Normal(p.Location-Location)*(2000.0/DistanceFromHit);

			p.ActivationDelay=(FRand()*0.1)+(DistanceFromHit/100.0);
			//if(p.ActivationDelay<0.4) p.ActivationDelay=FRand()*0.001;
			if(p.ActivationDelay>MaxActivationDelay) p.ActivationDelay=(p.ActivationDelay/=2)-(FRand()*0.2); //MaxActivationDelay-(FRand()*0.1);

			if(p.ActivationDelay!=0)
				p.Velocity*=((MaxActivationDelay-p.ActivationDelay)/MaxActivationDelay);

			SetParticle(ParticleIndex,p);


		}
	}
}

simulated function PostBeginPlay()
{
	local texture t;
	local vector SurfBase, SurfU, SurfV, SurfUSize, SurfVSize;
	local vector IncomingHitVector;
	super.PostBeginPlay();


	// Trace back to find the surface that should shatter:

	// return the texture hit, or none.
	

	IncomingHitVector=Normal(-vector(Rotation));
	t=TraceTexture
	(
		Location-(vector(Rotation)*50),
		Location,
		none,		
		SurfBase,
		SurfU,
		SurfV,
		SurfUSize,
		SurfVSize
	);

	
	SpawnGlassParticles(SurfBase, SurfU, SurfV, SurfUSize, SurfVSize,IncomingHitVector);

}

defaultproperties
{
     GlassParticleCountBase=100
     GlassParticleCountVariance=25
     Enabled=False
     Lifetime=0.000000
     InitialVelocity=(Z=0.000000)
     MaxVelocityVariance=(X=30.000000,Y=30.000000,Z=30.000000)
	 BounceVelocityVariance=(X=10.0,Y=10.0,Z=5.0)
     BounceElasticity=0.400000
     Bounce=True
     ParticlesCollideWithWorld=True
     LineStartColor=(R=158,G=223,B=248)
     LineEndColor=(R=219,G=252,B=199)
     DrawScaleVariance=0.050000
     StartDrawScale=0.100000
     EndDrawScale=0.100000
     RotationVariance=6.280000
     UpdateWhenNotVisible=True
     bDirectional=True
     Style=STY_Translucent
     DrawScale=0.100000
	 Lifetime=10.0
	 DestroyWhenEmpty=True
}
