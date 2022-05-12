//=============================================================================
// CH_Earthquake.
//=============================================================================
class CH_Earthquake extends Earthquake;

var() bool bThrowStuff;

	function Trigger(actor Other, pawn EventInstigator)
	{
		local Actor A;
		local vector throwVect;
		if (bThrowStuff)
		{
			throwVect = 0.18 * Magnitude * VRand();
			throwVect.Z = FMax(Abs(ThrowVect.Z), 120);
		} 
		foreach visiblecollidingactors(class'Actor', A, radius,, true)
		{
			if ( A.IsA('PlayerPawn') )
				PlayerPawn(A).ShakeView(duration, magnitude, 0.015 * magnitude);
			if ( bThrowStuff )
			{
				if ( A.bIsPawn )
					Pawn(A).AddVelocity(throwVect);
				else if ( A.IsA('Decoration') && Decoration(A).bPushable
							&& (A.Physics == PHYS_None) )
				{
					A.SetPhysics(PHYS_Falling);
					A.Velocity = throwVect;
				}
			}
		}

		if ( bThrowStuff && (duration > 0.5) )
		{
			remainingTime = duration;
			SetTimer(0.5, false);
		}
	}

	function Timer()
	{
		local vector throwVect;
		local Actor A;
		local PlayerPawn P;
		remainingTime -= 0.5;
		throwVect = 0.15 * Magnitude * VRand();
		throwVect.Z = FMax(Abs(ThrowVect.Z), 120);

		foreach visiblecollidingactors(class'Actor', A, radius,, true)
		{
			if ( A.IsA('PlayerPawn') )
			{
				P = PlayerPawn(A);
				P.BaseEyeHeight = FMin(P.Default.BaseEyeHeight, P.BaseEyeHeight * (0.5 + FRand()));
				P.ShakeView(remainingTime, magnitude, 0.015 * magnitude);
			}
			if ( A.bIsPawn && (A.Physics != PHYS_Falling) )
				Pawn(A).AddVelocity(throwVect);
			else if ( A.IsA('Decoration') && Decoration(A).bPushable
						&& (A.Physics == PHYS_None) )
			{
				A.SetPhysics(PHYS_Falling);
				A.Velocity = throwVect;
			}
		}
			
		if ( remainingTime > 0.5 )
			SetTimer(0.5, false);
	}	

defaultproperties
{
}
