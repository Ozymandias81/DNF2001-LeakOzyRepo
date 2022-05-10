//=============================================================================
// ExplosionChain.
//=============================================================================
class ExplosionChain extends Effects;

#exec OBJ LOAD FILE=..\Textures\t_explosionfx.dtx

#exec Texture Import File=models\exp001.pcx Name=s_Exp001 Mips=Off Mask=On Flags=2

var() float			MomentumTransfer;
var() float			Damage;
var() float			Size;
var() float			Delaytime;
var() bool			Retriggerable;
var() class<actor>	ExplosionSpawnActor;

var bool bExploding;

function PreBeginPlay()
{
	Texture=None;
	Super.PreBeginPlay();
}

singular function TakeDamage( int NDamage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType )
{
	if ( bOnlyTriggerable && DamageType != class'ExplosionChainDamage' )
		return;
	
	Instigator = InstigatedBy;
	MakeNoise(1.0);
	//GoToState('Exploding');
	bExploding = True;
	SetTimer(DelayTime+FRand()*DelayTime*2, False);

}

function Trigger( actor Other, pawn EventInstigator )
{
	TakeDamage( 10, EventInstigator, Location, Vector(Rotation), class'ExplosionChainDamage' );
}

function Timer(optional int TimerNum)
{
	local actor f;
	
	bExploding = true;
	HurtRadius( Damage, Damage+100, class'ExplosionChainDamage', MomentumTransfer, Location );
	f = spawn(ExplosionSpawnActor,,,Location + vect(0,0,1)*16,rot(16384,0,0)); 
	f.DrawScale = (Damage/100+0.4+FRand()*0.5)*Size;

	if(!Retriggerable) Destroy();
}

//////////////////////////////////////////////////////////////

defaultproperties
{
     MomentumTransfer=100000.000000
     Damage=100.000000
     Size=1.000000
     DelayTime=0.300000
     bNetTemporary=False
     RemoteRole=ROLE_SimulatedProxy
     DrawType=DT_Sprite
     Texture=Texture'engine.s_actor'
     DrawScale=0.400000
     bCollideActors=True
     bCollideWorld=True
     bProjTarget=True
}
