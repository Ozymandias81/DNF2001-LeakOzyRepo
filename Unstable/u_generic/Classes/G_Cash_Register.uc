//=============================================================================
// G_Cash_Register.
//=============================================================================
// AllenB
class G_Cash_Register expands dnSwitchDecoration;

defaultproperties
{
     SwitchStates(0)=(Sequence=Open_Close)
     SwitchStates(1)=(Sequence=Open_Close)
     Loop=True
     NumberStates=2
     TriggerRadius=40.000000
     TriggerHeight=9.000000
     TriggerType=TT_PlayerProximityAndLookUse
     TriggerRetriggerDelay=1.000000
     Health=50
     bFlammable=True
     CollisionRadius=12.000000
     CollisionHeight=9.000000
     Mesh=DukeMesh'c_generic.cash_register'
}
