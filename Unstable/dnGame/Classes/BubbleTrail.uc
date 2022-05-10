class BubbleTrail extends Projectile;

var dnBubbleFX_BulletTrail Trail;

function PostBeginPlay()
{
	local vector dir;

	Super.PostBeginPlay();

	dir = vector(Rotation);
	Velocity = speed * dir;
	//Acceleration = 0;

	Trail = spawn(class'dnBubbleFX_BulletTrail');
	Trail.SetPhysics(PHYS_MovingBrush);
	Trail.AttachActorToParent(self, true, true);
}

simulated function Destroyed()
{
	if (Trail != none)
	{
		Trail.Enabled = false;
		Trail.DestroyWhenEmpty = true;
		Trail = none;
	}
	Super.Destroyed();
}

defaultproperties
{
	speed=3072
}