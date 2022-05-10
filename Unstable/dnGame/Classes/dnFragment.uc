//=============================================================================
// dnFragment.
//=============================================================================
class dnFragment expands Fragment;

#exec OBJ LOAD FILE=..\Meshes\c_FX.dmx

enum FragmentPhysics
{
	FP_Default,
	FP_Fragment1,
	FP_Glass,
	FP_Wood,
	FP_Paper	// Wishy washy paper fally
};

var () FragmentPhysics Physics; // Which physics to use.

simulated function CalcVelocity(vector Momentum, float ExplosionSize)
{
	// Adjust my velocity according to my physics:
	switch(Physics)
	{
		case FP_Default:
			Super.CalcVelocity(Momentum,ExplosionSize);
			break; 
		
		case FP_Fragment1:
			ExplosionSize = VSize(Momentum);
			Velocity = VRand()*(ExplosionSize+FRand()*100.0+100.0); 
			Velocity.z += ExplosionSize/2;
			break;
		
		case FP_Glass:
			Velocity = (FRand()+0.6+0.4)*VRand() * Momentum * 0.0001;
			break;			
			
		case FP_Wood:
			Super.CalcVelocity(Momentum, ExplosionSize);
			Velocity.z += ExplosionSize/2;
			break;		
	}
}

defaultproperties
{
}
