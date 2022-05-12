//=============================================================================
// ut_BloodDrop.
//=============================================================================
class UT_BloodDrop extends Effects;

function PostBeginPlay()
{
	Velocity = (Vector(Rotation) + VRand()) * (80 * FRand() + 20);
	Velocity.z += 30;
	if ( !Level.bDropDetail )
		Texture = MultiSkins[Rand(8)];
	Drawscale = FRand()*0.2+0.1;
}

auto state Explode
{

	simulated function Landed( vector HitNormal )
	{
		Destroy();
	}

	simulated function HitWall( vector HitNormal, actor Wall )
	{
		Destroy();
	}
}

defaultproperties
{
     Physics=PHYS_Falling
     RemoteRole=ROLE_None
     LifeSpan=1.000000
     DrawType=DT_Sprite
     Style=STY_Masked
     Texture=Texture'Botpack.Blood.BD3'
     DrawScale=0.300000
     MultiSkins(0)=Texture'Botpack.Blood.BD3'
     MultiSkins(1)=Texture'Botpack.Blood.BD4'
     MultiSkins(2)=Texture'Botpack.Blood.BD6'
     MultiSkins(3)=Texture'Botpack.Blood.BD9'
     MultiSkins(4)=Texture'Botpack.Blood.BD10'
     MultiSkins(5)=Texture'Botpack.Blood.BD3'
     MultiSkins(6)=Texture'Botpack.Blood.BD4'
     MultiSkins(7)=Texture'Botpack.Blood.BD6'
     bCollideWorld=True
     bBounce=True
     NetPriority=2.000000
}
